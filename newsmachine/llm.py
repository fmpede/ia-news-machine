"""Un solo punto de entrada a los LLM con fallback ordenado y contadores diarios en la tabla quota.

complete(prompt, system, json_schema, tier) → str | dict
  tier "cheap"   : gemini → groq → haiku      (ranking, borradores, traducción)
  tier "quality" : sonnet → haiku             (hero del día)
  tier "qa"      : haiku → sonnet             (nunca cae a proveedores gratuitos: si no hay Claude, se bloquea)
"""
import json, os, re, sys
import requests
from . import db

OPENAI_COMPAT = {  # nombre: (base_url, env key, modelo) — hablan /chat/completions
    "groq": ("https://api.groq.com/openai/v1", "GROQ_API_KEY", "openai/gpt-oss-120b"),
}
GEMINI = {"gemini": ("GEMINI_API_KEY", "gemini-3.8-flash"), "gemini_lite": ("GEMINI_API_KEY", "gemini-3.5-flash-lite")}  # nativo; clave en header, nunca en la URL (2.5 ya no existe para cuentas nuevas)
CLAUDE = {"haiku": "claude-haiku-4-5", "sonnet": "claude-sonnet-5"}
# ponytail: llamadas/día ~20% debajo del cupo publicado (2026-09); ajustar si un proveedor cambia su tier.
LIMITS = {"gemini": 200, "gemini_lite": 300, "groq": 800, "haiku": 400, "sonnet": 40}
TIERS = {"cheap": ["gemini", "gemini_lite", "groq", "haiku"], "quality": ["sonnet", "haiku"], "qa": ["haiku", "sonnet"]}


def complete(prompt, system="", json_schema=None, tier="cheap", max_tokens=8000):
    errors = []
    for name in TIERS[tier]:
        key = os.getenv("ANTHROPIC_API_KEY" if name in CLAUDE else GEMINI[name][0] if name in GEMINI else OPENAI_COMPAT[name][1])
        if not key or (db.CONN is not None and db.quota_used(name) >= LIMITS[name]):
            continue
        try:
            fn = _claude if name in CLAUDE else _gemini if name in GEMINI else _openai
            text, tokens = fn(name, key, prompt, system, json_schema, max_tokens)
            out = _parse(text, json_schema)
            if db.CONN is not None:
                db.quota_add(name, tokens=tokens)
            return out
        except Exception as e:  # 429, 5xx, JSON inválido, claves faltantes → siguiente proveedor
            if db.CONN is not None:
                db.quota_add(name, calls=0, errors=1)
            errors.append(f"{name}: {type(e).__name__}: {str(e)[:200]}")
    raise RuntimeError("todos los proveedores fallaron: " + " | ".join(errors))


def _openai(name, key, prompt, system, schema, max_tokens):
    base, _, model = OPENAI_COMPAT[name]
    if schema:  # json_object está soportado por todos; el esquema va en el system prompt y se valida en _parse
        system = f"{system}\n\nRespondé únicamente con JSON válido que cumpla este esquema:\n{json.dumps(schema, ensure_ascii=False)}"
    body = {"model": model, "max_tokens": max_tokens, "temperature": 0.4,
            "messages": [{"role": "system", "content": system}, {"role": "user", "content": prompt}]}
    if schema:
        body["response_format"] = {"type": "json_object"}
    r = requests.post(f"{base}/chat/completions", json=body, timeout=180, headers={"Authorization": f"Bearer {key}"})
    r.raise_for_status()
    j = r.json()
    return j["choices"][0]["message"]["content"], j.get("usage", {}).get("total_tokens", 0)


def _gemini(name, key, prompt, system, schema, max_tokens):
    model = GEMINI[name][1]
    if schema:
        system = f"{system}\n\nRespondé únicamente con JSON válido que cumpla este esquema:\n{json.dumps(schema, ensure_ascii=False)}"
    body = {"contents": [{"role": "user", "parts": [{"text": prompt}]}],
            "generationConfig": {"temperature": 0.4, "maxOutputTokens": max_tokens, **({"responseMimeType": "application/json"} if schema else {})}}
    if system:
        body["system_instruction"] = {"parts": [{"text": system}]}
    r = requests.post(f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent", json=body, timeout=180,
                      headers={"x-goog-api-key": key})
    r.raise_for_status()
    j = r.json()
    if not j.get("candidates"):
        raise RuntimeError(f"sin candidatos: {j.get('promptFeedback')}")
    text = "".join(p.get("text", "") for p in j["candidates"][0]["content"]["parts"])
    return text, j.get("usageMetadata", {}).get("totalTokenCount", 0)


def _claude(name, key, prompt, system, schema, max_tokens):
    import anthropic
    kw = {}
    if schema or name == "sonnet":
        kw["output_config"] = {}
        if schema:
            kw["output_config"]["format"] = {"type": "json_schema", "schema": schema}
        if name == "sonnet":
            kw["output_config"]["effort"] = "medium"  # Haiku 4.5 no soporta effort
    msg = anthropic.Anthropic(api_key=key).messages.create(
        model=CLAUDE[name], max_tokens=max_tokens, system=system or anthropic.NOT_GIVEN,
        messages=[{"role": "user", "content": prompt}], **kw)
    if msg.stop_reason == "refusal":
        raise RuntimeError("refusal")
    text = next(b.text for b in msg.content if b.type == "text")
    return text, msg.usage.input_tokens + msg.usage.output_tokens


def _parse(text, schema):
    if not schema:
        return text
    text = re.sub(r"^```(?:json)?\s*|\s*```$", "", text.strip(), flags=re.M)
    data = json.loads(text)
    missing = [k for k in schema.get("required", []) if k not in data] if isinstance(data, dict) else []
    if missing:
        raise ValueError(f"faltan claves {missing}")
    return data


def configured():
    env = lambda n: "ANTHROPIC_API_KEY" if n in CLAUDE else GEMINI[n][0] if n in GEMINI else OPENAI_COMPAT[n][1]
    return [n for n in [*GEMINI, *OPENAI_COMPAT, *CLAUDE] if os.getenv(env(n))]


if __name__ == "__main__":  # python -m newsmachine.llm --selftest : una llamada mínima por proveedor configurado
    from .config import load_env
    load_env()
    if not configured():
        print("sin claves configuradas (ANTHROPIC_API_KEY / GEMINI_API_KEY / GROQ_API_KEY)"); sys.exit(0)
    schema = {"type": "object", "properties": {"ok": {"type": "boolean"}}, "required": ["ok"], "additionalProperties": False}
    for n in configured():
        TIERS["_one"] = [n]
        try:
            print(n, complete("Respondé {\"ok\": true}", json_schema=schema, tier="_one", max_tokens=200))
        except Exception as e:
            print(n, "FAIL", e)
