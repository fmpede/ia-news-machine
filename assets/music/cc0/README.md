# Música de fondo (CC0, opcional)

Este directorio es opcional. `pipeline/media.py` busca aquí cualquier `*.mp3` y, si
encuentra alguno, elige uno al azar (o el primero por orden alfabético) para
mezclarlo por debajo de la voz del video (a -18dB, con `amix`). Si el
directorio está vacío, el video se genera igual, solo con la voz.

## De dónde sacar música

- **Pixabay Music** (https://pixabay.com/music/) — licencia Pixabay Content
  License, uso comercial permitido sin atribución obligatoria (igual es buena
  práctica dejarla). Filtrar por "no copyright" / instrumental, tono acorde a
  la marca (energético pero no invasivo, sin voces).
- Otras fuentes CC0 válidas: Free Music Archive (filtrar CC0), YouTube Audio
  Library (pistas marcadas "no attribution required").

Evitar cualquier pista con licencia que exija atribución obligatoria en el
video (complica la automatización) o que restrinja uso comercial.

## Cómo nombrar los archivos

- Minúsculas, sin espacios: `synth-ambient-01.mp3`, `lofi-beat-02.mp3`.
- Duración recomendada: 60–180 segundos (se recorta/loopea automáticamente
  según la duración del audio narrado).
- Mantener el volumen del archivo original razonable (sin clipping); el mezclado
  ya aplica una atenuación de -18dB pero un archivo ya saturado igual sonará mal.

## Licencia y registro

Antes de subir un archivo, anotar en este mismo README (o en un
`CREDITS.txt` en esta carpeta) el nombre, la fuente y el link de licencia,
por si hace falta acreditar en la descripción del video o responder un
reclamo de derechos.
