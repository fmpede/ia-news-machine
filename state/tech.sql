BEGIN TRANSACTION;
CREATE TABLE metrics (publish_id INTEGER REFERENCES publish_log(id), snapshot_at TEXT,
  likes INTEGER, reposts INTEGER, replies INTEGER, views INTEGER, raw_json TEXT, PRIMARY KEY (publish_id, snapshot_at));
CREATE TABLE outputs (
  id INTEGER PRIMARY KEY, vertical TEXT, date TEXT, story_id INTEGER, lang TEXT,
  format TEXT CHECK (format IN ('post','thread','carousel','card','video','article','illustration')),
  content_json TEXT NOT NULL, file_path TEXT, public_url TEXT,
  qa_status TEXT DEFAULT 'pending' CHECK (qa_status IN ('pending','pass','fixed','blocked')),
  qa_json TEXT, model TEXT, created_at TEXT,
  UNIQUE (vertical, date, story_id, lang, format));
CREATE TABLE publish_log (
  id INTEGER PRIMARY KEY, vertical TEXT, date TEXT, story_id INTEGER, lang TEXT, network TEXT, format TEXT,
  status TEXT CHECK (status IN ('ok','failed','packed','skipped')),
  post_id TEXT, url TEXT, error TEXT, published_at TEXT,
  UNIQUE (vertical, story_id, lang, network));
CREATE TABLE quota (provider TEXT, day TEXT, calls INTEGER DEFAULT 0, tokens INTEGER DEFAULT 0,
  errors INTEGER DEFAULT 0, PRIMARY KEY (provider, day));
CREATE TABLE runs (vertical TEXT, date TEXT, stage TEXT, status TEXT, detail TEXT, at TEXT);
INSERT INTO "runs" VALUES('tech','2026-09-16','ingest','ok','The Verge: 10/10; Ars Technica: 20/20; TechCrunch: 20/20; Xataka: 26/26; Hacker News: 10/10; GitHub: 20/20; arXiv: 15/15; Google News: 102/102','2026-09-16T19:40:45+00:00');
INSERT INTO "runs" VALUES('tech','2026-09-16','cluster','ok','223 stories, 221 clusters','2026-09-16T19:40:54+00:00');
INSERT INTO "runs" VALUES('tech','2026-09-16','ingest','ok','The Verge: 0/10; Ars Technica: 0/20; TechCrunch: 1/20; Xataka: 0/26; Hacker News: 0/9; GitHub: 0/20; arXiv: 0/15; Google News: 5/102','2026-09-16T19:58:50+00:00');
INSERT INTO "runs" VALUES('tech','2026-09-16','cluster','ok','229 stories, 226 clusters','2026-09-16T19:58:50+00:00');
INSERT INTO "runs" VALUES('tech','2026-09-16','rank','warn','LLM falló, heurística: todos los proveedores fallaron: ','2026-09-16T19:58:50+00:00');
INSERT INTO "runs" VALUES('tech','2026-09-16','rank','warn','LLM falló, heurística: todos los proveedores fallaron: ','2026-09-16T19:58:50+00:00');
INSERT INTO "runs" VALUES('tech','2026-09-16','rank','warn','LLM falló, heurística: todos los proveedores fallaron: ','2026-09-16T19:58:50+00:00');
INSERT INTO "runs" VALUES('tech','2026-09-16','rank','warn','LLM falló, heurística: todos los proveedores fallaron: ','2026-09-16T19:58:50+00:00');
INSERT INTO "runs" VALUES('tech','2026-09-16','rank','warn','LLM falló, heurística: todos los proveedores fallaron: ','2026-09-16T19:58:50+00:00');
INSERT INTO "runs" VALUES('tech','2026-09-16','rank','warn','LLM falló, heurística: todos los proveedores fallaron: ','2026-09-16T19:58:50+00:00');
INSERT INTO "runs" VALUES('tech','2026-09-16','rank','warn','LLM falló, heurística: todos los proveedores fallaron: ','2026-09-16T19:58:50+00:00');
INSERT INTO "runs" VALUES('tech','2026-09-16','rank','warn','LLM falló, heurística: todos los proveedores fallaron: ','2026-09-16T19:58:50+00:00');
INSERT INTO "runs" VALUES('tech','2026-09-16','rank','warn','LLM falló, heurística: todos los proveedores fallaron: ','2026-09-16T19:58:50+00:00');
INSERT INTO "runs" VALUES('tech','2026-09-16','rank','warn','LLM falló, heurística: todos los proveedores fallaron: ','2026-09-16T19:58:50+00:00');
INSERT INTO "runs" VALUES('tech','2026-09-16','rank','ok','0 por LLM, 226 por heurística','2026-09-16T19:58:50+00:00');
INSERT INTO "runs" VALUES('tech','2026-09-16','select','ok','6 historias, hero=Show HN: An e-ink frame that hears birds and draws them as 1','2026-09-16T19:58:53+00:00');
INSERT INTO "runs" VALUES('tech','2026-09-16','metrics','ok','0 snapshots','2026-09-17T00:03:29+00:00');
CREATE TABLE selected (
  vertical TEXT, date TEXT, story_id INTEGER REFERENCES stories(id),
  role TEXT CHECK (role IN ('hero','story')), position INTEGER,
  PRIMARY KEY (vertical, date, story_id));
INSERT INTO "selected" VALUES('tech','2026-09-16',77,'hero',0);
INSERT INTO "selected" VALUES('tech','2026-09-16',80,'story',1);
INSERT INTO "selected" VALUES('tech','2026-09-16',87,'story',2);
INSERT INTO "selected" VALUES('tech','2026-09-16',88,'story',3);
INSERT INTO "selected" VALUES('tech','2026-09-16',1,'story',4);
INSERT INTO "selected" VALUES('tech','2026-09-16',2,'story',5);
CREATE TABLE stories (
  id INTEGER PRIMARY KEY, vertical TEXT NOT NULL, url TEXT NOT NULL, url_hash TEXT NOT NULL,
  title TEXT NOT NULL, summary TEXT, body TEXT, source TEXT NOT NULL, source_weight REAL DEFAULT 1,
  lang TEXT, points INTEGER, published_at TEXT, fetched_at TEXT NOT NULL,
  cluster_id INTEGER, score REAL, score_json TEXT,
  UNIQUE (vertical, url_hash));
INSERT INTO "stories" VALUES(1,'tech','https://www.theverge.com/entertainment/996416/resident-zach-cregger-review','39b97b89b02a8f661ee01758cb7ff6c2d0646911','Resident Evil is a comedy first and a thrilling nightmare second','When Paul W.S. Anderson''s Resident Evil hit theaters in 2002, video game movies were largely seen as a niche. Films like Mortal Kombat and Tomb Raider had proven that big-screen game adaptations could be successful, but the commercial and critical failure of projects like the 1993 Super Mario Bros. still cast a long shadow. And […]','Login / Sign Up
Facebook
Threads
Instagram
Youtube
RSS
Entertainment
Gaming
Film
﻿Zach Cregger’s take on Capcom’s zombie franchise is a testament to how video game movies have evolved.
﻿Zach Cregger’s take on Capcom’s zombie franchise is a testament to how video game movies have evolved.
Link
Share
Gift
When Paul W.S. Anderson’s Resident Evil hit theaters in 2002, video game movies were largely seen as a niche. Films like Mortal Kombat and Tomb Raider had proven that big-screen game adaptations could be successful, but the commercial and critical failure of projects like the 1993 Super Mario Bros. still cast a long shadow. And while Anderson’s vision of Raccoon City might have captivated audiences on the whole, many hardcore fans of Capcom’s games were left disappointed by the way the original movies wildly deviated from the source material.
Weapons director Zach Cregger’s new take on Resident Evil is a return to the franchise’s fundamentals and a choice example of how video game movies have evolved. Its story is stripped down and its zombified monsters are terrifying. It’s also chiefly a movie that’s trying to make you laugh. Cregger uses humor to amplify his Resident Evil’s horror — his spin on the games’ infected ghouls are meant to be as funny as they are disturbing. The film feels like it could be the beginning of a fantastic new era for the franchise, but what’s most impressive is how well it can work as one and done.
Though this Resident Evil is peppered with nods to Capcom’s games, it focuses on Bryan (Austin Abrams), a medical courier character created for the movie. Like most people living in his mountain town, Bryan knows that a drive over to Raccoon City in the middle of winter can be hell, but a last-minute, high-paying delivery gig is enough to convince him to make the trip. Even with the treacherous weather and spotty cellphone reception, Bryan’s journey with his mysterious cargo is mostly uneventful as he first sets out. But he begins to understand what kind of danger he’s wandering into when he accidentally runs over a shambling woman (Andrea Miltnerová) who doesn’t seem to realize that she’s just been hit by an out-of-control car.
Resident Evil’s first big scare almost immediately establishes the sense of humor Cregger leans into throughout the film. You can feel the fear oozing out of Bryan as he trudges into the woods looking for the woman, but that tension momentarily evaporates as the film smash-cuts to him coaxing her into his car so that he can get her the medical help she clearly needs. The same dread rushes to the fore when Bryan witnesses how Resident Evil’s infected humans can mutate into creatures that feel like nods to Katamari Damacy and The Legend of Zelda: Breath of the Wild. But it’s hard not to laugh when Bryan muses about how interesting the zombies’ transformations are to see up close.
Cregger knows that while viewers might not be familiar with Resident Evil’s lore, we can all appreciate how horror movies need their characters to make poor decisions. Abrams plays Bryan with a wide-eyed guilelessness that’s charming, but what really makes the character work is the way each monster encounter forces him to evolve into someone with better survival instincts.
By building the film around a civilian instead of highly trained special agents, Cregger and co-writer Shay Hatten give themselves the ability to tell a story that leans into the survival aspect of survival horror. Because Bryan is a bit of a dolt who’s constantly screaming in terror and fumbling his bullets when he’s scared, it often feels like the movie is replicating the experience of playing (or watching someone else play) a Resident Evil game for the first time. Bryan finds a couple of guns and a very limited number of bullets, but they’re nowhere near enough to make him feel safe as he trudges toward Raccoon City making the occasional stop to search seemingly empty buildings in hopes of finding a way to call for help.
The movie’s indo','The Verge',1.0,'en',NULL,'2026-09-16T18:45:35+00:00','2026-09-16T19:40:38+00:00',1,59.4,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(2,'tech','https://www.theverge.com/gadgets/996379/metroid-ravenous-preorder-deal-sale','1ee7e5ce99bb3ff21412ad7e0b9d382029c2f30e','Walmart takes a bite off the cost of Metroid Ravenous physical preorders','The Metroid series is going back to its 2D roots again with Metroid Ravenous for the Nintendo Switch 2, the first side-scrolling game in the series since 2021’s Metroid Dread for the Nintendo Switch. If you’re already excited enough to consider preordering, you can save $10 on the physical version of the game when you […]','Login / Sign Up
Facebook
Threads
Instagram
Youtube
RSS
Gadgets
Gaming
Nintendo
Walmart is once again giving gamers a discount when they preorder an upcoming Nintendo game.
Walmart is once again giving gamers a discount when they preorder an upcoming Nintendo game.
Link
Share
If you buy something from a Verge link, Vox Media may earn a commission. See our ethics statement.
The Metroid series is going back to its 2D roots again with Metroid Ravenous for the Nintendo Switch 2, the first side-scrolling game in the series since 2021’s Metroid Dread for the Nintendo Switch. If you’re already excited enough to consider preordering, you can save $10 on the physical version of the game when you buy it from Walmart. It’s $59.88 instead of $69.99, about the same as buying it digitally. The game launches on January 28th, 2027, but it’s not clear how long the preorder discount will last. If it’s anything like other Walmart preorders, it may occasionally disappear.
Metroid Ravenous
Nintendo first showed off the side-scrolling adventure game at its September 2026 Direct, with a frantic trailer cutting between cinematic sequences, Samus dashing and rolling across a variety of environments, and engaging a number of enemies and bosses in battle. Samus absorbs some powerful abilities at the conclusion of Dread, and Ravenous seem to be all about plowing through anyone stopping her from escaping the planet. Other details of the story, including unique new mechanics, are being kept under wraps for the time being.
If you haven’t played Metroid Dread, I recommend it, especially at its $41.99 discounted price at Amazon. It’s part of Nintendo’s “Customer Appreciation” sale happening through September 26th, and several other games and accessories are cheaper, too.
Verge Shopping
Sign up to get the best deals on products we’ve found and tested sent to your inbox.
Brad Bourque
Deals
Gadgets
Gaming
Nintendo
Verge Shopping
Most Popular
The iPhone 18 Pro’s big camera update is all about the small gainsVideo
Microsoft announces Windows and Surface event for October 7th
The Boox Palma 3 gets stylus support and a sleek redesign
The premium AirPods 5 are the best open-ear earbuds Apple has made
What if social media isn’t hurting kids?
Verge Shopping
Sign up to get the best deals on products we’ve found and tested sent to your inbox.
This is the title for the native ad
More in Gadgets
This is the title for the native ad
Top Stories
Sign in to see your notifications or create an account to join the conversation.','The Verge',1.0,'en',NULL,'2026-09-16T18:20:38+00:00','2026-09-16T19:40:38+00:00',2,59.2,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(3,'tech','https://www.theverge.com/tech/996321/apple-servers-ai-nvidia','933ca83973d0dec89de3e3e678727aae6bc9eb03','Apple might make servers again to cash in on the AI rush','According to The Information, Apple is planning to get back into the server game and might just pair up with Nvidia to make it happen. Apple retired its Xserve line in 2011 and has largely left enterprise machines to other manufacturers since. But the growing demand for compute power as the AI industry continues to […]',NULL,'The Verge',1.0,'en',NULL,'2026-09-16T17:20:29+00:00','2026-09-16T19:40:38+00:00',3,58.7,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(4,'tech','https://www.theverge.com/column/995939/optimizer-health-age-wearables-longevity','a94aaee70d91d36b6eb0d137ce0d28b3e881c338','Your ‘health age’ is fake','This is Optimizer, a weekly newsletter sent from Verge senior reviewer Victoria Song that dissects and discusses the latest gizmos and potions that swear they''re going to change your life. Opt in for Optimizer here. During last week''s Apple Watch announcement, I let out a distinct "Noooo!" in the Steve Jobs Theater. Along with a […]',NULL,'The Verge',1.0,'en',NULL,'2026-09-16T17:00:00+00:00','2026-09-16T19:40:38+00:00',4,58.5,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(5,'tech','https://www.theverge.com/tech/996310/google-home-mcp-integration-agentic-ai-smart-home-price-release-date','2306ad1a8f49503f0e07656e48d3e07b3ba86cba','Google will now let any AI agent run your smart home','Google is opening up its smart home to AI agents, letting tools like Claude and Open Claw access and control your connected devices and analyze your home''s data using the standardized Model Context Protocol. Google Home MCP is a new integration that lets third-party AI agents control and monitor your smart home and act on […]',NULL,'The Verge',1.0,'en',NULL,'2026-09-16T17:00:00+00:00','2026-09-16T19:40:38+00:00',5,58.5,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(6,'tech','https://www.theverge.com/ai-artificial-intelligence/996234/anthropic-one-claude-cowork-docs-slides','b10d3b6dd4c6cccd8528d7e489b91f58fbc66496','Claude comes for Gemini with its own take on Docs and Slides','Claude is getting a pair of new tools today: Docs and Slides. They''ll let you create documents and presentations through Claude chats, which you can export, edit, and share with other users. As part of the announcement, Anthropic is also simplifying how Claude chats work, merging regular chats and Cowork into "one Claude," with all […]',NULL,'The Verge',1.0,'en',NULL,'2026-09-16T16:30:00+00:00','2026-09-16T19:40:38+00:00',6,58.3,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(7,'tech','https://www.theverge.com/ai-artificial-intelligence/995348/ai-dating-app-scams','a553240ea84ff9c194196de75a64343111731d48','The sexy AI-powered dating app scams are here','Security researcher Matthew "Zigula" Gore-Kormanik was analyzing a fraudulent dating app called Dora when he got a pop-up message saying he was receiving a call from Jennifer. According to her bio, she''s a 41-year-old Sagittarius with red hair, blue eyes, and piercings. She likes music, horror movies, nightlife, and sports. Gore-Kormanik answered the call, but […]',NULL,'The Verge',1.0,'en',NULL,'2026-09-16T14:45:00+00:00','2026-09-16T19:40:38+00:00',7,57.4,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(8,'tech','https://www.theverge.com/gadgets/996216/xreal-video-glasses-beats-pill-sonos-ace-deal-sale','4f31f426a9084ef576076ad84e97d587f22491bb','Xreal’s well-rounded 1S glasses are back down to their lowest price','USB-C-connected video glasses are a lot of fun if you want to see your games, movies (or just your computer screen) on a large, immersive virtual screen. One of the most well-rounded pairs out there, Xreal’s 1S, has returned to their lowest price yet, costing $399 at Amazon and via Xreal itself ($50 off). The […]',NULL,'The Verge',1.0,'en',NULL,'2026-09-16T14:44:48+00:00','2026-09-16T19:40:38+00:00',8,57.4,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(9,'tech','https://www.theverge.com/policy/995534/a-brief-history-of-ai-executives-calling-for-regulation','3a2fbb6e3782c2e74b97ea5b10567d3216b4593d','A brief history of AI executives calling for regulation','Over the past few days, a lot of people who stand to make a lot of money from AI all publicly agreed that it''s time to make everyone slow down before we lose control - including OpenAI CEO Sam Altman, Anthropic CEO Dario Amodei, Google DeepMind cofounder Demis Hassabis, Microsoft CEO Satya Nadella, and X […]',NULL,'The Verge',1.0,'en',NULL,'2026-09-16T12:00:00+00:00','2026-09-16T19:40:38+00:00',9,56.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(10,'tech','https://www.theverge.com/games/995539/fire-emblem-fortunes-weave-switch-2-review','7a3612640a4eb551eb0a0c40afad8527c2640511','Nintendo opens up Fire Emblem with the gigantic Fortune’s Weave','Nintendo has gotten quite good at making open-ended games. The Legend of Zelda: Breath of the Wild upended the idea of what a Zelda game could be by giving the player free rein to tackle any part of the map, a philosophy iterated upon with Tears of the Kingdom. On the Switch 2 this idea […]',NULL,'The Verge',1.0,'en',NULL,'2026-09-16T12:00:00+00:00','2026-09-16T19:40:38+00:00',10,56.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(11,'tech','https://arstechnica.com/tech-policy/2026/09/its-ok-to-tell-ice-their-actions-will-haunt-them-judge-rules-in-speech-fight/','48fc7d3b506fd1e2967805a13df9d43e4b4c9f90','It’s OK to tell ICE their actions will haunt them, judge rules in speech fight','Man wins fight to block ICE threat over off-the-cuff angry email.',NULL,'Ars Technica',1.0,'en',NULL,'2026-09-16T17:06:06+00:00','2026-09-16T19:40:38+00:00',11,58.6,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(12,'tech','https://arstechnica.com/gadgets/2026/09/iran-strikes-on-amazon-data-centers-caused-permanent-loss-of-customer-data/','1fcf60fdf5f4ffc1ecc259547aef600a8393812a','Iran strikes on Amazon data centers caused permanent loss of customer data','War damage to data centers exceeded what AWS services are designed to withstand.',NULL,'Ars Technica',1.0,'en',NULL,'2026-09-16T16:40:11+00:00','2026-09-16T19:40:38+00:00',12,58.3,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(13,'tech','https://arstechnica.com/science/2026/09/what-happens-when-neutrinos-swap-identities-inside-a-supernova/','c7f0d689db84445aecda85572c08e2a1203fd718','What happens when neutrinos swap identities inside a supernova?','Identity-fluid particles may carry some energy out, leading to direct collapse.',NULL,'Ars Technica',1.0,'en',NULL,'2026-09-16T15:17:43+00:00','2026-09-16T19:40:38+00:00',13,57.7,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(14,'tech','https://arstechnica.com/gadgets/2026/09/macos-27-golden-gate-the-ars-technica-review/','7428046dd0d550cc7beef8ccb83828d381ed9a82','macOS 27 Golden Gate: The Ars Technica review','It''s both a "Snow Leopard update" and a major leap for Apple Intelligence.',NULL,'Ars Technica',1.0,'en',NULL,'2026-09-16T14:50:06+00:00','2026-09-16T19:40:38+00:00',14,57.4,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(15,'tech','https://arstechnica.com/cars/2026/09/the-worlds-best-racing-driver-is-about-to-race-100-karts-at-once/','f9b65ef1c43a7cddd96d66f18bd2afadd8b1f371','The world’s best racing driver is about to race 100 karts at once','Red Bull, Disney+, and ESPN are streaming the race at noon Eastern today.',NULL,'Ars Technica',1.0,'en',NULL,'2026-09-16T14:19:01+00:00','2026-09-16T19:40:38+00:00',15,57.2,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(16,'tech','https://arstechnica.com/tech-policy/2026/09/lawmakers-target-flock-cameras-with-a-threat-to-highway-funding/','ffef8a1be6adf72dfcd332cf468b3a839cfb2bc4','Lawmakers target Flock cameras with a threat to highway funding','A bipartisan bill would restrict Flock cameras to a handful of public safety uses.',NULL,'Ars Technica',1.0,'en',NULL,'2026-09-16T14:03:39+00:00','2026-09-16T19:40:38+00:00',16,57.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(17,'tech','https://arstechnica.com/science/2026/09/how-chimps-teach-their-kids-tool-tricks/','d2b6d52ede2d58425e8da9079a0c8a9465b75254','How chimps teach their kids tool tricks','Adults first demonstrate tool use, then hand over the implements to their infants, who copy the behavior.',NULL,'Ars Technica',1.0,'en',NULL,'2026-09-16T04:00:39+00:00','2026-09-16T19:40:38+00:00',17,52.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(18,'tech','https://arstechnica.com/space/2026/09/the-roman-telescope-has-enough-gas-for-22-years-double-nasas-expectations/','e009fde4cd830e7b3c321e0b755be7a72558f480','The Roman telescope has enough gas for 22 years, double NASA''s expectations','The Nancy Grace Roman Space Telescope is the first NASA observatory designed for in-space refueling.',NULL,'Ars Technica',1.0,'en',NULL,'2026-09-15T22:26:32+00:00','2026-09-16T19:40:38+00:00',18,49.2,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(19,'tech','https://arstechnica.com/tech-policy/2026/09/filmmaker-suing-passthepopcorn-may-be-banned-user-out-for-revenge/','f3290b3e79e6469225411ee9f14605079c06d0bf','“Filmmaker” suing PassThePopcorn may be banned user out for revenge','Allegedly fake filmmaker targeted trackers like PassThePopcorn, BroadcasTheNet, and HDBits.',NULL,'Ars Technica',1.0,'en',NULL,'2026-09-15T20:19:17+00:00','2026-09-16T19:40:38+00:00',19,48.2,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(20,'tech','https://arstechnica.com/health/2026/09/measles-kills-18-year-old-in-pa-fourth-death-as-state-outbreak-nears-700-cases/','82c2b1e02cab6e60faf92dd8d2d4b3862136d588','18-year-old dies of measles in PA from severe neurological complication','Teen developed acute disseminated encephalomyelitis, a known measles complication.',NULL,'Ars Technica',1.0,'en',NULL,'2026-09-15T18:58:09+00:00','2026-09-16T19:40:38+00:00',20,47.5,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(21,'tech','https://arstechnica.com/space/2026/09/spacex-sets-launch-date-for-first-starship-orbital-flight/','af431be1c18d5dd6dff7b23114cb6cbf297d092c','SpaceX declares Starship ready for orbit, sets launch date next week','Reaching orbit would mark a significant milestone.',NULL,'Ars Technica',1.0,'en',NULL,'2026-09-15T18:48:08+00:00','2026-09-16T19:40:38+00:00',21,47.4,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(22,'tech','https://arstechnica.com/ai/2026/09/agilitys-new-humanoid-robot-will-stop-squat-to-avoid-harming-human-coworkers/','ca4965f11fd951c479aada20ec1d47ce82a56513','Agility’s new humanoid robot will stop, squat to avoid harming human coworkers','Robots can start working outside physical cages and without safety barriers.',NULL,'Ars Technica',1.0,'en',NULL,'2026-09-15T18:33:02+00:00','2026-09-16T19:40:38+00:00',22,47.3,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(23,'tech','https://arstechnica.com/tech-policy/2026/09/boston-dumps-flock-says-it-shared-data-nationwide-in-violation-of-contract/','2795ab6da052e8530a545922ec8ad0ef2b7d0657','Boston dumps Flock, says it shared data nationwide in violation of contract','City: Flock enabled "nationwide lookup" despite contract requiring it to be disabled.',NULL,'Ars Technica',1.0,'en',NULL,'2026-09-15T18:14:11+00:00','2026-09-16T19:40:38+00:00',23,47.1,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(24,'tech','https://arstechnica.com/cars/2026/09/ev-charging-infrastructure-is-still-lagging-adoption-report-says/','2ad2e34f0cb50a332cd2113696bf35bb11ef8e58','Demand for EV chargers is outstripping supply, says ChargePoint report','EV growth is happening, even in the US, and those EVs will need plugs to charge.',NULL,'Ars Technica',1.0,'en',NULL,'2026-09-15T17:58:09+00:00','2026-09-16T19:40:38+00:00',24,47.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(25,'tech','https://arstechnica.com/science/2026/09/epa-seeks-to-eliminate-remaining-greenhouse-gas-rules-for-power-plants/','2e7ea67e298ed733f35625d196478ee1f5b8fd21','Trump EPA moves to wipe out climate rules for power plants','EPA says power plant emissions have no material impact on climate change.',NULL,'Ars Technica',1.0,'en',NULL,'2026-09-15T13:43:51+00:00','2026-09-16T19:40:38+00:00',25,44.9,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(26,'tech','https://arstechnica.com/cars/2026/09/gm-gives-its-most-important-trucks-a-new-ui-and-includes-carplay/','889867f52f83025d0b860e8c516667554081fa3d','GM gives its most important trucks a new UI—and includes CarPlay','The new look debuts in the 2027 Chevrolet Silverado and 2027 GMC Sierra pickup trucks.',NULL,'Ars Technica',1.0,'en',NULL,'2026-09-15T13:27:57+00:00','2026-09-16T19:40:38+00:00',26,44.7,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(27,'tech','https://arstechnica.com/science/2026/09/this-is-by-far-the-most-peaceful-atlantic-hurricane-season-weve-ever-seen/','8e938cf85b7c868dc618220a58b666781a4a70a3','This Atlantic hurricane season is about to do something that hasn''t happened in 175 years','But there may be a price to pay for a quiet Atlantic hurricane season.',NULL,'Ars Technica',1.0,'en',NULL,'2026-09-15T12:36:11+00:00','2026-09-16T19:40:38+00:00',27,44.3,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(28,'tech','https://arstechnica.com/ai/2026/09/exclusive-open-chinese-models-close-gap-with-silicon-valleys-frontier-ai-models/','3c126044b676be125f93a3b08cadc87acf996d01','Exclusive: Paying for frontier AI models buys 4-month head start at 5x the cost','Ars previewed Mozilla’s report on how cheap open models caught up on capability.',NULL,'Ars Technica',1.0,'en',NULL,'2026-09-15T12:00:41+00:00','2026-09-16T19:40:38+00:00',28,44.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(29,'tech','https://arstechnica.com/cars/2026/09/volvo-bigs-up-the-batteries-for-2028-xc60-and-xc90-plug-in-refresh/','62e7169918013df67d8ba76ba0e00514aaf877d0','Volvo increases the batteries for 2028 XC60 and XC90 plug-in refresh','The refreshed Volvos also get new infotainment systems with Gemini onboard.',NULL,'Ars Technica',1.0,'en',NULL,'2026-09-15T07:00:30+00:00','2026-09-16T19:40:38+00:00',29,41.5,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(30,'tech','https://arstechnica.com/space/2026/09/for-the-first-time-the-us-military-confirms-it-has-deployed-weapons-in-orbit/','6b841b3013124c2b1916e25af2e6f3a92d52bd0d','For the first time, the US military confirms it has deployed weapons in orbit','"The United States now has on-orbit space control weapons capable of defending the joint force."',NULL,'Ars Technica',1.0,'en',NULL,'2026-09-15T03:47:36+00:00','2026-09-16T19:40:38+00:00',30,40.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(31,'tech','https://techcrunch.com/2026/09/16/automattics-interim-ceo-and-legal-chief-signed-reciprocal-severance-deals-during-mullenwegs-brief-ouster/','7b801d80062c1e39de26a292b998e733f718c047','Automattic’s interim CEO and legal chief signed reciprocal severance deals during Mullenweg’s brief ouster','CFO Mark Davies and legal chief Andy Missan signed each other’s severance agreements while Matt Mullenweg was on leave, providing a year of salary and additional equity vesting if their departures qualify for the benefits.',NULL,'TechCrunch',0.9,'en',NULL,'2026-09-16T19:35:29+00:00','2026-09-16T19:40:39+00:00',31,55.8,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(32,'tech','https://techcrunch.com/2026/09/16/former-waymo-cfo-jumps-to-self-driving-startup-wayve/','dcd0fe8b06fcfa0a34e47945a32b6d06c7a0e894','Former Waymo CFO jumps to self-driving startup Wayve','Elisa de Martel, who left her position as chief financial officer at Alphabet''s autonomous vehicle company Waymo in January, will be based out of Silicon Valley.',NULL,'TechCrunch',0.9,'en',NULL,'2026-09-16T19:02:49+00:00','2026-09-16T19:40:39+00:00',32,55.5,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(33,'tech','https://techcrunch.com/2026/09/16/hear-why-science-corp-ceo-max-hodak-says-the-screen-era-is-ending-at-techcrunch-disrupt-2026/','d7b3812b8250d3b036ad33f6b90c4191b731aa5f','Hear why Science Corp CEO Max Hodak says the screen era is ending at TechCrunch Disrupt 2026','At this year''s Disrupt, Science Corp CEO Max Hodak will present a vision for screen-free interfaces that can even offer medical help. Register before September 25 to save up to $200 on your pass.',NULL,'TechCrunch',0.9,'en',NULL,'2026-09-16T18:45:35+00:00','2026-09-16T19:40:39+00:00',33,55.4,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(34,'tech','https://techcrunch.com/2026/09/16/ai-labs-want-in-house-auditors-but-maybe-they-should-shut-the-front-door-first/','454a368571e2edcfd3f61cfde1ff50d964a94afe','AI labs want in-house auditors — but maybe they should shut the front door first','There may be a simpler and more effective fix for rogue agents, hiding in plain sight.',NULL,'TechCrunch',0.9,'en',NULL,'2026-09-16T18:25:25+00:00','2026-09-16T19:40:39+00:00',34,55.2,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(35,'tech','https://techcrunch.com/2026/09/16/hackers-publish-thousands-of-drivers-data-after-breaching-florida-motor-vehicle-database/','bec238e6114cd50ed4f6fbf32c9697f96d379203','Hackers publish thousands of drivers’ data after breaching Florida motor vehicle database','The ShinyHunters gang leaked the files online after saying the Florida state agency did not pay their ransom demand.',NULL,'TechCrunch',0.9,'en',NULL,'2026-09-16T18:00:54+00:00','2026-09-16T19:40:39+00:00',35,55.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(36,'tech','https://techcrunch.com/2026/09/16/your-ai-agents-can-now-control-your-google-home-devices/','29b48237ac8b2eae380ad1a74d2e9d4c993b2ad5','Your AI agents can now control your Google Home devices','Google is launching early access to a new MCP server for Google Home, allowing AI agents like Claude, ChatGPT, and others to control connected devices, review camera summaries, and access smart home activity using natural language.',NULL,'TechCrunch',0.9,'en',NULL,'2026-09-16T17:00:00+00:00','2026-09-16T19:40:39+00:00',36,54.5,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(37,'tech','https://techcrunch.com/2026/09/16/anthropic-merges-claude-chat-and-cowork-in-one-interface/','15baa612d96c96309d4f2624141293111b6a6b40','Anthropic merges Claude chat and Cowork in one interface','Anthropic is initially releasing these features to Pro and Max plan subscribers.',NULL,'TechCrunch',0.9,'en',NULL,'2026-09-16T16:30:00+00:00','2026-09-16T19:40:39+00:00',37,54.3,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(38,'tech','https://techcrunch.com/video/how-fortell-is-using-ai-and-163m-to-crack-a-hearing-aid-monopoly/','6f7597974e3f9a7a242d01fee1ebca8d2d8d27d4','How Fortell is using AI (and $163M) to crack a hearing aid monopoly','“Why do I have to beg my grandparents to put on their hearing aids, but no one has ever needed to ask me to put on my glasses?”  That’s the question that drove Matthew de Jonge to spend six years building Fortell, an AI hearing aid startup that recently raised $163 million from the likes of Founders Fund, Thrive Capital, and Valor Equity […]',NULL,'TechCrunch',0.9,'en',NULL,'2026-09-16T16:00:00+00:00','2026-09-16T19:40:39+00:00',38,54.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(39,'tech','https://techcrunch.com/2026/09/16/may-mobility-is-going-public-in-a-1-4b-spac-deal/','1f1a74d00d9fef3181afefd938d9fdef03c03536','May Mobility is going public in a $1.4B SPAC deal','The deal could net the asset-light robotaxi company more than $300 million in funding.',NULL,'TechCrunch',0.9,'en',NULL,'2026-09-16T15:27:13+00:00','2026-09-16T19:40:39+00:00',39,53.7,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(40,'tech','https://techcrunch.com/2026/09/16/robots-are-waiting-for-a-chatgpt-moment-nvidias-les-karpas-explains-why-at-techcrunch-disrupt-2026/','26c48edc2eec52a30db0089d1d700758ab56b139','Robots are waiting for a ChatGPT moment: Nvidia’s Les Karpas explains why at TechCrunch Disrupt 2026','The robotics industry is still waiting for their breakthrough into day-to-day life. Nvidia''s Les Karpas has an answer as to why at TechCrunch Disrupt 2026. Register before September 25 to save up to $200 on your pass.',NULL,'TechCrunch',0.9,'en',NULL,'2026-09-16T15:00:00+00:00','2026-09-16T19:40:39+00:00',40,53.5,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(41,'tech','https://techcrunch.com/2026/09/16/google-says-some-pixel-phone-owners-were-hacked-in-zero-day-attacks/','d2990196de8d84c764285252262f5922a8688e4b','Google says some Pixel phone owners were hacked in zero-day attacks','The Pixel phone maker said there are indications that a bug in the phone''s modem "may be under limited, targeted exploitation."',NULL,'TechCrunch',0.9,'en',NULL,'2026-09-16T14:47:07+00:00','2026-09-16T19:40:39+00:00',41,53.4,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(42,'tech','https://techcrunch.com/2026/09/16/amazon-gives-its-workers-a-raise-of-1-per-hour/','c0d1a255ce5e0880b04035d81e5fb3a309362286','Amazon gives its workers a raise of $1 per hour','Amazon''s investment in these raises comes out to over $1.5 billion, or about 0.06% of its $2.68 trillion market cap.',NULL,'TechCrunch',0.9,'en',NULL,'2026-09-16T14:32:08+00:00','2026-09-16T19:40:39+00:00',42,53.3,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(43,'tech','https://techcrunch.com/2026/09/16/threads-new-features-let-podcasters-promote-shows-and-reach-listeners/','7da679bc9c36d9d6cc51e5a6d5828b364d9ec77b','Threads’ new features let podcasters promote shows and reach listeners','Threads is rolling out new tools for podcasters, including profile cards, episode links, transcripts, guest tags, posting reminders, and audience insights, as Meta looks to make the X rival a bigger hub for podcast promotion and discussion.',NULL,'TechCrunch',0.9,'en',NULL,'2026-09-16T14:24:58+00:00','2026-09-16T19:40:39+00:00',43,53.2,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(44,'tech','https://techcrunch.com/2026/09/16/next-wave-of-vcs-judging-startup-battlefield-200-contenders-at-techcrunch-disrupt-2026-revealed/','86c73b79cbce25830ada2059b8978a1f39d69694','Next wave of VCs judging Startup Battlefield 200 contenders at TechCrunch Disrupt 2026 revealed','Meet the next five top-tier investors judging the Startup Battlefield 200 contenders live at TechCrunch Disrupt 2026. Register before September 25 to save up to $200 and don''t miss a moment of the ultimate startup pitch competition.',NULL,'TechCrunch',0.9,'en',NULL,'2026-09-16T14:15:00+00:00','2026-09-16T19:40:39+00:00',44,53.1,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(45,'tech','https://techcrunch.com/2026/09/16/3-days-left-to-exhibit-at-techcrunch-disrupt-2026/','d21d6c6322c07bf9b3603b8b58cc7d079c58992d','3 days left to exhibit: Get your brand in front of VCs and high-value leads at TechCrunch Disrupt 2026','Last day to book your exhibit table at Disrupt is September 18. Three days left. Get your startup in front of 10,000+ founders, investors, operators, and tech leaders on October 13–15.',NULL,'TechCrunch',0.9,'en',NULL,'2026-09-16T14:00:00+00:00','2026-09-16T19:40:39+00:00',45,53.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(46,'tech','https://techcrunch.com/2026/09/16/sk-hynix-reportedly-in-talks-with-intel-to-build-memory-chips-in-us/','37581c176306f4567878c586d58ffc5debe4a717','SK Hynix reportedly in talks with Intel to build memory chips in US','SK Hynix told TechCrunch the company hasn''t finalized any plans or arrangements yet.',NULL,'TechCrunch',0.9,'en',NULL,'2026-09-16T13:23:02+00:00','2026-09-16T19:40:39+00:00',46,52.7,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(47,'tech','https://techcrunch.com/2026/09/16/former-infosys-chiefs-ai-startup-adds-50m-to-seed-weeks-after-initial-raise/','af1917c42c04c73bb59bddf77706d5dbe9229e41','Former Infosys chief’s AI startup nabs another $53M','The Palo Alto startup says it has landed multiple seven-figure enterprise contracts within months of launch.',NULL,'TechCrunch',0.9,'en',NULL,'2026-09-16T13:00:00+00:00','2026-09-16T19:40:39+00:00',47,52.5,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(48,'tech','https://techcrunch.com/2026/09/16/clean-tech-startup-fluxnium-found-a-way-to-tap-50000-years-worth-of-nuclear-fuel/','bb21c4c0801c18b8c61e031622dc46f50ad248c9','Clean tech startup Fluxnium found a way to tap 50,000 years’ worth of nuclear fuel','Fluxnium''s  fibers can extract uranium directly from seawater, which has enough of the nuclear fuel to power thousands of generations.',NULL,'TechCrunch',0.9,'en',NULL,'2026-09-16T13:00:00+00:00','2026-09-16T19:40:39+00:00',48,52.5,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(49,'tech','https://techcrunch.com/2026/09/16/amazon-launches-alexa-in-india-with-hindi-support/','f431efc80dbbbdeaeebe28e5b74892fffe30efea','Amazon launches Alexa+ in India with Hindi support','Amazon is letting all customers use Alexa+ assistant in early access period.',NULL,'TechCrunch',0.9,'en',NULL,'2026-09-16T10:34:47+00:00','2026-09-16T19:40:39+00:00',49,51.3,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(50,'tech','https://techcrunch.com/2026/09/15/we-dont-need-ai-regulation-leave-safety-to-us-nvidias-jensen-huang-says/','d2de68ab7234843d6ba1d94c3f324200357ba405','We don’t need AI regulation — leave safety to us, Nvidia’s Jensen Huang says','AI isn''t some new form of "alien mind," according to Jensen Huang. It''s just hardware and software, so safety can be engineered by each AI product maker.',NULL,'TechCrunch',0.9,'en',NULL,'2026-09-16T00:20:39+00:00','2026-09-16T19:40:39+00:00',50,46.2,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(51,'tech','https://www.xataka.com/cine-y-tv/familia-paul-walker-se-pronuncia-posible-regreso-actor-a-fast-furious-mediante-ia-que-meadow-desee','492e58e34160f946ab195b5aff9c1a0538e4f3ac','La familia de Paul Walker se pronuncia sobre el posible regreso del actor a ''Fast & Furious'' mediante IA: "Lo que Meadow desee"','Trece años después de su muerte, Paul Walker sigue siendo inseparable de la saga ''Fast & Furious''. Por eso no es de extrañar que su antiguo compañero de reparto, Vin Diesel, quiera traerlo de vuelta en la película final, ''Fast Forever'', sino que muchos quieran volver a verlo por última vez. La IA podría hacerlo realidad, pero con una condición
Ahora sí hay una vía: la IA. Existiría una posibilidad nueva de reencontrarse con Paul Walker en el próximo film de la saga. Su hermano Cody Walker acaba de explicar que la inteligencia artificial podría hacerlo realidad, como ya se ha visto en otras tantas ocasiones. Eso sí, con una condición.
"La IA no era nada en 2014". En una entrevista reciente con Entertainment Weekly, Cody Walker señaló que hoy existen vías y recursos para traer de vuelta a su hermano que hace más de diez años no existían: "La IA no era nada en 2014, hoy podrían hacerlo. Hay años de material de otras películas de ''Fast'' que nunca se usó. Son los mejores de la industria, pueden encontrar la manera".


 
     
                   
   
   
        Imagen | Espinof
   
   

La última palabra es de Meadow. Cody Walker, no obstante, no lo ve como algo que le corresponda decidir a él, sino a Meadow, la hija de Paul Walker: "Mi postura es que eso lo decide Meadow; es su padre. No tengo ningún interés en hacerlo. Me encanta cómo su personaje abandonó la franquicia. No lo mataron, no hicieron nada cursi. Es maravilloso que Brian esté criando a sus hijos. Pero si quieren [traerlo de vuelta], si Meadow lo desea, no me necesitan a mí ni a Caleb".
Cody y Caleb ya pusieron el cuerpo. Ambos ejercieron en el pasado de dobles de su hermano fallecido en ''Fast & Furious 7''. En 2018, los dos comentaron que se imaginaban regresando una vez más a la franquicia, pero parece que Cody habría cambiado de opinión.


 
  
   
    
     
    
   
   
    
     En Xataka
    
    En qué orden ver la saga ''Fast & Furious'': del cronológico al orden en el que fueron estrenadas y dónde verlas
   
  
 

Vin Diesel lleva tiempo empujando. El actor se ha pronunciado en varias ocasiones a favor de recuperar a Brian, el personaje de Paul Walker, en ''Fast Forever'' y reunirlo con su Dom una última vez. Si eso sucederá de verdad, y si la IA tendrá algo que ver, es algo que habrá que seguir esperando para saber.

Cuándo llega ''Fast Forever''. Hasta que la película se estrene en cines todavía queda un buen rato: está programado para el 16 de marzo de 2028. Mientras tanto, siempre es buen momento para revisitarlas todas. En particular, la primera, la segunda y la tercera. Son las mejores y de esta burra no me baja nadie. 

Vía | moviepilot.de

Imagen | Espinof

En Xataka | 17 icónicos vehículos del cine y la TV en 45 fotos: así será la exposición de coches de ciencia ficción más grande en la historia


                 -  La noticia
      
        La familia de Paul Walker se pronuncia sobre el posible regreso del actor a ''Fast & Furious'' mediante IA: "Lo que Meadow desee"  
      
      fue publicada originalmente en
      
        Xataka 
      
             por 
               
        Jose García
        
             .',NULL,'Xataka',0.9,'es',NULL,'2026-09-16T19:00:13+00:00','2026-09-16T19:40:39+00:00',51,55.5,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(52,'tech','https://www.xataka.com/moviles/samsung-comienza-a-desplegar-one-ui-9-android-17-eso-habra-que-tener-algo-paciencia','bf041c21e55572b17e70601b95c1b26c53961dfb','Samsung comienza a desplegar One UI 9 sobre Android 17. Eso sí: habrá que tener algo de paciencia','Las cosas de palacio van despacio y las actualizaciones de Android, a veces, también. Sin embargo, Samsung ha pillado carrerilla estos últimos años actualizando a la nueva versión de Android no sólo bastante rápido, sino también con una generosa lista de móviles compatibles. 

La última es One UI 9 sobre Android 17, versión que tuvimos de serie en los plegables como el Galaxy Z Fold 8, que ahora inicia su despliegue al resto de la familia.

A continuación, vamos con las principales novedades de One UI 9, los Samsung compatibles y los tiempos, ya que aunque ahora comience el despliegue, puede que tarde unos días en llegar a tu dispositivo.

Las funciones de One UI 9Como es habitual, una nueva versión de software llega con algunos cambios visuales y en animaciones. Con Android 17, también aseguramos las últimas mejoras en cuanto a seguridad (que se unen a Nox en muchos modelos de Samsung), pero el protagonismo absoluto de esta versión recae en la IA.

Porque hay mucha, muchísima IA que impregna prácticamente todas las novedades del sistema. Por un lado, lo realmente nuevo:

My FanCam: se trata de una función que identifica y sigue automáticamente a una persona elegida dentro de un vídeo ya grabado, ajustando el encuadre de manera inteligente conforme cambia la escena, de forma que los momentos con movimiento se transformen en contenido listo para compartir en redes sociales sin apenas necesidad de editar. Un ejemplo es la actuación de un amigo bailando o la de un jugador dentro de un partido.Now Brief ahora permite personalizar el contenido de los resúmenes diarios gracias a tarjetas generativas. Podemos añadir tarjetas de salud o clima para adaptar mejor el resumen a aquello que nos interesa de verdad.Ajustes ahora tiene un apartado de "Garantía y cuidado" que centraliza el soporte del dispositivo. Desde ahí, podemos revisar la cobertura de la garantía de los dispositivos móviles vinculados, hacer un diagnóstico, ver la estimación del coste de reparación, gestionar Samsung Care+ o pedir asistencia oficial.
 
  
   
    
     
    
   
   
    
     En Xataka
    
    Samsung ha demostrado en IFA 2026 que la guerra ya no es por el dispositivo del hogar: es por hacerse con todo el ecosistema 
   
  
 

También hay cambios y novedades en funciones que ya estaban disponibles:
Now Nudge: ahora ofrece información y sugerencias más contextuales. Por ejemplo, la organización de planes de un chat, que ahora nos permite guardar desde ahí mismo una ubicación o consultar detalles de una reserva en un restaurante, por ejemplo.Estudio Creativo: cuando la app se da cuenta de que se acerca una efeméride como puede ser un cumpleaños de un contacto, Estudio Creativo sugiere la creación de una imagen o una felicitación. Intérprete: se ha mejorado el modo de conversación para que sea más fluido gracias a traducciones más rápidas. Si además tenemos unos Galaxy Buds compatibles, la reproducción de audio es más ágil para que la conversación tenga menos pausas y el diálogo sea más natural. Además, ahora tendrá una ''memoria'' para ver conversaciones pasadas.Escaneado de documentos: han añadido mejoras al escaneado de documentos como esas páginas curvadas en libros o de hojas con las esquinas dobladas. Además, se ha mejorado la función de borrado de dedos para que el escaneo sea más limpio.Grabadora de voz: los resúmenes de las notas de voz ahora se organizan de otra forma, con tablas y encabezados que permiten localizar de un vistazo la información más importante. 
 
                   
   
   
      

Por otro lado, también hay mejoras en seguridad:

Now Brief ahora tiene Security Brief, que reúne información sobre seguridad y privacidad como avisos de malware, apps de origen desconocido o esas apps que piden demasiados permisos para funcionar. De esta forma, el usuario está más informado sobre los posibles riesgos y puede tomar medidas.Alertas de privacidad mejoradas que detectan posibles amenazas, como pueden ser permisos en segundo plano.Muchas de estas funciones necesitan, eso sí, cuenta en Samsung y algunas estarán disponibles dependiendo del país. Por ejemplo, Samsung detalla que la cobertura, precio y requisitos de Samsung Care+ dependen tanto de país, la región y que en algunos casos se aplicarán tarifas de servicio.

Samsung compatibles con One UI 9Como decimos, hoy empieza el despliegue del nuevo sistema, pero habrá que tener algo de paciencia. De momento, Samsung comienza con los Galaxy S26 y toda la familia para, posteriormente, aplicarlo al resto del ecosistema. Y es posible que aún pasen unos días hasta que veas aparecer la actualización en tu S26.

Dicho esto, te dejamos todos los móviles de las series S, Z, A y tablets que recibirán antes o después One UI 9:

Serie SGalaxy S25 UltraGalaxy S25+Galaxy S25Galaxy S25 EdgeGalaxy S25 FEGalaxy S24 UltraGalaxy S24+Galaxy S24Galaxy S24 FEGalaxy S23 UltraGalaxy S23+Galaxy S23Galaxy S23 FESerie AGalaxy A57 5GGalaxy A56Galaxy A55Galaxy A37 5GGalaxy A36Galaxy A35Galaxy A26Galaxy A25Galaxy A17Galaxy A16Galaxy A15Galaxy A07Galaxy A06Serie ZGalaxy Z Fold7Galaxy Z Flip7Galaxy Z Flip 7 FEGalaxy Z Fold6Galaxy Z Fold Special EditionGalaxy Z Fold5Galaxy Z Flip6Galaxy Z Flip5Galaxy TabGalaxy Tab S11 UltraGalaxy Tab S11Galaxy Tab S10 UltraGalaxy Tab S10 FE+Galaxy Tab S10 LiteGalaxy Tab S9 UltraGalaxy Tab S9+Galaxy Tab S9Galaxy Tab S9FE+Galaxy Tab S9 FEY te recordamos que, aunque One UI 9 esté llegando ahora, nuestros compañeros de Xataka Móvil ya están indagando en la siguiente versión: One UI 9.5.

En Xataka | Samsung Galaxy Watch Ultra2, análisis: quería un reloj Android para todo y he acabado encontrando uno casi perfecto para hacer deporte


                 -  La noticia
      
        Samsung comienza a desplegar One UI 9 sobre Android 17. Eso sí: habrá que tener algo de paciencia  
      
      fue publicada originalmente en
      
        Xataka 
      
             por 
               
        Alejandro Alcolea
        
             .',NULL,'Xataka',0.9,'es',NULL,'2026-09-16T18:16:11+00:00','2026-09-16T19:40:39+00:00',52,55.1,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(53,'tech','https://www.xataka.com/medicina-y-salud/ultima-moda-para-ligar-dejar-ducharse-ciencia-tiene-malas-noticias-para-sus-defensores','0ba74822c7b2c7d288d13422c99650004a79db7a','La última moda para ligar es dejar de ducharse. La ciencia tiene malas noticias para sus defensores','Las redes sociales siempre traen algo que no dejan de sorprendernos, y lo último está puesto en la higiene personal y en su interferencia a la hora de ligar con otras personas. Esto es lo que se llama "pheromone maxxing" y este concepto lo que plantea es la necesidad de dejar de ducharse, abandonar el desodorante y dejar que nuestro sudor haga el trabajo de atraer a una posible pareja a través de nuestras irresistibles feromonas. 

Esta es una idea que ha sido recientemente abordada por The Conversation, donde se hacen la pregunta sobre si tiene algún apoyo científico el hecho de que no ducharse aumenta la cantidad de feromonas y atraerá a mucha gente. Y la realidad es que no hay pruebas al respecto de esto, quedando este fenómeno como un movimiento que ha nacido en redes sociales ''porque si''. 

Las feromonas. Cuando pensamos en este término, automáticamente nos vamos hacia el mundo de los animales. Y es que en la naturaleza una feromona no es más que una señal química que provoca una respuesta fija, automática y estereotipada en todos los miembros de una especie, como ocurre en las polillas. 

Pero... ¿Esto lo tenemos los humanos? Y la respuesta es que no. Si concretamos un poco más, nos encontramos dentro de la evidencia fisiológica con que el órgano vomeronasal humano, que es la estructura que en otros animales detecta esta señal, no es funcional en adultos. Es un remanente anatómico que no está conectado de forma operativa a nuestro cerebro. 


 
  
   
    
     
    
   
   
    
     En Xataka
    
    Ligar en Tinder es agotador. La solución de estas apps es saltarse los chats eternos y organizarte la cita directamente
   
  
 

Algo parecido. Si queremos tener algo similar en nuestro cuerpo, hay algunos candidatos, como por ejemplo el estratetraenol. Pero estos no tienen un efecto en nuestro comportamiento significativo, y está muy alejado de las respuestas casi automáticas de atracción sexual que promete internet. 

Las camisetas sudadas. Si no hay ninguna evidencia científica que respalde el efecto de las ''feromonas'' humanas, la pregunta es prácticamente obligatoria: ¿de dónde sale esta creencia de que el sudor atrae a terceras personas? Pues la culpa la tiene un experimento de los años 90 donde se pidió a un grupo de mujeres que oliera camisetas usadas durante varios días por hombres. 

Aquí se descubrió que las mujeres preferían el olor de aquellos hombres que contaban con un MHC diferente al suyo. Esto quiere decir que a las mujeres les atraía el olor de las personas que contaban con un sistema inmune "distinto" al nuestro para garantizar una descendencia más resistente. Sin embargo, con el paso del tiempo se vio que estos estudios tenían muestras pequeñas, con métodos muy limitantes y, sobre todo, medían una "preferencia de olor" indirecta en un laboratorio, no la elección de pareja en el mundo real. 

El golpe de gracia. Para poder desmentir este fenómeno, nos tenemos que fijar en un estudio publicado en 2020, donde los investigadores integraron muchas fuentes para enfatizar que no hay un efecto significativo en la satisfacción de la relación cuando se busca una complementariedad a través del olfato y el sudor. 

El problema es que durante décadas los estudios encontraban un vínculo exótico entre genes y olor que se usaba para publicar rápidamente, aunque en realidad no había nada de fondo. 


 
  
   
    
     
    
   
   
    
     En Xataka
    
    Hoy ligamos con el móvil, pero en 1930 el Tinder era tu prima: este gráfico revela cómo hemos encontrado pareja desde entonces 
   
  
 

El jabón sigue siendo lo mejor. En definitiva, al cruzar toda la literatura científica disponible, la imagen que nos encontramos es que dejar de ducharse no te convierte en un imán biológico. De esta manera, no hay demostración de una feromona sexual humana infalible que permita crear un vínculo perfecto o que alguien literalmente se "derrita" por tus huesos. De hecho, lo que si se sabe es que el mal olor asociado al sudor acumulado si que puede resultar muy aversivo y no atractivo para muchas personas. 

Imágenes | Katerina Holmes

En Xataka | Las mejores 17 aplicaciones para ligar, tener citas o encontrar tu media naranja


                 -  La noticia
      
        La última moda para ligar es dejar de ducharse. La ciencia tiene malas noticias para sus defensores  
      
      fue publicada originalmente en
      
        Xataka 
      
             por 
               
        José A. Lizana
        
             .',NULL,'Xataka',0.9,'es',NULL,'2026-09-16T18:00:13+00:00','2026-09-16T19:40:39+00:00',53,55.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(54,'tech','https://www.xataka.com/seleccion/mejores-auriculares-dormir','7b10679821fbdc54d687f5aaa2750e8213e14efa','Mejores auriculares para dormir 2026. Cuál comprar y 6 modelos recomendados','Mucha gente ha pasado por épocas en las que les es complicado conciliar el sueño, especialmente cuando suele haber ruidos externos. No importa que sea el paso de los coches o los ronquidos de su pareja. Sea como sea, no logran dormirse. Lo bueno es que existen wearables pensados para ayudarnos en estas situaciones, como es el caso de los auriculares para dormir. Este tipo de dispositivos no solo está pensado para aislarnos del ruido, sino para ofrecer funciones orientadas a facilitar el sueño. Nuestra opción favorita son los Soundcore Sleep A30 de Anker, aunque hay otras opciones que también son muy interesantes. 



 
  
 
     
   
  
   Soundcore Auriculares Sleep A30 de Anker: con Cancelación Activa de Ruido, Sistema Adaptativo para Bloquear los Ronquidos, Máxima Comodidad para Quienes Duermen de Lado y 45h de Reproducción
   
         
             

      PVP en Powerplanet —       159,95 €
 
                      

       MediaMarkt —       236,42 €
 
                

       Amazon —       249,53 €
 
                

       Anker —       249,99 €
 
              
           
  
 
 El precio podría variar. Obtenemos comisión por estos enlaces


Estos auriculares inalámbricos ofrecen todo lo que podemos esperar de un dispositivo orientado a dormir. Muchos auriculares in-ear se acaban clavando cuando nos echamos de lado en la cama. Soundcore ha querido evitar esto con su perfil delgado y con una silicona suave. Además, como se puede esperar de este tipo de dispositivos, ofrece cancelación de ruido activa para evitar escuchar el ruido del exterior. Lo que nos sorprende es el nivel de personalización que ofrece, gracias a su sistema adaptativo. 
Como decíamos, estos auriculares no solo servirán para aislarnos del ruido. También cuentan con una biblioteca de sonidos con más de 40 pistas para inducir a la relajación. Además, también son capaces de hacer un seguimiento de nuestro sueño, el cual podemos ver a través de la app de Soundcore. 


 
  
   
    Índice de Contenidos (12)
   
   
  
 
 
  
   
               
       Los destacados
      
                    
       Por qué destacan
      
                    
       Otras opciones a considerar
      
                    
       Configuraciones y extras
      
                    
       Preguntas frecuentes
      
                    
       ¿Puedo usar mis auriculares normales (como unos AirPods) para dormir? 
      
                    
       ¿Escucharé el despertador si los llevo puestos? 
      
                    
       ¿Cómo se lavan los modelos que son de tela o diadema? 
      
                    
       ¿Es malo para mis oídos escuchar ruido blanco toda la noche? 
      
                    
       ¿Es peligroso tener el Bluetooth encendido cerca de la cabeza toda la noche? 
      
                    
       ¿Se apagan solos o suenan toda la noche? 
      
                    
       Recomendación final
      
            
  
 
Los destacados
 
  
       
        
                 
       Modelos
      
                 
       
      
                 
       Perfecto para ti
      
                 
       Lo mejor
      
                 
       Lo peor
      
                 
       Precio desde
      
    
 
    
      
          
                 
       Soundcore Sleep A30
      
                 
                        
     
          
                 
       Si duermes en zonas muy ruidosas o con una persona que ronque mucho. 
      
                 
       Su sistema triple de reducción acústica. 
      
                 
       Su precio es el más elevado de la lista. 
      
                 
       159,95 €
      
    
   
                 
       
Fulext Auriculares para Dormir
      
                 
                        
     
          
                 
       Si no te gusta llevar auriculares in-ear y buscas una opción económica. 
      
                 
       Su banda elástica ofrece una experiencia muy cómoda. 
      
                 
       No cuenta con sistema de reducción de ruido. 
      
                 
       21,99 €
      
    
   
                 
       MINISO MS217
      
                 
                        
     
          
                 
       Si buscas un modelo tipo botón económico para saber si puedes aprovechar este tipo de auriculares. 
      
                 
       Su tamaño y diseño. 
      
                 
       La calidad de sonido es algo más básica. 
      
                 
       13,75 €
      
    
   
                 
       Soundcore Sleep A20
      
                 
                        
     
          
                 
       Si buscas un dispositivo que te garantice sonidos relajantes toda la noche. 
      
                 
       Su batería. 
      
                 
       No incluye un sistema de cancelación total. 
      
                 
       92,99 €
      
    
   
                 
       Voerou auriculares para dormir
      
                 
                        
     
          
                 
       Si eres de dar muchas vueltas en la cama y buscas algo con lo que hacer ejercicio. 
      
                 
       Sus altavoces estéreo ultrafinos. 
      
                 
       Tampoco ofrece aislamiento total. 
      
                 
       22,99 €
      
    
   
                 
       HoomBand auriculares para dormir
      
                 
                        
     
          
                 
       Si buscas un modelo que se apoye mucho en el software dedicado. 
      
                 
       La aplicación dedicada de la marca. 
      
                 
       El tejido puede dar un poco de calor durante el verano. 
      
                 
       69,00 €
      
    
 
      
  
 

Por qué destacan
Cuando buscamos los mejores auriculares inalámbricos, lo más importante es que ofrezcan un sonido de alta calidad. En este caso, lo más importante es que se trate de dispositivos que logren aislarnos del ruido en las mejores condiciones posibles. No obstante, hay otras características que debemos tener en cuenta de forma previa. A continuación, te contamos las más relevantes. 


 
                   
   
   
      

Cancelación de ruido. Como acabamos de comentar, el factor más determinante a la hora de buscar unos auriculares inalámbricos es que cuenten con cancelación de ruido. La cancelación puede ser pasiva o activa. La primera depende casi en exclusiva de la forma de los auriculares, que nos aíslan de manera física del ruido. Básicamente, se trata de un aislamiento acústico físico, como el que ofrecen los tapones para dormir. La segunda, por su parte, se trata de una tecnología electrónica. Mediante la incorporación de pequeños micrófonos, el procesador interno de los auriculares analiza el sonido en tiempo real y genera una onda sonora exactamente opuesta, con la que se produce un choque. Al producirse esto, el ruido se cancela por completo. 
La cancelación activa de ruido es la opción más recomendada. Especialmente porque es capaz de adaptarse a ruidos graves y continuos, que son los que más molestias pueden causarnos al dormir. Pero también porque la mayoría de modelos que incorporan esta tecnología también cuentan con cancelación pasiva, la cual está pensada para ruidos agudos e irregulares. De modo que ofrece una experiencia completa para tratar de descansar. 
Diseño. El diseño es el segundo factor clave que debemos valorar antes de apostar por unos auriculares de este tipo. Por muy buena cancelación de ruido (pasiva o activa) que ofrezcan los auriculares, serán totalmente incompatibles para conciliar el sueño si se nos clavan al dormir. Para ello, es fundamental que su diseño sea más compacto que el de los auriculares tradicionales. Existen dos tipos de diseño para estos dispositivos: 
Diseño de diadema: No nos referimos a los clásicos auriculares de diadema que utilizamos para escuchar música o jugar. Se trata, literalmente, de diademas que incorporan unos pequeños altavoces para poder escuchar música o sonidos de relajación. Además, al colocarlas encima de las orejas, ofrecen un pequeño aislamiento del ruido. Diseño in-ear: La apariencia de estos auriculares es muy parecida a la de los modelos clásicos para escuchar música. Sin embargo, apuestan por un tamaño más reducido para que no sean incómodos de utilizar mientras estamos acostados. 
Autonomía. Al ser dispositivos que utilizaremos para dormir, es importante que cuenten con una autonomía lo suficientemente elevada como para garantizar su uso durante nuestras horas de sueño. Los modelos con cancelación activa de ruido suelen contar con un mayor consumo, por lo que es importante echar un vistazo a las horas que asegura el fabricante. Aunque quizás no nos haga falta hacer uso de ella durante toda la noche, lo recomendable es que al menos sean capaces de durar unas 5-6 horas con ella activa. 
Sonido. Aunque no le damos la misma importancia que a los auriculares TOP, ya que hacemos la inversión, es importante que sean modelos que ofrezcan un buen sonido. De este modo también podremos aprovecharlos a lo largo del día, ya sea para escuchar música, un podcast o reproducir algún capítulo de Netflix con ellos puestos. 
Otras opciones a considerar
 
                    
         
    
     
 
      

Fulext Auriculares para Dormir. Es una banda para dormir que destaca por su buena relación calidad-precio. Por un precio bastante ajustado, nos encontramos con un modelo con diadema elástica muy cómoda. Integra auriculares con micrófono y conectividad Bluetooth 5.0 para que conectes tu móvil y escuches lo que te ayude a conciliar el sueño, ya sea un audiolibro, música relajante o un podcast.



 
  
 
     
   
  
   Fulext Auriculares para Dormir Bluetooth Deportes Diadema Deportiva Auriculares con HD Estéreo Altavoces para DeportesDormir de Lado y Relajación (Morado)
   
         
             

      Hoy en Amazon —       21,99 €
 
                    
           
  
 
 El precio podría variar. Obtenemos comisión por estos enlaces



 
                    
         
    
     
 
      

MINISO MS217. Se trata de una alternativa económica perfecta para probar los auriculares in-ear para dormir. Cuentan con un diseño de botón que se ajusta a la perfección al oído para que no sean molestos al usarlos cuando estamos echados. Ayudan a bloquear sonidos como ronquidos gracias a su diseño, que isla pasivamente dle ruido. Tan solo pesan 3 gramos y ofrecen una batería de 7 horas. 



 
  
 
     
   
  
   MINISO MS217 Auriculares para Dormir, Auriculares Traductores, Blanco
   
         
             

      PVP en AliExpress —       13,75 €
 
                      

       Amazon —       39,99 €
 
              
           
  
 
 El precio podría variar. Obtenemos comisión por estos enlaces



 
                    
         
    
     
 
      

Soundcore Sleep A20. En el caso de buscar un modelo de mayor calidad, Anker ha incluido en estos auriculares un sistema de enmascaramiento de ruido de 4 puntos. Esto incluye almohadillas de doble sellado para ofrecer un mayor aislamiento pasivo, control inteligente del volumen y unos transductores que enmascaran el ruido. Hace un seguimiento de nuestras horas de sueño y tiene una autonomía de hasta 14 horas con una carga completa, y 80 horas con el estuche de carga. 



 
  
 
     
   
  
   Soundcore Sleep A20
   
         
             

      PVP en Powerplanet —       92,99 €
 
                      

       Carrefour —       140,71 €
 
                

       Amazon —       149,99 €
 
                

       PcComponentes —       149,99 €
 
                

       MediaMarkt —       154,60 €
 
              
           
  
 
 El precio podría variar. Obtenemos comisión por estos enlaces



 
                    
         
    
     
 
      

Voerou Auriculares para Dormir. Se trata de una sencilla banda mullida y suave que destaca por su autonomía de hasta 10 horas de reproducción. Es absorbente, lavable y cómoda, además de poder ser utilizada como antifaz. Además, cuenta con una correa ajustable para evitar que se mueva accidentalmente.



 
  
 
     
   
  
   Voerou Auriculares Bluetooth 5.4 para Dormir, Auriculares Inalámbricos con Altavoces Ultrafina y Estéreo, Auriculares para Dormir para Entrenamiento, Correr, Yoga y Meditación, Dispositivos
   
         
             

      Hoy en Amazon —       22,99 €
 
                    
           
  
 
 El precio podría variar. Obtenemos comisión por estos enlaces



 
                    
         
    
     
 
      

HoomBand auriculares para dormir. De nuevo, estamos ante una banda elástica. En este caso, podemos encontrarla en dos tallas diferentes y en una versión conectada o inalámbrica. Ambos modelos están fabricados en un tejido flexible y cómodo con espuma termoformada, donde se incluyen unos auriculares ultraplanos. Es ideal para escuchar música gracias a su calidad de audio HD, y además ofrece más de 100 horas de meditaciones guiadas y contenido creado por especialistas de sueño. 



 
  
 
     
   
  
   HoomBand | Auriculares Bluetooth para dormir | Diadema para dormir, viajes, meditación | Acceso gratuito a historias hipnóticas y sonidos creados por expertos en sueño | Cable de carga incluido
   
         
             

      Hoy en Amazon —       69,00 €
 
                    
           
  
 
 El precio podría variar. Obtenemos comisión por estos enlaces


Configuraciones y extrasJunto a las características que hemos mencionado más arriba, hay otra serie de aspectos que también debemos tener en consideración. Sobre todo si, además de para dormir, queremos utilizar los auriculares durante el resto del día. 

Drivers. Son los altavoces que se incluyen dentro de los auriculares. Por regla general, tener unos drivers de mayor tamaño implica tener un mejor sonido. Aunque en este tipo de auriculares es complicado encontrar modelos de gran tamaño, dado que se trata de dispositivos muy compactos. Podemos encontrar drivers de entre 6 y 13 mm. 

Códecs de sonido. Son los algoritmos de codificación que se usan para transmitir el sonido. Lo recomendable es contar con algunos como aptX o LDAC, ya que sirven para ofrecer una mejor experiencia en la transmisión de audio en streaming y en la reproducción de sonido de alta calidad. 

Sensibilidad. Esto nos señala cuán fuerte puede llegar a sonar el auricular con un nivel de energía determinado. Se mide en decibelios de presión sonora por milivatio. Cuanto menor sea la sensibilidad, mayor tendrá que ser la energía utilizada para alcanzar cierto volumen. Esto puede dar lugar a que el sonido máximo del auricular no sea demasiado alto, además de afectar al consumo. Lo aconsejable es que cuente con, al menos, 90 dB. 

Ausencia de luces. Al ser auriculares pensados para dormir, es importante que sean modelos con un diseño sobrio. Hay que prescindir de aquellos modelos con luces, pantallas o cualquier otro elemento interactivo que pueda molestarnos mientras tratamos de conciliar el sueño. 

Preguntas frecuentes¿Puedo usar mis auriculares normales (como unos AirPods) para dormir? Poder puedes, pero no es lo ideal. Los auriculares estándar son rígidos y, si duermes de lado, terminarán clavándose en el cartílago y causándote dolor. Además, es muy fácil que se salgan, se pierdan entre las sábanas o incluso se estropeen si los aplastas con el peso de la cabeza.

¿Escucharé el despertador si los llevo puestos? Sí. De hecho, es una de sus grandes ventajas. Si la alarma suena en tu móvil, el audio se transmitirá por los auriculares. Muchos modelos premium incluso tienen su propia alarma integrada en la app. Así te despiertas tú sin sobresaltar a la persona que duerme a tu lado.

¿Cómo se lavan los modelos que son de tela o diadema? Casi todos los modelos tipo cinta están diseñados para lavarse fácilmente. Tienen una pequeña ranura por donde puedes extraer el módulo Bluetooth y los altavoces ultraplanos. Una vez vacía, la cinta de tela se puede lavar a mano o en la lavadora sin problema.

¿Es malo para mis oídos escuchar ruido blanco toda la noche? No, siempre y cuando mantengas un volumen seguro. Los expertos recomiendan mantener el sonido a un volumen moderado: lo justo para enmascarar el ruido exterior, pero sin que resulte fuerte. Muchos auriculares específicos para dormir limitan el volumen máximo precisamente para proteger tu salud auditiva a largo plazo.

¿Es peligroso tener el Bluetooth encendido cerca de la cabeza toda la noche? No hay de qué preocuparse. Estos dispositivos utilizan tecnología Bluetooth, que emite un nivel de radiación no ionizante minúsculo (muchísimo menor que el de un teléfono móvil buscando cobertura o el router del WiFi). Son completamente seguros para un uso continuo.

¿Se apagan solos o suenan toda la noche? Depende de lo que tú prefieras. La mayoría de aplicaciones de estos auriculares incluyen un temporizador. Puedes programarlos para que el sonido de lluvia o ruido blanco se apague a los 30 o 60 minutos, justo cuando calcules que ya estarás profundamente dormido, ahorrando así batería.

Recomendación finalComo hemos visto, hay opciones variadas y bastante diferentes entre sí. Sin embargo, si buscamos los mejores auriculares para dormir, no cabe duda de que nuestra recomendación serían los Soundcore Sleep A30. Su diseño es perfecto para que podamos utilizarlos por la noche sin que nos molesten. Además, ofrece una calidad de sonido fantástica para darle un uso tradicional. 



 
  
 
     
   
  
   Soundcore Auriculares Sleep A30 de Anker: con Cancelación Activa de Ruido, Sistema Adaptativo para Bloquear los Ronquidos, Máxima Comodidad para Quienes Duermen de Lado y 45h de Reproducción
   
         
             

      PVP en Powerplanet —       159,95 €
 
                      

       MediaMarkt —       236,42 €
 
                

       Amazon —       249,53 €
 
                

       Anker —       249,99 €
 
              
           
  
 
 El precio podría variar. Obtenemos comisión por estos enlaces


Incluye un sistema de cancelación de ruido activa de mucho nivel, que además se potencia gracias al enmascaramiento adaptativo que ofrece su estuche de carga, que se encarga de monitorizar y analizar ruidos como ronquidos, para que posteriormente los auriculares se encarguen de silenciarlos por completo. 

Además, es un dispositivo cargado de opciones de audio para relajarnos y favorecer que conciliemos el sueño lo más rápido posible. Pero lo mejor es que es capaz de individualizar el sonido dependiendo del uso que le demos. Suponen una inversión bastante elevada, pero no se nos ocurre una mejor opción para evitar los ruidos cuando nos metamos en la cama. 

Nota: algunos de los enlaces aquí publicados son de afiliados. A pesar de ello, ninguno de los artículos mencionados han sido propuestos ni por las marcas ni por las tiendas, siendo su introducción una decisión única del equipo de editores.

Imágenes | Soundcore, Voerou, Hoom, Miniso, Fulext, Abhishek Shintre en Unsplash

En Xataka | Mejores auriculares verdaderamente inalámbricos (TWS) con cancelación de ruido. Cuál comprar y siete modelos recomendados

En Xataka | Mejores auriculares inalámbricos de diadema. Cuál comprar y cinco modelos recomendados


                 -  La noticia
      
        Mejores auriculares para dormir 2026. Cuál comprar y 6 modelos recomendados 
      
      fue publicada originalmente en
      
        Xataka 
      
             por 
               
        Fran San Nicolás
        
             .',NULL,'Xataka',0.9,'es',NULL,'2026-09-16T17:46:11+00:00','2026-09-16T19:40:39+00:00',54,54.9,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(55,'tech','https://www.xataka.com/magnet/este-piso-ibiza-se-vende-a-mitad-precio-hay-problema-nadie-puede-entrar-a-verlo','0074a4d85bbb11d01e9bc18a361a324ec4ab4679','Este piso de Ibiza se vende a mitad de precio, pero hay un problema: nadie puede entrar a verlo','¿Cómo se venden los pisos ocupados y qué riesgo asume quien los compra? Hay quien cree que adquirirlos es como intentar comprar una casa encantada, solo que el fantasma tiene DNI, no paga ni la hipoteca ni la comunidad. El comprador firma ante notario un derecho de propiedad que, en la práctica, no vale hasta que un juez ordene el desalojo. Y nadie puede decirle cuándo llegará ese día.

Es lo que le ha pasado a una familia de Madrid con un piso en San Agustín–Cala de Bou, en Ibiza. Así que han tomado una decisión: sacarlo a la venta por 350.000 euros, casi la mitad de lo que valdría vacío, porque dentro vive una okupa desde 2018. El requisito: nadie puede visitarlo.

El chollo. El piso son 73 metros cuadrados, dos habitaciones, terraza de 15 m², garaje incluido, vistas al mar y ascensor hasta la tercera planta. Salió al mercado por 390.000 euros y ya ha bajado a 350.000, un 10% menos. En un lugar donde hay masías de casi 7 millones, no está nada mal. La propia inmobiliaria calcula que, libre de okupación, rondaría los 600.000 euros. Cualquier oferta se hace a ciegas, sin pisar el interior, guiándose solo por fotos y por la palabra de la agencia.

A pocos kilómetros de Cala de Bou, otro piso ibicenco repite el guion: vivienda ocupada en Santa Eulària por 465.000 euros. Son 70 metros, dos habitaciones, terraza, jardín y garaje incluido, a 6.643 euros el metro cuadrado, más caro por metro que el piso de Cala de Bou pese a tener menos superficie. La ficha lo etiqueta tal cual como ocupado, aunque destaca las "magníficas puestas de sol". El anuncio también desglosa las dos vías para recuperar la posesión: demanda civil de desahucio, de 6 meses a un año, o casi inmediata si el ocupante nunca tuvo título; y la vía penal por usurpación, con pena de uno a dos años si media violencia.


 
  
   
    
     
    
   
   
    
     En Xataka
    
    Un pueblo de Toledo se ha cansado de los okupas. Así que está ofreciendo un nuevo servicio a sus vecinos para echarlos
   
  
 

Ocho años de pacto. Los dueños usaban el piso como segunda residencia de verano. Quien lo ocupó en 2018 fue, según la inmobiliaria, la propia persona que limpiaba la casa, y ahí sigue. En vez de ir a juicio, firmaron con ella un contrato: se compromete a marcharse el día que el piso se venda. "Cuesta un poco creérselo", dice el agente. Conviene recordar que no es lo mismo okupación de allanamiento.

24.000 pisos. Idealista contabilizó 24.058 viviendas okupadas en venta en España solo en el último trimestre de 2025, un 4,6% más que tres meses antes, y el 40% concentradas en Cataluña. Girona es la provincia clave: el 8,8% de los pisos en venta están ocupados, por delante de Murcia (5,5%) y Sevilla (4,7%). Y el origen de la mayoría se remonta a la crisis de 2008-2014: la banca empaquetó hipotecas impagadas en lotes de cientos de pisos, con o sin okupas, y los vendió a fondos de inversión, que ahora sacan al mercado uno a uno.

Descuentos de hasta el 74%. El recorte de precio varía muchísimo según la ciudad. En Sevilla, un piso de 90 metros que valdría 168.570 euros libre se vende ocupado por 57.150: un 66% menos, con el precio por metro cuadrado cayendo hasta un 74% en los casos más extremos. En Madrid, la rebaja media ronda el 58-66%. La horquilla nacional se mueve entre el 40% y el 60%, siempre por debajo del valor real de mercado.


 
  
   
    
     
    
   
   
    
     En Xataka
    
    En Zaragoza, una inquilina dejó de pagar el alquiler, se hizo okupa y consiguió que la propietaria le pagara 1.000 euros de agua
   
  
 

La excepción. En Baleares ocurre justo lo contrario. La escasez de vivienda es tan brutal que casi no quedan pisos (okupados o no) en venta: solo 442 en todo el archipiélago a finales de 2025, un 6,8% menos que el trimestre anterior. Y los precios se han disparado: lo que en 2023 costaba entre 25.000 y 100.000 euros, hoy vale el doble, entre 50.000 y 200.000. Hay nuevas construcciones que alcanzan los 1,4 millones de euros. En Mallorca, una propietaria anunció la venta de su piso ocupado con un cartel casero durante la Cabalgata de Reyes en Palma, a 138.000 euros. Recibió decenas de ofertas en días, la mayoría de fondos de inversión.

El suelo. El suelo balear es, de largo, el más caro de España: 5.285 euros el metro cuadrado de media en 2026, casi cinco veces más que en Extremadura (1.083 euros) y muy por encima de la media nacional, que este año ha marcado su máximo histórico en torno a 2.820 euros/m². Cuanto más caro es el metro cuadrado libre, más brutal resulta el tijeretazo cuando hay un okupa dentro: es la razón por la que un piso ibicenco pierde 250.000 euros de golpe y un chalet en Almadén (Ciudad Real), el municipio más barato del país, apenas perdería unos pocos miles.

El verdadero riesgo. Comprar barato no significa entrar rápido. Según el Consejo General del Poder Judicial, el tiempo medio para conseguir un desalojo por ocupación ronda los 20,5 meses (en 2023, sin actualizar datos), sumando primera instancia y apelación, frente a los menos de 5 meses de 2018. En Cataluña, el plazo medio es de 20,1 meses de 2023.

Para comparar: en Reino Unido, la policía puede entrar sin orden judicial ante la simple sospecha de ocupación, y el propietario puede tramitar una orden de posesión en apenas 28 días. España cuenta con cerca de 27 millones de viviendas. Pero lo que de verdad compra quien firma por uno de estos pisos no es un inmueble, es una posición en una cola judicial. El piso de Cala de Bou sigue esperando su oferta y la inquilina sigue dentro: paciencia es la palabra negociadora.

Imágenes | Idealista

En Xataka | Si tienes una casa vacía, paga el doble de impuestos: en Londres han decidido ponerse duros para atajar su crisis de vivienda


                 -  La noticia
      
        Este piso de Ibiza se vende a mitad de precio, pero hay un problema: nadie puede entrar a verlo 
      
      fue publicada originalmente en
      
        Xataka 
      
             por 
               
        Isra Fdez
        
             .',NULL,'Xataka',0.9,'es',NULL,'2026-09-16T17:30:12+00:00','2026-09-16T19:40:39+00:00',55,54.8,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(56,'tech','https://www.xataka.com/movilidad/diesel-se-ha-vuelto-a-disparar-todo-mundo-crudo-no-este-maximos-clave-esta-refinerias','60345fb98f8a9e55e2bf96dc5623e1e213a2d2e0','El diésel se ha vuelto a disparar en todo el mundo aunque el crudo no esté en máximos: la clave está en las refinerías','No es ninguna sorpresa el hecho de que los precios del combustible hayan subido en gran medida en los últimos meses. El conflicto bélico entre Estados Unidos e Irán fue lo que rompió el hielo, haciendo que el estrecho de Ormuz (por donde pasa la mayor parte del petróleo en el mundo) quedara bloqueado y desembocando en una escalada de precios sin precedentes. Esto no solo ha afectado a conductores, sino también a transportistas, mercancías, aviación y prácticamente todo lo que necesita combustible hoy día.
Hasta un país como Estados Unidos, que parecía blindado completamente de los problemas de combustible, está sintiendo el desequilibrio global en la cadena de suministro del petróleo. Y en Europa ya hay incluso países en los que el diésel roza los 3 euros el litro en algunas gasolineras de Alemania o Italia. La cadena de suministro se ahoga y las refinerías no dan abasto.
En cifras. Según el Boletín Semanal del Petróleo de la Comisión Europea, la media en toda la UE se situaba en 1,907 euros por litro para la gasolina y 2,028 euros para el diésel a fecha de 7 de septiembre de 2026. El precio del diésel en Alemania se situó en 2,34 euros por litro esa misma semana, muy por encima de la media decenal del país de 1,48 euros. Francia se encuentra un poco por debajo, cerca de los 2,20 euros. Los rincones más caros de Europa (los Países Bajos, Dinamarca, Alemania, Finlandia y Bélgica) son los más cercanos al rango de 2,40-2,60 euros.
Cómo hemos llegado hasta aquí. Tal y como mencionábamos al principio, la subida se remonta a finales de febrero cuando estalló la guerra entre Estados Unidos, Israel e Irán, interrumpiendo el tráfico a través del estrecho de Ormuz, un punto estrangulador para aproximadamente una quinta parte de los flujos mundiales de petróleo. Reuters contaba en mayo que el crudo Brent superó los 110 dólares por barril, su nivel más alto desde 2022. El diésel reaccionó con mayor violencia, superando en varios países los 2 euros por litro y con incrementos que en España superaron el 34 % desde que comenzó la guerra.
Un informe del grupo de investigación CREA estimaba que los precios del diésel y la gasolina en todo el mundo se habían disparado un 59 % desde que comenzó la guerra en febrero, añadiendo decenas de miles de millones de euros en costes imprevistos de importación de combustible en las principales economías europeas.


 
  
   
    
     
    
   
   
    
     En Xataka
    
    Si la pregunta qué día es el mejor para llenar el depósito y ahorrar unos euros, la respuesta es sencilla: ayer
   
  
 

Al otro lado del Atlántico es peor, y es un récord. En Estados Unidos, la historia ha ido más allá, pues la media nacional del precio del diésel alcanzaba su máximo histórico, superando su récord de 2022. Los camioneros pagaban alrededor de 5,85 dólares por galón en todo el país a principios de septiembre, casi un 60 % más que los aproximadamente 3,71 dólares por galón que pagaban un año antes, alcanzando California unos 7,70 dólares por galón. A mediados de septiembre, las medias nacionales rondaban los 6 dólares por galón a medida que la guerra entre EEUU e Irán continuaba interrumpiendo el tráfico marítimo a través del estrecho de Ormuz.

En realidad no se trata del petróleo crudo. El diésel está batiendo récords a pesar de que el petróleo crudo en sí es más barato de lo que era durante el pico de 2022. El diésel en EEUU alcanzó un máximo histórico de 5,901 dólares por galón el 8 de septiembre, incluso cuando el crudo cotizaba unos 28 dólares por barril por debajo de su nivel de 2022. La diferencia entre ambos, conocida como “margen de refino” o “crack spread”, es decir, el margen que ganan las refinerías al convertir el crudo en combustible terminado, ha alcanzado niveles inéditos.

El crack spread del diésel en EEUU alcanzó un máximo histórico de 100 dólares por barril, y tres de las mayores refinerías del país, Marathon Petroleum, Valero y Phillips 66, han ganado en conjunto 12.600 millones de dólares en el segundo trimestre de 2026. Así que no es que falte petróleo, sino que la capacidad mundial para refinarlo y convertirlo en diésel ha quedado mermada.

Qué está mermando esa capacidad. Hay dos guerras que se están agravando mutuamente. Ucrania ha estado atacando refinerías rusas, lo que ha llevado a Moscú a restringir las exportaciones de diésel, mientras que los ataques de Irán cerca del estrecho de Ormuz también han golpeado las refinerías de los aliados del Golfo. El propio director de operaciones de Valero, Gary Simmons, contaba que los dos conflictos juntos han paralizado refinerías que representan unos 5 millones de barriles diarios de capacidad. Andy Lipow, analista independiente, estimaba que alrededor del 8 % del diésel necesario para cubrir la demanda mundial se encuentra actualmente interrumpido.

¿Se acerca el litro a 3 euros? Los analistas ven que EEUU se encamina hacia una media anual récord para el diésel, algo que es improbable que iguale la gasolina, ya que ésta entra en su descenso otoñal. En Europa, la limitación es menos grave por el momento, pues los precios son altos y volátiles pero todavía se mantienen por debajo de los 3 euros incluso en los países más caros. Que eso cambie depende menos del suministro de crudo que de la rapidez con la que las refinerías dañadas en Rusia y Oriente Medio vuelvan a estar operativas, y las reparaciones podrían tardar muchos meses.

Lo único con lo que sí hemos dado es que en alguna que otra gasolinera de Italia ya está el diésel premium por encima de los 3 euros el litro. Aunque de momento es un caso muy puntual.

En Xataka | Vuelve el fantasma de la gasolina a 2€/litro: la voladura del oleoducto en Arabia Saudí resucita la crisis del petróleo


                 -  La noticia
      
        El diésel se ha vuelto a disparar en todo el mundo aunque el crudo no esté en máximos: la clave está en las refinerías  
      
      fue publicada originalmente en
      
        Xataka 
      
             por 
               
        Antonio Vallejo
        
             .',NULL,'Xataka',0.9,'es',NULL,'2026-09-16T17:00:13+00:00','2026-09-16T19:40:39+00:00',56,54.5,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(57,'tech','https://www.xataka.com/empresas-y-economia/paso-680-dias-marruecos-siguio-cobrando-su-pension-justicia-acaba-confirmar-consecuencias-32-857-euros','4a5405558cc5371f4dc2f640b4bfe2a508a3ed6e','Pasó 680 días en Marruecos y siguió cobrando su pensión en España. La Justicia acaba de confirmar las consecuencias: 32.857 euros','Una pensionista de 77 años viajaba a Marruecos con frecuencia. Se quedaba semanas, a veces meses, y volvía cuando le convenía. Durante todo ese tiempo, la mujer recibía puntualmente su pensión y, durante años, nadie en la Administración puso el foco en esos viajes. Hasta que alguien sí lo hizo.
Ahora el Tribunal Superior de Justicia de Cataluña ha revisado su expediente y el balance no es para nada positivo: la pensionista tendrá que devolver 32.857,20 euros por haber permanecido demasiado tiempo en el país vecino e incumplir los requisitos de residencia que rigen la pensión no contributiva que recibía. Es decir, si no vives en España, no puedes cobrarla.
Una pensionista en Marruecos. Según se detalla en la sentencia dictada por la Sala de lo Social del Tribunal Superior de Justicia de Cataluña, la protagonista cobraba desde diciembre de 2013 una pensión de invalidez no contributiva. Según su normativa, esta ayuda exige acreditar una discapacidad y residir legalmente en España. No hace falta haber cotizado lo suficiente para acceder a una pensión ordinaria y, en su caso, rondaba los 604 euros mensuales, más un pequeño complemento de unos 37 euros.
A esa cantidad se sumaba otra pensión de Marruecos de unos 97 euros al mes. Y ahí empieza el problema. La mujer permaneció fuera de España 135 días en 2018, 136 días en 2019, 260 días en 2020 y 149 días en 2021, según recoge la sentencia. En total suman 680 días en cuatro ejercicios.


 
  
   
    
     
    
   
   
    
     En Xataka
    
    La ineludible realidad de las cotizaciones a la Seguridad Social: "Quien cotiza 40 años al máximo no llega al 50% de lo aportado"
   
  
 

El límite que marca la ley. Tal y como se recoge en el artículo 10.2 del Real Decreto 357/1991 que regula las prestaciones no contributivas, la residencia legal "no se considerará interrumpida por las ausencias del territorio español inferiores a noventa días a lo largo de cada año natural", salvo enfermedad justificada. Superado ese tope, la ley entiende que hubo un traslado real de residencia fuera de España.
No hace falta demostrar que alguien se instaló de forma definitiva en otro país. Basta con contar los días que la beneficiaria de la pensión pasó fuera del territorio nacional. La Seguridad Social revisa estos expedientes de forma habitual. Es un control muy parecido al que exige la fe de vida a los pensionistas que residen en el extranjero.
La reclamación por cobro indebido. El expediente detectó dos fallos. El primero, la duración de las salidas al extranjero que, según se lee en la sentencia "que superó ampliamente los 90 días cada año" que contempla la ley. El segundo, los ingresos de la unidad familiar. Tal y como detalla la sentencia del TSJ de Cataluña, en 2021, la unidad familiar sumó unos ingresos de 73.291,08 euros, muy por encima del límite de 33.835,2 euros que el tribunal había fijado para su caso.
Con esos dos motivos sobre la mesa, la Generalitat de Cataluña anuló la prestación con efectos retroactivos desde junio de 2018 y reclamó la devolución de todo lo cobrado desde entonces: 32.857,20 euros. La beneficiaria recurrió y, en su defensa, alegó que el cierre de fronteras por la pandemia le impidió volver a España a tiempo en 2020.


 
  
   
    
     
      
      
      
      
     
    
   
   
    
     El futuro de las pensiones tiene un precio: millones de nóminas lo van a pagar un poco más caro a partir de 2026
         
   
  
 

Lo que dice el TSJ de Cataluña. El Tribunal Superior de Justicia de Cataluña no aceptó ese argumento. La sentencia recuerda que España mantuvo canales de regreso para sus residentes. Incluso en los meses más duros, cuando se restablecieron los controles en las fronteras. Sobre los ingresos familiares, el fallo es más contundente todavía: "es evidente que se superó muy ampliamente el límite de ingresos", señalan los magistrados.
El fallo confirma, además, que no hace falta probar un cambio formal de residencia para perder la pensión. La salida al extranjero "superior a 90 días es causa de extinción", señalan los magistrados. No hace falta demostrar, añade, que la persona pasó a vivir de forma legal en el otro país basta con que exceda el plazo de permanencia fuera del país para anular la prestación.
Por lo tanto, la pensionista debe devolver a la Seguridad Social los 32.857,20 euros que recibió indebidamente durante esos cuatro años porque ya cumplía con los requisitos para cobrar su prestación.
En Xataka | Alfonso Muñoz, experto en jubilación: "Compensa no solicitar la jubilación anticipada si cobras el subsidio para mayores de 52"
Imagen | Unsplash (Saif Taee)


                 -  La noticia
      
        Pasó 680 días en Marruecos y siguió cobrando su pensión en España. La Justicia acaba de confirmar las consecuencias: 32.857 euros 
      
      fue publicada originalmente en
      
        Xataka 
      
             por 
               
        Rubén Andrés
        
             .',NULL,'Xataka',0.9,'es',NULL,'2026-09-16T16:30:13+00:00','2026-09-16T19:40:39+00:00',57,54.3,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(58,'tech','https://www.xataka.com/seleccion/almacenamiento-nube-europeo-cifrado-conocimiento-cero-descuentazo-internxt-alternativa-a-google-drive','2e56829300118c51557eb5e9289559f0f3431cb5','Un almacenamiento en la nube europeo con cifrado de conocimiento cero (y descuentazo): Internxt es una alternativa a Google Drive','No todas las nubes de almacenamiento son propiedad de empresas de EEUU: hay vida más allá de Google Drive y OneDrive. Además, cada vez son más los usuarios que buscan independizarse de estos servicios y apostar por alternativas europeas. ¿Estás buscando un almacenamiento en la nube que cumpla con esto? Puede encajarte Internxt: es de origen español y, utilizando el código ''XATAKA'', tienen un 85 % de descuento en todos sus planes.



 
  
 
     
   
  
   Internxt Drive
   
         
             

      PVP en Internxt (desde) —       285,00 €
 
                    
           
  
 
 El precio podría variar. Obtenemos comisión por estos enlaces


Una nube europea con cifrado de conocimiento cero
 
                    
         
    
     
 
      

El aumento del trabajo remoto es una realidad y eso tiene, entre otras muchas consecuencias, una mayor necesidad de tener información almacenada en la nube para facilitar el compartirla con otras personas o acceder a ella desde distintos equipos. A eso hay que sumarle que puede que tengamos la necesidad de tener almacenamiento para darle aire a nuestros móviles y portátiles, especialmente si almacenamos muchas fotos o vídeos. Pero, ¿cuáles son los puntos fuertes de Internxt?

Lo primero es que tiene cifrado de conocimiento cero. ¿Qué quiere decir eso? Que los archivos se encriptan antes de subirlos a la nube y somos nosotros los que almacenamos las claves. Eso, en la práctica, implica que nadie puede acceder a nuestros datos, ni siquiera la propia Internxt. 

A eso hay que sumarle que la plataforma también tiene cifrado post-cuántico, protegiendo así nuestros datos para el futuro cercano y la computación cuántica. Es cierto que esta todavía no está demasiado extendida, lo que podría significar que no tiene mucho sentido. Sin embargo, siempre existe la posibilidad de que alguien almacene nuestra información para usarla dentro de unos años. De esa forma, nuestra información estará protegida incluso en ese momento.


 
  
   
    
     
    
   
   
    
     En Xataka
    
    Hoy en Amazon, la solución económica para usar fácilmente los enchufes poco accesibles tras muebles y sofás 
   
  
 

Otro punto a destacar de Internxt es que, al tener sede en Valencia, opera bajo la jurisdicción europea y del RGPD. Esto es algo que no se aplica a nubes como Google Drive o OneDrive de Microsoft, puesto que estas, al ser de compañías de EE. UU., actúan bajo la llamada CLOUD Act. ¿En qué nos afecta esto en la práctica? Es que las leyes europeas son más rígidas en lo que a privacidad y protección de nuestros datos se refiere.

Siguiendo con la seguridad y privacidad de Internxt, no podemos olvidar que es un servicio de código abierto, por lo que cualquier persona del mundo puede acceder a su código y auditarlo. También cuenta con varios reconocimientos en materia de seguridad, como la certificación ISO 27001, Certificación ENS Alto o Apoyo del CDTI.



 
  
 
     
   
  
   Internxt Drive
   
         
             

      PVP en Internxt (desde) —       285,00 €
 
                    
           
  
 
 El precio podría variar. Obtenemos comisión por estos enlaces


Si te interesa, Internxt tiene tres planes diferentes que podemos elegir pagar de forma mensual o un solo pago y tener el servicio para toda la vida. Por ejemplo, su plan más económico, llamado Esencial, ofrece 1 TB de almacenamiento por 1,49 euros al mes o 285 euros en un solo pago. Este servicio, además, incluye VPN (y antivirus), lo que te puede venir genial si ya estás pagando una a parte.

Algunos de los enlaces de este artículo son afiliados y pueden reportar un beneficio a Xataka. En caso de no disponibilidad, las ofertas pueden variar.

Imágenes | Internxt

En Xataka | Mejores VPN 2026: guía con los 17 mejores servicios para proteger tu privacidad online

En Xataka | Alternativas Google Drive: los mejores servicios de almacenamiento en la nube para tus archivos


                 -  La noticia
      
        Un almacenamiento en la nube europeo con cifrado de conocimiento cero (y descuentazo): Internxt es una alternativa a Google Drive  
      
      fue publicada originalmente en
      
        Xataka 
      
             por 
               
        Juan Lorente
        
             .',NULL,'Xataka',0.9,'es',NULL,'2026-09-16T16:16:11+00:00','2026-09-16T19:40:39+00:00',58,54.1,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(59,'tech','https://www.xataka.com/espacio/nasa-lanzo-telescopio-roman-esperando-10-anos-vida-suerte-precision-le-han-regalado-doble','b0f87e8afee20081f1b70b1482f6947024c64e7f','La NASA lanzó el telescopio Roman esperando 10 años de vida. La suerte y la precisión le han regalado el doble','El Telescopio Nancy Grace Roman ha sido uno de los grandes logros actuales de la NASA. Su desarrollo fue un éxito, su lanzamiento transcurrió sin incidentes y se espera que en los próximos años llegue a donde ni siquiera el James Webb y el Hubble han podido llegar, aportando datos de interés en la búsqueda de exoplanetas y materia oscura. Esto ya de por sí era un motivo de celebración. Pero, por si no fuese suficiente, ahora la agencia espacial estadounidense ha anunciado que, por una carambola de suerte y victorias técnicas encadenadas que empezó incluso con un lanzamiento antes de tiempo, su vida útil se alargará casi una década más de lo que se pensó inicialmente. Eso da para tomar muchísimos datos.
5 años de misión y todo lo que se pueda añadir. La misión principal que llevará a cabo el Nancye Grace Roman será de 5 años. Además, desde un principio se pensó que, si la financiación lo permitía, se podría alargar hasta una década, gracias al máximo de combustible que se podría añadir en los tanques de la nave. Sin embargo, una vez que la nave estuvo construida, esta cifra se quedó corta. 
De 10 a 22 años. Cuando se diseña una nave o un telescopio espacial, como en este caso, no se sabe inicialmente cuáles serán sus dimensiones. Se hace un cálculo al alza y después se hacen ajustes si es necesario. Por eso, aunque inicialmente se calculó que la nave pesaría 9.800 kg, una vez construida se quedó con una masa de 8.056 kg. Eso permitió añadir más peso en forma de combustible, de manera que, de 10 años máximos de misión, se pasó a 14 años. Y la cosa no se quedó ahí.


 
  
   
    
     
    
   
   
    
     En Xataka
    
    Las estrellas con agujero negro en su interior solo existían en la teoría. Hasta que el James Webb se dio un paseo 
   
  
 

Tras el lanzamiento, que tuvo lugar el pasado 30 de agosto, la nave encendió brevemente su motor para posicionarse en la trayectoria que la llevaría a su destino, en el punto de Lagrange L2. Se logró posicionar con una precisión del 99%, mucho más de lo que habían predicho los cálculos, por lo que se gastaron solo 18 kg de combustible, mucho menos de lo esperado. Eso, de nuevo, dejaba más combustible disponible para seguir trabajando cuando llegue a L2. De 14 años, pasaron a 18. Y lo mejor es que, dada la precisión con la que apuntaron a L2, se espera que en una segunda corrección de rumbo que se realizará antes de llegar a L2 se gaste también muy poco combustible, por lo que finalmente habría reservas para 22 años de misión.

Los próximos encendidos. Una vez que el Nancy Grace Roman se posicione en su órbita en L2 el próximo mes de diciembre, solo tendrá que hacer encendidos muy breves cada 28 días. Es más que esperable que pueda llegar a los 22 años de misión. No obstante, cabe destacar que para eso será necesaria la financiación. Por ahora solo está pagado para que realice su misión de 5 años. No obstante, con tantos éxitos y todo ese combustible de sobra, sería una pena desperdiciarlo.

Mano a mano con el James Webb. El Telescopio Espacial James Webb también está en L2, por lo que ambos instrumentos podrán trabajar mano a mano, complementándose entre sí. El Nancy Grace Roman fotografiará un área muy amplia y verá un número enorme de objetos, mientras que Webb verá menos cosas con mayor detalle. Esto permitirá a Roman localizar objetos raros que Webb podrá estudiar en detalle con su visión más potente, pero más estrecha. Por otro lado, Roman podrá observar regiones ya vistas por Webb para aportar contexto. 

Dicho de una forma muy metafórica, Roman verá páginas y páginas de un libro, mientras que James Webb solo se puede centrar en unas pocas palabras. Ambos se necesitan, porque para entender unas pocas palabras debemos conocer el libro del que provienen, pero si encontramos un pasaje interesante en el libro, necesitamos a alguien que pueda leerlo de cerca. Por eso es tan importante que el Nancy Grace Roman pueda alargar su misión. 

Imagen | NASA

En Xataka | Llevamos años estudiando los planetas de TRAPPIST-1 con una gran esperanza. El James Webb acaba de tumbarla






                 -  La noticia
      
        La NASA lanzó el telescopio Roman esperando 10 años de vida. La suerte y la precisión le han regalado el doble   
      
      fue publicada originalmente en
      
        Xataka 
      
             por 
               
        Azucena Martín
        
             .',NULL,'Xataka',0.9,'es',NULL,'2026-09-16T16:00:12+00:00','2026-09-16T19:40:39+00:00',59,54.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(60,'tech','https://www.xataka.com/energia/china-abre-al-mundo-su-tecnologia-reactores-nucleares-alta-temperatura','21edd1c010db2e3565d41b153364b744bafbde88','China abre al mundo su tecnología de reactores nucleares de alta temperatura','China se ha conseguido situar a la vanguardia de los reactores nucleares de alta temperatura, conocidos como HTGR (High-Temperature Gas-cooled Reactor o reactor refrigerado por gas de alta temperatura). Su dominio acaba de llevar al Organismo Internacional de Energía Atómica (OIEA) a firmar un acuerdo de colaboración por el que la nación liderada por Xi Jinping se compromete a compartir su experiencia en energía nuclear con el resto del mundo.

Antes de indagar en las implicaciones de este pacto merece la pena que nos detengamos un momento para explorar cómo ha conseguido China colocarse a la vanguardia de la energía nuclear en general, y de la tecnología de los reactores de alta temperatura en particular. Este país empezó a investigar estos reactores a finales de los años 70, mucho antes de que fuesen viables desde un punto de vista comercial. El programa chino de desarrollo tecnológico respaldó esta iniciativa en los años 80, y en 1995 comenzó la construcción del HTR-10, el primer reactor experimental chino de esta clase.

La semilla acababa de ser plantada. China transformó el HTR-10 en una plataforma idónea para dar el salto comercial a gran escala. No obstante, la mayor fortaleza de este país es que ya en aquel momento creó un ecosistema muy robusto en el que la universidad, las empresas nucleares y el Estado se dan la mano y reman de una forma coordinada. Si a esto sumamos su capacidad industrial y la persistencia con la que el Estado ha financiado la investigación, es fácil entender cómo China ha llegado a la posición en la que se encuentra actualmente.

Objetivo: ir más allá de la generación de electricidadManejar con absoluta seguridad las altas temperaturas de los reactores HTGR no es sencillo porque requiere utilizar en la fabricación de los elementos críticos del reactor, como la vasija o el intercambiador de calor, elementos químicos y aleaciones que sean capaces de soportar un estrés térmico muy alto sin que su estructura se vea degradada y su volumen resulte alterado. Esta es la razón por la que actualmente el estándar BPVC (Código de calderas y vasijas de presión), que es el que recoge los requisitos que deben cumplir los materiales utilizados en la fabricación de los reactores nucleares de alta temperatura, es extraordinariamente riguroso.


 
  
   
    
     
    
   
   
    
     En Xataka
    
    China ha logrado lo que parecía imposible: una batería capaz de seguir funcionando incluso a -70 ºC
   
  
 


 
     Hasta hace muy poco tiempo únicamente cinco materiales habían conseguido superar los requisitos impuestos por el estándar BPVC
   

Hasta hace muy poco tiempo únicamente cinco materiales habían conseguido superar los requisitos impuestos por el estándar BPVC para los reactores nucleares de alta temperatura, mientras que en la fabricación de un reactor de agua ligera es posible emplear hasta 100 materiales diferentes. La escasez de elementos disponibles para la fabricación de los primeros parecía condenar a las centrales nucleares de cuarta generación a un futuro incierto, pero China es uno de los países que más ha empujado la frontera tecnológica para llevar a buen puerto estas máquinas.
El acuerdo que ha pactado con el Organismo Internacional de Energía Atómica aborda la investigación, el diseño, la construcción, la puesta en marcha y la operación de los reactores HTGR. Este es el ámbito en el que otros países podrán beneficiarse de la experiencia de China. No obstante, este último país también podrá aprovechar las fortalezas de otras naciones en el terreno de la gestión de la cadena de suministro y la formación de personal altamente cualificado. Sobre el papel, todos ganan.


 
  
   
    
   
  
 

Los reactores HTGR han sido diseñados para operar a temperaturas más altas que los reactores convencionales, por lo que una parte del calor que generan puede ser utilizado en procesos industriales, para generar hidrógeno o producir vapor, además de, por supuesto, para generar electricidad. De hecho, esta propiedad es lo que los hace tan atractivos para todos los países que apuestan por la energía nuclear como una pieza importante de su mix energético. Un apunte importante para concluir: este acuerdo no implica que China vaya a desplegar sus propios reactores HTGR en otros países.

Imagen | Shandong Shidao Bay

Más información | Interesting Engineering

En Xataka | Europa y Japón están listas: van a iniciar los experimentos de fusión nuclear más ambiciosos de la historia


                 -  La noticia
      
        China abre al mundo su tecnología de reactores nucleares de alta temperatura 
      
      fue publicada originalmente en
      
        Xataka 
      
             por 
               
        Laura López
        
             .',NULL,'Xataka',0.9,'es',NULL,'2026-09-16T15:46:11+00:00','2026-09-16T19:40:39+00:00',60,53.9,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(61,'tech','https://www.xataka.com/magnet/cancelado-tapapies-festival-tapas-lavapies-su-propio-exito-algunos-bares-pequenos-pueden-verse-obligados-a-cerrar','32076ae08660a7c64834872bfd48a7e78b46dc70','Cancelado Tapapiés, el festival de tapas de Lavapiés, por su propio éxito: "Algunos bares pequeños pueden verse obligados a cerrar"','“Era nuestro salvavidas”, indica Antonio Amago, propietario de La Musa de Espronceda, a ElPaís. Este 2026 tocaba decimosexta edición. Pero no va a ser posible. Tapapiés, el festival de tapas de Lavapiés, se suspende un año entero por el motivo menos habitual para cancelar un evento. Le sobra público. Dicho de otra forma: ha muerto de éxito. 
No lo decimos nosotros, lo dice Manuel Díaz, cofundador del festival y director de Comunicación. Sobrepasado por su propia repercusión, 2025 fue el punto de ruptura: 92 tapas, cocina de alrededor de 30 países, 68 bares participantes, participación de los mercados de San Fernando y Antón Martín. La previsión inicial era de unos 90.000 visitantes. Se superó el medio millón de personas. Según los vecinos, “cuando quisimos reaccionar, estaban las calles llenas y ya no se podía parar. Incluso se pensó en suspenderlo el primer fin de semana”.
De 24 bares al fenómeno descontrolado. Tapapiés nació en 2011 como una ruta de tapas promovida por la Asociación de Comerciantes de Lavapiés Distrito 12. Su objetivo inicial era atraer visitantes a un barrio con una gran diversidad cultural (pero castizo y poco turístico) y reforzar a los pequeños negocios. Con el tiempo incorporó conciertos, pasacalles y actividades gratuitas, hasta convertirse en una cita de escala mucho mayor. Usar el tirón de las rutas de tapas para revitalizarlo funcionó.
Demasiado, de hecho. En 2013, la tercera edición ya esperaba superar los 100.000 visitantes con 75 tapas de 24 países. Para 2025, decimoquinta edición y aniversario redondo, el festival reunía 68 bares y cocina de 30 países distintos, como decíamos. De los 90.000 visitantes que calculaban, los organizadores se toparon con cinco veces más gente. En un barrio de calles estrechas donde eso no cabe físicamente.


 
  
   
    
     
    
   
   
    
     En Xataka
    
    A la pregunta de cuántos bares hay en España, este mapa desmonta mitos y reafirma algunos excesos
   
  
 

Ruido en las calles. Papeleras a rebosar, suciedad, vómitos, mercados intransitables y lo que los propios organizadores describen como un botellón masivo al aire libre: justo lo contrario del espíritu de barrio con el que nació el evento. La Asociación Vecinal La Corrala describió determinadas zonas como un “desmadre”.

El caos llegó a plantear cancelar sobre la marcha el primer fin de semana de 2025. Aguantaron, sí, pero ahora se llega a lo que la organización llama "un año de reflexión", para retomarlo en 2027 con un formato que reparta el público sin renunciar a mostrar la cocina de un barrio donde conviven más de 80 nacionalidades censadas.

La otra cara. No todo el mundo agradece la pausa. Para muchos locales pequeños, esos días eran el colchón económico del trimestre. Lo apuntábamos al comienzo con locales como La Musa de Espronceda: el dueño explica que en su local las ventas diarias se disparaban 75% durante Tapapiés. La factura conjunta del barrio creció un 25% en apenas 11 días. 

Un problema cada vez menos raro. El caso de Tapapiés se parece demasiado al de las fiestas de Gràcia, donde una celebración de raíz vecinal acabó con una llegada masiva de visitantes, el ruido y la suciedad. También guarda relación con el Brunch in the Park, criticado por las molestias, el consumo de alcohol y la ocupación temporal de un espacio público, y con la decisión de Barcelona de reducir los grandes eventos en Montjuïc para limitar su impacto sobre los barrios próximos. 

El plan B de 2027 puede pasar por reducir la duración o escalonar las actividades, limitar el número de locales participantes, eliminar o restringir los conciertos callejeros en las zonas residenciales, crear reservas o franjas horarias para evitar colas y aglomeraciones, separar la ruta gastronómica de las actuaciones musicales, establecer aforos por mercados y reforzar baños, limpieza, recogida de residuos y mediación vecinal.

Está claro que la cuestión común no pasa necesariamente por cancelar las fiestas, sino rediseñarlas con aforos, horarios, control del alcohol, refuerzo de limpieza y una distribución que respete la capacidad real del barrio. 

Artículo original publicado en Directo al Paladar

Imágenes | Asociación de Comerciantes de Lavapiés Distrito 12

En Xataka | La Generación Z está reinventando su forma de beber alcohol, pero hay algo que se mantiene intocable: el estigma del abstemio


                 -  La noticia
      
        Cancelado Tapapiés, el festival de tapas de Lavapiés, por su propio éxito: "Algunos bares pequeños pueden verse obligados a cerrar" 
      
      fue publicada originalmente en
      
        Xataka 
      
             por 
               
        Isra Fdez
        
             .',NULL,'Xataka',0.9,'es',NULL,'2026-09-16T15:30:12+00:00','2026-09-16T19:40:39+00:00',61,53.8,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(62,'tech','https://www.xataka.com/energia/madre-todas-crisis-petroleo-arabia-saudi-empieza-a-cancelar-exportaciones-petroleo-a-europa','c05e4aafa7a8b6022fea376dc51b97a90cbfc7c4','La madre de todas las crisis del petróleo: Arabia Saudí empieza a cancelar las exportaciones de petróleo a Europa','Hace solo unos días conocíamos que fuerzas hutíes habían atacado con drones el oleoducto estratégico que atraviesa Arabia Saudí y sus consecuencias no se han hecho esperar. Con esta infraestructura en reparación, el mayor exportador de petróleo del mundo está teniendo dificultades para sacar al mercado parte de su producción por las rutas habituales. Y los efectos están siendo demoledores, con unas subidas del barril de crudo que podrían superar la barrera de los 150 dólares en algunos escenarios.

Arabia Saudí recorta algunos envíos a Europa. Tras el ataque hutí al oleoducto Este-Oeste que transportaba unos 7 millones de barriles diarios, Arabia Saudí ha informado a sus clientes europeos de que se cancelarán algunos cargamentos de crudo previstos para este mes, como reporta Reuters. La interrupción podría prolongarse durante las reparaciones, que algunas fuentes estiman que podrían durar varias semanas. 

El secretario de Energía de EE.UU., Chris Wright, ha ofrecido, sin embargo, una previsión más optimista y ha asegurado que el oleoducto podría volver a estar operativo en cuestión de días, según recoge El Economista.


 
  
   
    
     
    
   
   
    
     En Xataka
    
    Vuelve el fantasma de la gasolina a 2€/litro: la voladura del oleoducto en Arabia Saudí resucita la crisis del petróleo
   
  
 

El anuncio ya ha tenido impacto en los mercados. Los efectos del anuncio de esta decisión no se han hecho esperar. Si Arabia Saudí cierra el grifo de sus exportaciones a Europa, los precios pueden verse afectados. Así lo demostró la jornada del 15 de septiembre, cuando el precio del barril de Omán llegó a alcanzar los 150 dólares. Se trata de una referencia especialmente relevante en este contexto porque su ruta no depende de atravesar el estrecho de Ormuz ni Bab el-Mandeb (controlados por Irán y por los hutíes, respectivamente), dos de los principales puntos críticos de la región.

¿Podría dejar de ser posible comprar petróleo? Algunos especialistas advierten de que, si la tensión se mantiene, la subida podría trasladarse al resto de referencias de crudo y llevarlas también a máximos históricos. Como explica Cinco Días, la barrera de los 150 dólares es la última frontera y el escenario más extremo para un mercado energético que, aunque ya resentido, todavía podría empeorar aún más. Según declara al diario económico Jorge León, jefe de análisis de la consultora energética Rystad, el precio no puede subir más porque, sencillamente, se destruiría la demanda. Si esto ocurre, el resto del mundo no podría comprar más petróleo, y tendría que racionar sus reservas y obligar a realizar cortes en el suministro, con las consecuencias fatales que eso podría conllevar. 

El transporte de petróleo también se ha disparado de precio. El problema no está solo en el precio del barril. Otra de las consecuencias derivadas de esta compleja situación es el fuerte aumento en las tarifas de transporte. La disponibilidad de petroleros se ha reducido mientras aumenta el riesgo asociado a las rutas marítimas de Oriente Medio, donde los ataques a buques mercantes son muy habituales. 

La diferencia es enorme: la semana pasada, las tarifas de fletamento de petroleros alcanzaron el millón de dólares al día, según apunta el portal XTB. Hace tan solo un año, el coste de alquilar uno de estos buques era de menos 100.000 dólares.

Las alternativas, volátiles e insuficientes. Todo, a pesar de todos los esfuerzos que se están haciendo y de las medidas que países como EE.UU. están poniendo en marcha para retomar el paso por Ormuz ahora que el oleoducto que evitaba esta ruta se encuentra fuera de juego, como explica XTB. Por ejemplo, la Marina estadounidense ha escoltado numerosos buques mercantes en el territorio marítimo de la zona de Omán, a menudo con sus señales de seguimiento apagadas para evitar ser detectados, según Reuters. Aun así, los volúmenes diarios de cargamento siguen siendo muy volátiles.

El de Arabia Saudí no es el único problema. A las reparaciones del oleoducto saudí se le suma la interrupción de otros yacimientos que están provocando una situación de estrangulamiento en el resto del mundo. Por un lado, la escalada de la crisis en Libia ha llevado a la compañía estatal National Oil Corporation a suspender temporalmente los trabajos en varios yacimientos petroleros, entre los que se encuentran Hamada y Al-Tahara, después de que la Guardia de Instalaciones Petroleras cerrara una válvula en el principal oleoducto como medida de protesta.

Por otro lado, Kazajistán también atraviesa problemas de producción. Esta potencia energética clave tiene a su industria petrolera ahora mismo en tareas de mantenimiento. Los trabajos operativos en los yacimientos de Karachaganak han reducido las previsiones en la producción nacional en un 8,4%, en un momento clave que resulta clave para el mercado petrolero. 



Imagen | Mumtaz Niazi 

En Xataka | El mapa energético está cambiando: ya no gana quien tiene más gas, sino quien puede sacarlo al mercado




                 -  La noticia
      
        La madre de todas las crisis del petróleo: Arabia Saudí empieza a cancelar las exportaciones de petróleo a Europa  
      
      fue publicada originalmente en
      
        Xataka 
      
             por 
               
        Alexandra Ramírez
        
             .',NULL,'Xataka',0.9,'es',NULL,'2026-09-16T15:16:09+00:00','2026-09-16T19:40:39+00:00',62,53.6,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(63,'tech','https://www.xataka.com/robotica-e-ia/para-zuckerberg-seguridad-ia-no-freno-argumento-venta-anthropic-openai','54385d1e10fa9d19b1c4a5bf6dd858a028745ec7','Para Zuckerberg, la seguridad de la IA no es un freno: es el argumento de venta contra Anthropic y OpenAI','Las empresas de IA están "jugando con nuestras vidas". Es lo que dijo Jacob Coxon, exingeniero de Anthropic justo después de abandonar la compañía. Lo que le siguió fue un terremoto que ha puesto patas arriba la industria de la IA. De un lado tenemos a los responsables de las empresas de IA, con Dario Amodei al frente, abogan por echar el freno y ralentizar el desarrollo ante un inminente riesgo para la humanidad. Del otro lado tenemos a Trump y  Jensen Huang, que quieren justo lo contrario: acelerar. Había un líder tecnológico que aún no se había pronunciado: Mark Zuckerberg. 
Zuck ha hablado. En un mensaje publicado en su cuenta de X, el CEO de Meta se ha pronunciado sobre la polémica de estos días, criticando de forma indirecta el discurso de Anthropic y OpenAI: "Cada laboratorio tiene la responsabilidad y el incentivo para avanzar al ritmo necesario para entrenar sus modelos de manera segura". Zuckerberg no niega que existan riesgos, pero rechaza una pausa coordinada para toda la industria y traslada la responsabilidad de crear productos seguros directamente a los laboratorios. Además, les recuerda que los laboratorios "enfrentan una responsabilidad legal significativa si sus modelos causan daño". 
La alineación no es secundaria. Para Zuckerberg, la seguridad y alineación de los modelos no es algo secundario, sino primordial en el desarrollo de la IA. La propuesta encabezada por Amodei es ralentizar el desarrollo para permitir que la seguridad consiga ponerse al mismo nivel. Zuckerberg es claro ahí: "Mi opinión es que la confianza y la alineación se están convirtiendo rápidamente en las capacidades más importantes que diferenciarán a los agentes y modelos. Cualquier laboratorio que no se enfoque en la alineación se quedará atrás".


 
  
   
    
     
      
      
      
      
     
    
   
   
    
     Frenar la IA suena a proteger a la humanidad. También es una forma muy eficaz de frenar a DeepSeek, Qwen y Mistral
         
   
  
 

Automejora no, gracias. Zuckerberg también ha criticado la carrera por la llamada  automejora recursiva de la IA, es decir, que los modelos logren mejorarse a sí mismos. En su opinión, los laboratorios no deberían estar enfocando gran parte del cómputo en esto, sino en "servir a las personas" porque es "una de las mejores formas de asegurar que desarrollemos esta tecnología de manera segura". Es una crítica indirecta, pero bastante clara, a la creación de una superinteligencia que Anthropic ha puesto en el centro de su argumentario.

Meta ya lo hace. Zuckerberg no ha perdido la oportunidad de destacar que Meta ya está cumpliendo con todas esas acciones que propone Amodei. Asegura que retrasaron el lanzamiento de su modelo Muse "durante varios meses para enfocarse en la seguridad y la protección" y añade que "No pedimos que todos los demás lo hicieran. Simplemente lo hicimos como parte de nuestro trabajo diario porque claramente era lo correcto para las personas y para nosotros". Esto es claramente un dardo contra el discurso de Amodei, que pide que todos paren a la vez y se cree un marco regulatorio en torno a esto. 

El CEO de Meta también destaca que su empresa ya integra evaluadores y asesores independientes "en varias áreas porque ayuda a producir un mejor trabajo", y suelta otro dardo: "Otros laboratorios simplemente pueden hacer esto también". 

Son su competencia. Que Zuckerberg no se alinee con OpenAI y Anthropic tiene todo el sentido desde el punto de vista competitivo. La compañía ha hecho grandes esfuerzos para recortar distancia con su competencia, empezando por el fichaje de numerosos ingenieros e investigadores a los que ofrecieron sueldos de locura. Meta ya ha lanzado su modelo de IA Muse Spark, un agente personal y se espera que en las próximas semanas haya un nuevo lanzamiento, según el New York Times. Se habla de un modelo al que internamente se refieren como Watermelon, y será el más potente que han hecho hasta la fecha. 

Imagen | Xataka con Magnific

En Xataka | ¿Hay realmente un 10% de posibilidades de que la IA extinga al ser humano? La realidad tras el nuevo pánico apocalíptico




                 -  La noticia
      
        Para Zuckerberg, la seguridad de la IA no es un freno: es el argumento de venta contra Anthropic y OpenAI  
      
      fue publicada originalmente en
      
        Xataka 
      
             por 
               
        Amparo Babiloni
        
             .',NULL,'Xataka',0.9,'es',NULL,'2026-09-16T15:00:13+00:00','2026-09-16T19:40:39+00:00',63,53.5,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(64,'tech','https://www.xataka.com/seleccion/aldi-lanza-esta-aspiradora-cables-59-99-euros-luz-verde-varios-accesorios-59-99-euros','1d982efa30358bc3f7f00de4ca68c2768558f8e1','Aldi lanza esta aspiradora sin cables por 59,99 euros el próximo sábado 19 de septiembre: con luz verde y varios accesorios','Conseguir que la casa esté limpia sin invertir demasiado esfuerzo ni presupuesto es un objetivo recurrente y las aspiradoras de tipo escoba se han posicionado como la herramienta estrella para lograrlo. Sin embargo, muchas opciones del mercado superan fácilmente los 200 o 300 euros cuando buscan añadir tecnología de detección de suciedad o pantallas digitales.
Aldi vuelve a irrumpir en el sector del bazar este sábado, 19 de septiembre, lanzando una aspiradora vertical inalámbrica de la firma Ambino, que reúne características muy codiciadas por solo 59,99 euros.
Si no tienes un supermercado Aldi cerca, en Amazon hay una alternativa también económica (está rebajada a 89,98 euros) que puede interesarte. Se trata de la Proscenic P11 Ultra+, con 50 kPa de potencia de succión, autonomía de hasta 50 minutos, luz verde y varios cepillos.



 
  
 
     
   
  
   Proscenic P11 Ultra+ Aspiradora sin Cable
   
         
             

      PVP en Amazon —       89,98 €
 
                    
           
  
 
 El precio podría variar. Obtenemos comisión por estos enlaces


Detección de microsuciedad y panel digital por menos de 60 euros
 
                    
         
    
     
 
      

El elemento diferenciador de esta aspiradora vertical es su iluminación integrada de luz verde en la cabeza de aspirado. Inspirada en los sistemas de alta gama (como las aspiradoras Dyson), esta tecnología proyecta un haz de luz en ángulo sobre el suelo que resalta el polvo fino y la microsuciedad que habitualmente resultan invisibles con luz ambiente.

A nivel técnico y funcional, este modelo de 130 W se posiciona como una alternativa completa para el mantenimiento diario del hogar. Alcanza hasta 11 kPa de presión, ideal para suelos duros como parqué, gres o tarima.


 
  
   
    
     
    
   
   
    
     En Xataka
    
    Hoy en Action la solución a la falta de enchufes en casa para cargar tus dispositivos por 14,95 euros 
   
  
 

Dispone de un cabezal giratorio de 180° que facilita maniobrar entre las patas de sillas, mesas o bajo muebles bajos. Incorpora también una pantalla LCD para monitorear el estado del dispositivo y revisar el nivel de batería en tiempo real.
Cuenta con un depósito de polvo de 600 ml y un filtro HEPA lavable, pensado para retener pequeñas partículas y alérgenos. En cuanto a su batería, ofrece una autonomía de hasta 32 minutos de funcionamiento continuo con una sola carga. Por último, se puede destacar que incluye varios cabezales adicionales para adaptar la succión a rincones estrechos, tapicerías o zonas de difícil acceso.


 
  
       
        
                 
       ⚡ EN RESUMEN: aspiradora inalámbrica ambiano en aldi
      
    
 
    
      
          
                 
       ✅ LO MEJORLuz verde de precisión: una función heredada de la gama alta que proyecta luz angular para hacer visible el polvo fino que suele pasar desapercibido.Depósito holgado: sus 600 ml de capacidad superan la media de los modelos de gama de entrada.
      
    
   
                 
       ❌ LO PEORAutonomía para limpiezas rápidas... Sus 32 minutos de batería alcanzan para pisos pequeños o medianos, pero el tiempo se reduce al usar el modo de máxima potencia.Potencia modesta... Sus 11 kPa (130 W) resultan suficientes para suelos duros, pero se quedan cortos en alfombras gruesas o moquetas.
      
    
   
                 
       💡 CÓMPRALO SI... Estás buscando una aspiradora sin cable económica como segundo equipo o para un piso pequeño o mediano.
      
    
   
                 
       ⛔ NO LO COMPRES SI... Tienes una casa muy grande que requiere sesiones de limpieza de más de 45-60 minutos continuos.
      
    
 
      
  
 


 
  
   
    
     
    
   
   
    
     En Xataka
    
    Mejores aspiradores verticales. Cuál comprar en función del uso y seis modelos recomendados
   
  
 

También te podrían interesar

 
  
 
     
   
  
   Lefant M210 Robot Aspirador, 2200Pa, 120min, Suelos Duros, Modo Silencioso
   
         
             

      Hoy en Amazon —       99,99 €
 
                    
           
  
 
 El precio podría variar. Obtenemos comisión por estos enlaces




 
  
 
     
   
  
   XIAOMI G20 Lite Aspiradora Inalámbrica, 18000Pa/Hasta 40Min, LED
   
         
             

      Hoy en Amazon —       84,99 €
 
                      

       Leroy Merlin —       99,62 €
 
                

       PcComponentes —       99,90 €
 
              
           
  
 
 El precio podría variar. Obtenemos comisión por estos enlaces


Algunos de los enlaces de este artículo son afiliados y pueden reportar un beneficio a Xataka. En caso de no disponibilidad, las ofertas pueden variar.

Imagen | Aldi 

En Xataka | Mejores robots aspirador en calidad precio. Cuál comprar en función del uso y cinco modelos recomendados

En Xataka | Estos son los siete mejores dispositivos de limpieza para mantener la suciedad a raya


                 -  La noticia
      
        Aldi lanza esta aspiradora sin cables por 59,99 euros el próximo sábado 19 de septiembre: con luz verde y varios accesorios 
      
      fue publicada originalmente en
      
        Xataka 
      
             por 
               
        Fran León
        
             .',NULL,'Xataka',0.9,'es',NULL,'2026-09-16T14:46:11+00:00','2026-09-16T19:40:39+00:00',64,53.4,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(65,'tech','https://www.xataka.com/magnet/madrid-ha-batido-otro-record-numero-reclamaciones-que-ha-recibido-su-metro','5d76140aabce97c690e530ee9fcc905f9dee9a20','Madrid ha batido otro récord: el número de reclamaciones que ha recibido su metro','Imagina la escena (aunque no hace falta, porque los datos dicen que lo han vivido decenas de miles de personas): subes al metro y el aire acondicionado parece que no funciona en el vagón. Te desplazas tambaleándote y tampoco va en el siguiente. Empiezas a sudar a chorros. Dentro hace 32 grados y fuera, Madrid encadena una de las noches más calurosas de su historia. Algún que otro pasajero empieza a bufar y amenazar. Otro, directamente coge el móvil y redacta una reclamación. Esa escena se repitió miles de veces durante verano.

Junio de 2026 cerró con 3.753 reclamaciones contra Metro de Madrid, la cifra mensual más alta desde que el operador publica estos datos de forma homogénea, y el triple que el mismo mes de 2025. Los datos oficiales de reclamaciones (referencia PA011, el canal de quejas del Consorcio Regional de Transportes) muestran que entre enero y mayo la curva ya venía en ascenso, de 1.004 a 1.687 reclamaciones mensuales. Pero el salto de junio, con 3.753, no tiene precedente. ¿Qué pasó?

Quién manda en las quejas. Dentro de esas 3.753 reclamaciones, los usuarios citaron 4.401 motivos distintos, porque una misma queja puede señalar varias causas a la vez. Casi la mitad, el 47%, apuntó a la temperatura de los trenes. Sumando también las quejas por temperatura en estaciones, el calor aparece mencionado en el 56% de todas las reclamaciones del mes. Nada se le acerca: la segunda causa más citada, la frecuencia de trenes, se queda en el 19%.

La comparación año contra año resulta todavía más elocuente. En junio de 2025 Metro recibió 540 quejas por la temperatura de los trenes. Un año después, 2.073: casi se cuadruplicaron. Y no es un pico aislado. Según la memoria de sostenibilidad del propio operador, esas reclamaciones se multiplicaron por cinco entre 2023 y 2025, de 464 a 2.088 al año, mientras las quejas por frecuencia casi se duplicaron, de 2.498 a 4.725.

Junio aciago. El detonante: la ola de calor que azotó España entre el 21 y el 24 de junio fue, según la Agencia Estatal de Meteorología, la más intensa registrada en un mes de junio desde 1950, con anomalías de hasta 7,1 grados sobre la media y máximas que rozaron los 44 grados en algunos puntos. Dentro de un vagón sin climatización eficaz, eso se traduce en un horno rodante.

No es la primera vez: en julio de 2019, con otra ola de calor histórica en Europa, Metro registró 3.901 reclamaciones en un mes, única cifra que todavía supera a la de este junio. Metro reconoce el problema, de hecho. Invirtió 3,5 millones de euros para reforzar la climatización de 93 trenes en las líneas 1 y 5, reactivó equipos de refrigeración en 20 estaciones y desactivó la apertura automática de puertas en verano para conservar el frío. Asociaciones vecinales replican que, pese a todo, los vagones bordean y brincan los 32 grados en hora punta.


 
  
   
    
     
    
   
   
    
     En Xataka
    
    Todo lo que pueda pasarle a un tren en Extremadura, le pasará: Renfe se ha quedado sin aire acondicionado por el calor
   
  
 

Una app. Hartos de repetir la misma queja sin respuesta efectiva, algunos viajeros decidieron organizarse. Un ingeniero de telecomunicaciones y usuario habitual de la Línea 1, Nacho González, lanzó en julio la web Termo de Madrid, una herramienta ciudadana que convirtió los avisos en un índice de 0 a 100 por línea, clasificando cada trayecto de más confortable a más asfixiante y dando menos peso a los reportes antiguos.
En sus primeros días recibía una veintena de avisos diarios; tras aparecer en varios medios, llegó a acumular 400 reportes en una sola jornada. La Línea 1 concentra la mayoría de las quejas, algo lógico: mueve más de 100 millones de viajes al año en una red que en 2025 batió su récord histórico, con 736,8 millones de desplazamientos. En la última consulta, la web acumula más de cinco mil quejas que tildan algunas líneas de “infierno”.


 
                   
   
   
      

El otro sospechoso. Menos frecuencia, más aglomeración, el calor no explica todo. Las quejas por frecuencia de trenes también crecieron un 36% en junio respecto a 2025, de 619 a 844, y buena parte del malestar apunta a las obras de automatización de la Línea 6, criticadas en redes por reducir el espacio en los andenes y espaciar más los convoyes. Metro defiende que nunca tuvo tantos trenes circulando a la vez, cerca de 330 en hora punta, lo que permite frecuencias de entre 2 y 4 minutos.
Lo que cambia en octubre. Al margen del calor, Metro también prepara novedades tarifarias. Desde el 1 de octubre, el billete sencillo en toda la Zona A costará un precio único de 1,50 euros, sin importar las estaciones recorridas: desaparece el recargo de 10 céntimos por parada a partir de la quinta, que hoy puede encarecer un trayecto largo hasta los 2 euros.


 
  
   
    
     
    
   
   
    
     En Xataka
    
    400 cámaras y un objetivo ambicioso: el primer metro conducido de forma 100% autónoma en la Comunidad de Madrid
   
  
 

El cambio, anunciado por Isabel Díaz Ayuso durante el Debate del Estado de la Región, iguala el precio que ya regía desde junio para quienes pagaban con tarjeta bancaria directamente en el torno, el mismo mes en que las quejas por pago electrónico se dispararon de 31 a 400. Las nuevas máquinas expendedoras, además, incorporarán asistencia por videollamada para resolver dudas al comprar el billete.

Como parte de la Plataforma Centralizada de Información al Viajero (herencia del proyecto Estación 4.0), la Comunidad de Madrid también está preparando novedades en las máquinas de billetes. De momento, la novedad llega a 209 máquinas distribuidas por más de 70 vestíbulos y el servicio después se ampliará a otras 144 máquinas.

Salud y respuestas. El informe de vigilancia epidemiológica del Instituto de Salud Carlos III estableció umbrales críticos de mortalidad por zonas —35,9 °C en el área Metropolitana y Henares— a partir de los cuales se dispara el riesgo de muerte, confirmando que la mortalidad no depende solo de la intensidad del calor sino de su superación local de estos umbrales. El estudio de la Universidad Complutense de Madrid sobre olas de calor y salud humana concluyó que temperaturas nocturnas por encima de 20 °C elevan significativamente el riesgo de mortalidad en adultos. En la misma línea, el Observatorio de Salud y Medio Ambiente de DKV cuantificó el impacto sistémico del calor sobre la comorbilidad: cada grado adicional incrementa un 18% la morbilidad general y un 35% la mortalidad, dispara un 43% los casos de ansiedad y un 26% los de depresión.

Metro atribuye el alza generalizada de reclamaciones al "crecimiento sin precedentes de la demanda". Más gente, más quejas. Esa Gran Diagonal responde en parte a las nuevas necesidades. Sin embargo, esto no explica que los vagones hayan alcanzado temperaturas que se acercan a ese peligroso umbral de riesgo de muerte.

Imágenes | Pexels (Víctor de Donpablo)

En Xataka | Los expertos coinciden: “Hay fundamentos jurídicos que justifican que Renfe devuelva el dinero si viajas sin aire acondicionado"


                 -  La noticia
      
        Madrid ha batido otro récord: el número de reclamaciones que ha recibido su metro 
      
      fue publicada originalmente en
      
        Xataka 
      
             por 
               
        Isra Fdez
        
             .',NULL,'Xataka',0.9,'es',NULL,'2026-09-16T14:30:12+00:00','2026-09-16T19:40:39+00:00',65,53.3,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(66,'tech','https://www.xataka.com/robotica-e-ia/nueva-idea-uno-creadores-chatgpt-ia-que-no-sabe-escribir-esa-precisamente-su-ventaja','d4f2c2e34af8245b214784e182752cfc3e803942','La nueva idea de uno de los creadores de ChatGPT es una IA que no sabe escribir. Esa es precisamente su ventaja','Diogo Almeida no es un emprendedor de IA cualquiera. Trabajó en OpenAI y fue uno de los autores de InstructGPT, el estudio sobre aprendizaje por refuerzo a partir de retroalimentación humana (RLHF) que sentó parte de las bases de ChatGPT. Cuatro años después ha creado una nueva empresa llamada TypeSafe AI y un nuevo modelo llamado Jev. Lo curioso es que este modelo sacrifica justo aquello que hizo famoso a ChatGPT: no puede generar texto.

Una IA que habla con las máquinas. Cuando un LLM (como GPT-5.6 Sol, por ejemplo, que usamos en ChatGPT) recibe una pregunta y construye una respuesta, lo hace generando un token detrás de otro como un "loro estocástico". Jev está diseñado para otra cosa: este modelo recibe información no estructurada y devuelve decisiones acompañadas de probabilidades. Por ejemplo: en una transacción un programa o aplicación podría preguntarle a Jev si dicha transacción puede ser fraudulenta, si requiere una revisión humana y qué prioridad tiene esa alerta. Jev no se enrolla: simplemente devuelve las opciones permitidas y cuánto "confía" en cada una.


 
  
   
    
     
      
      
      
      
     
    
   
   
    
     Las suscripciones de IA son un chollo insostenible: 200 dólares al mes dan acceso a 14.000 dólares en tokens
         
   
  
 

De dónde viene el nombre. "Jev" es una referencia al economista inglés del s. XIX, William Stanley Jevons, que es conocido por la paradoja de Jevons. Según dicha teoría, la eficiencia tecnológica del uso del carbón no redujo su consumo, sino que lo incrementó. Eso ha acabado convirtiéndose en una paradoja trasladable al mundo tecnológico y en concreto a esta idea. El objetivo es que una mayor eficiencia en generación de tokens no reducirá su consumo, sino que lo incrementará aunque los precios bajen. En la era de los agentes de IA parece una afirmación plausible.

Mucho más rápido y barato. Al no tener que escribir una respuesta palabra por palabra, TypeSafe asegura que puede calcular muchísimas decisiones en paralelo. La compañía habla de entre 20 y 200 veces más velocidad y entre 40 y 400 veces menor coste que los modelos de IA habituales para estas tareas. El precio: 42 dólares por cada 1.000 millones de tokens de entrada (0,042 dólares por millón de tokens), pero lo curioso es que los "tokens de salida" son gratuitos porque resultan "demasiado baratos" para medirlos. 

Jev no habla, decide. En una de las demostraciones publicadas en el anuncio oficial, Jev jugaba a Doom tomando unas diez decisiones por segundo por aproximadamente siete dólares la hora. En otro escenario, intentaba llegar de un artículo de Wikipedia a otro escogiendo repetidamente entre decenas de enlaces. El modelo no necesita hablar, sino decidir y volver a decidir inmediatamente después.


 
                   
   
   
      

Jev teóricamente no puede alucinar... Si un desarrollador define en su plataforma que una respuesta solo puede ser "bajo", "medio" o "alto", la arquitectura del modelo garantiza que Jev no se inventará una cuarta opción ni devolverá un formato incorrecto. Gracias a ello en TypeSafe afirman que Jev tiene una tasa de alucinaciones del 0%, aunque reconocen que no es una cifra empírica. 

... pero hay letra pequeña. Lo que no aseguran es que Jev conteste "alto" cuando la respuesta correcta era "bajo". Su nueva técnica, llamada Reinforcement Learning for Calibrated Decisions (RLCD) precisamente está diseñada para que las probabilidades reflejen de forma correcta esa incertidumbre, pero de momento no hay un paper reproducible ni evaluaciones independientes que permitan validar esa afirmación.

¿Es esto realmente una revolución? Los LLM actuales ya pueden por ejemplo producir archivos JSON, ajustarse a ciertos esquemas y limitar sus respuestas a un conjunto predeterminado de opciones. Amjad Masad, CEO de Replit, se planteó una pregunta interesante: Si conocemos de antemano todas las respuestas posibles, ¿por qué no entrenar un modelo para producir sus probabilidades? Además, los mejores resultados de Jev provienen de evaluaciones diseñadas por la propia empresa, algo que ellos reconocen que pueden favorecer sus resultados en cuanto coste y velocidad. Quienes han podido probarlo parecen estar muy contentos con su capacidad.


 
  
   
    
     
    
   
   
    
     En Xataka
    
    La “economía de los tokens” se ha roto: las tarifas planas de IA para programar son matemáticamente insostenibles 
   
  
 

Decisiones, decisiones. Cuando hablamos con ChatGPT es de esperar que el modelo nos exlique con detalle su respuesta de (por ejemplo) por qué una transacción parece fraudulenta. En realidad el programa que debería enviarla para revisarla solo necesitaría una decisión "revisar" y una probabilidad (80%, por ejemplo). Jev hace que sea totalmente innecesario que un humano lea la respuesta.

No sustituye a ChatGPT, sino que lo complementa. Lo mismo sucede constantemente con operaciones que simplemente deben escoger continuamente su próxima acción. Aquí es donde entra Jev, que no pretende sustituir a ChatGPT. En lugar de eso, la apuesta es que parte de la futura IA ni siquiera tenga que parecerse a un chatbot. La idea, como poco, es intrigante.

En Xataka | En China los tokens de IA son los nuevos puntos de fidelización: te los regalan por comer, beber o usar una tarjeta


                 -  La noticia
      
        La nueva idea de uno de los creadores de ChatGPT es una IA que no sabe escribir. Esa es precisamente su ventaja  
      
      fue publicada originalmente en
      
        Xataka 
      
             por 
               
        Javier Pastor
        
             .',NULL,'Xataka',0.9,'es',NULL,'2026-09-16T14:16:11+00:00','2026-09-16T19:40:39+00:00',66,53.1,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(67,'tech','https://www.xataka.com/analisis/midea-portasplit-analisis-caracteristicas-precio-especificaciones','584a4cb3d5b534abb3ffab7192962ef8f30378a2','Midea PortaSplit, análisis: un aire acondicionado portátil que combina lo mejor de un split y de un pingüino','Cuando me he topado con algún aire acondicionado portátil normalmente me encuentro con un aparato ruidoso, ineficiente y pocas veces son capaces de enfriar una habitación en condiciones. Y tiene todo el sentido del mundo, ya que debido a su propia naturaleza y funcionamiento, nunca pueden rendir tan bien como un aire acondicionado split de pared propiamente dicho.

El PortaSplit de Midea intenta acortar esa distancia tomando prestada la fórmula del split (una unidad interior y una unidad exterior conectadas mediante tubos), pero manteniendo todo de forma independiente, de modo que puedes poner la unidad en funcionamiento en casa sin necesidad de un instalador, un taladro ni un agujero en la pared.

Durante estos meses de verano he podido probar este aparato en profundidad y bajo estas líneas te cuento qué me ha parecido.

✅ Cómpralo si...Vives en un lugar donde el aire acondicionado no se da por sentado por defecto, desde una vivienda de alquiler a una población en la que los hogares no están preparados para instalarlo.No puedes (o no quieres) instalar una unidad fija.Quieres un rendimiento cercano a una unidad split con la versatilidad de un pingüino y no te importa pagar un sobreprecio por ello para tener un aire portátil sin tubos corrugados. ❌ No lo compres si...Vives en un lugar cálido donde tener un aire acondicionado split fijo es más común.Tienes un presupuesto ajustado, pues es una opción considerablemente más cara que una unidad portátil convencional.Esperas una experiencia completamente de "enchufar y olvidarse" sin concesiones. Sigue siendo una máquina portátil, y eso conlleva ciertos matices.Lo esencial en 30 segundosEl Midea PortaSplit es un aire acondicionado portátil de dos piezas, con una unidad interior que se coloca en la habitación y una unidad exterior que se ubica fuera de la ventana, unidas por una manguera flexible plana que transporta tanto el refrigerante como el agua de condensación y el cableado eléctrico. La manguera viene acoplada de serie y está diseñada para que no se pueda retirar. 

Esta configuración es la clave de la diferencia entre este aparato y un aire acondicionado portátil de tipo pingüino de los de toda la vida, pues dado que el intercambio de calor ocurre realmente fuera, el sistema no vuelve a introducir aire caliente en la habitación como lo hacen los portátiles convencionales.


 
  
   
    
     
    
   
   
    
     En Xataka
    
    Adiós a derretirte de calor en casa: cinco aires acondicionados portátiles sin obra ni instalación ideales para tu hogar 
   
  
 

Es un aparato voluminoso, visiblemente más grande que cualquier portátil de un solo tubo que hayas visto probablemente, pero la instalación es sorprendentemente sencilla, ya que puedes poner en funcionamiento la máquina sin taladrar, sin instalador profesional y viene con soportes para colgar la unidad exterior fuera de la ventana. Además, puedes controlar el aire a través del panel físico, del mando a distancia incluido o de la aplicación de Midea.
Tiene un precio de unos 1.299 euros, por lo que lo sitúa bastante por encima de lo que pagarías normalmente por un aire acondicionado portátil, e incluso de algunos split fijos tradicionales, así que esto es un factor a tener en cuenta para decidir si realmente tiene sentido para ti.



 
  
 
     
   
  
   Midea Portasplit Aire Acondicionado Portatil 4 en 1 | 3000 frigorías / 12000 BTU | Split sin Obra de Bajo Consumo con modo Silence, App/Wifi, Deshumidificador, Calefacción y Ventilador hasta 45 m2
   
         
             

      Hoy en El Corte Inglés —       1.104,15 €
 
                      

       Amazon —       1.299,99 €
 
              
           
  
 
 El precio podría variar. Obtenemos comisión por estos enlaces


Nuestra experiencia con el Midea PortaSplit
 
                   
   
   
      

Montar y encender. Físicamente, el PortaSplit no se parece a nada que seguramente hayas visto dentro de la categoría. Y es que en lugar de una gran caja con un solo tubo de evacuación, tienes dos unidades separadas y unidas por una manguera flexible por donde circulan toda la circuitería y tubos de refrigeración, algo muy similar a un sistema split de pared, con la diferencia de que ninguna unidad se encuentra completamente fija.

El frío (o calor) llega más rápido. La ventaja en este sentido es que, al encargarse la unidad exterior del intercambio de calor propiamente dicho, la habitación se acaba enfriando bastante más rápido y mantiene la temperatura de forma mucho más constante. A pesar de que igualmente tengas que tener un hueco abierto para que el tubo pueda salir al exterior.


 
     
                   
   
   
        Unidad exterior anclada al soporte de ventana del Midea PortaSplit
   
   

Experiencia de Split fijo, sin el fijo. Por su particular diseño, podríamos decir que es un pingüino venido a más. Por su funcionamiento y precio, tiene más en común con un split fijo, pero sin tener que colocarlo en la pared, luego es un plus si buscas versatilidad y no puedes hacerte con una máquina fija en casa. Por sus especificaciones nos encontramos con una máquina tremendamente capaz, pues en cuestión de pocos minutos tendrás la habitación fresquita (incluso aunque haya que dejar una rendija abierta en la ventana). La máquina puede pecar de ruidosa en sus modos más exigentes, pero cuando no quiere hacer ruido en sus modos más silenciosos, cumple de sobra.

Junto a la ventana. Lo bueno es que el aparato es muy sencillo de instalar, ya que no necesitas más herramientas que las que vienen en la caja, y la unidad exterior se engancha a un soporte fuera de la ventana en cuestión de minutos. El tubo es de unos dos metros, así que tampoco puedes separar demasiado la unidad interior de una ventana o puerta que de al exterior. Eso hace que tengas que pensar muy bien dónde colocarlo, ya que inevitablemente tendrá que estar junto a un lugar que de al exterior para colocar la máquina que va fuera de casa. 

Completo en accesorios, pero cuidado. Donde se queda corto es en el kit de sellado para la ventana. Todavía tienes que dejar la ventana ligeramente abierta para que pase la manguera, y el accesorio de plástico que se pega a la ventana y se ata con una cinta adhesiva de tipo Velcro para mantener la ventana lo más sellada posible se me ha despegado varias veces, por lo que no resulta muy fiable. En la caja también se incluyen unas fajas con cremallera para aislar todos los huecos que queden abiertos. No me hizo falta colocarlas, pero viene bien tenerlas como opción por si acaso.


 
                   
   
   
      

Versatilidad y control. Además de refrigerar, también cuenta con modos de calefacción, deshumidificador o ventilador simple, así que es un aparato que te puede servir para cualquier momento del año. En cuanto al control, dispones de los botones del propio aparato, un mando a distancia bastante decente con luz en la pantalla e interfaz sencilla, y una app complementaria que puedes descargar para controlar el aire a distancia y otras opciones interesantes.


 
     
                   
   
   
        Uno de los accesorios que se incluyen en la caja: una cinta adhesiva de tipo Velcro que se pega al marco de la ventana y a la propia ventana para sellar la puerta lo máximo posible
   
   

No es un pingüino, es algo mejor. Las máquinas de aire portátiles que enfrían a partir de agua y un tubo corrugado (un pingüino de toda la vida) son bastante más económicas precisamente por cómo funcionan. No hay una máquina exterior que les permita rendir como un aire acondicionado propiamente dicho, pero el Midea PortaSplit sí lo consigue, precisamente porque tiene lo mejor de un pingüino (portabilidad), con lo mejor de un split fijo (potencia y forma de funcionar). 

El tamaño engaña. A pesar de ser portátil, no hay que infravalorar su tamaño y peso, así que debemos pensar bien dónde colocarlo. Lo bueno es que va con ruedas, así que una vez que lo saques de la caja (que no es moco de pavo, precisamente), irá rodado. Por otro lado, y como ocurre igual en los pingüinos, el sellado alrededor de la ventana nunca va a ser tan hermético como una instalación de pared adecuada. Además, también está el tema del precio, pues a 1.299 euros no es un aparato especialmente barato. Y está claro que no es un mal producto desde luego, ya que el rendimiento y funcionamiento del PortaSplit es sencillamente top, pero sí merece la pena darle una pensada para determinar si es la opción que necesitas.

Ficha técnica del Midea PortaSplit
 
  
       
        
                 
       
      
                 
       midea portasplit
      
    
 
    
      
          
                 
       Alimentación
      
                 
       220–240 V~, 50 Hz, 1 Ph
      
    
   
                 
       Potencia de entrada nominal / Corriente	
      
                 
       1500 W / 7 A
      
    
   
                 
       Capacidad de refrigeración	
      
                 
       3,5 kW (5,5 A, 1230 W de entrada)
      
    
   
                 
       Capacidad de calefacción	
      
                 
       3,5 kW (4,3 A, 950 W de entrada)
      
    
   
                 
       Eficiencia energética	
      
                 
       A++ / SEER 6,1 · A+ / SCOP 4,0
      
    
   
                 
       Refrigerante	
      
                 
       R32, 0,62 kg
      
    
   
                 
       Presión máxima de funcionamiento	
      
                 
       4,4 MPa (44 bar)
      
    
   
                 
       Clasificación IP de la unidad exterior	
      
                 
       IPX4
      
    
   
                 
       Dimensiones unidad interior
      
                 
       646 x 518 x 340 mm
      
    
   
                 
       Dimensiones unidad exterior
      
                 
       438 x 500 x 260 mm
      
    
   
                 
       Peso neto	
      
                 
       45,5 kg
      
    
   
                 
       Ruido interior (Alto/Medio/Bajo/Silencioso)	
      
                 
       49/47/44/39 dB
      
    
   
                 
       Ruido interior (Alto/Medio/Bajo/Silencioso)	
      
                 
       56/48 dB
      
    
   
                 
       Área máxima de la habitación	
      
                 
       42 m²
      
    
   
                 
       Precio	
      
                 
       1.299 euros
      
    
 
      
  
 



 
  
 
     
   
  
   Midea Portasplit Aire Acondicionado Portatil 4 en 1 | 3000 frigorías / 12000 BTU | Split sin Obra de Bajo Consumo con modo Silence, App/Wifi, Deshumidificador, Calefacción y Ventilador hasta 45 m2
   
         
             

      Hoy en El Corte Inglés —       1.104,15 €
 
                      

       Amazon —       1.299,99 €
 
              
           
  
 
 El precio podría variar. Obtenemos comisión por estos enlaces


Midea PortaSplit, la opinión de Xataka
 
                   
   
   
      

El PortaSplit cumple lo que se propone, pues ofrece un rendimiento de refrigeración más cercano al de un split real que al de un portátil estándar, sin pedirte que taladres un solo agujero en la pared. Enfría la habitación de forma muy eficiente y cuenta con varios modos de operación, incluyendo calefacción, deshumificador y ventilador. Además, es super sencilla su instalación. Los accesorios que vienen incluidos en la caja para sellar la ventana dejan algo que desear, pero son bastante útiles.

¿Te lo recomiendo?Sí, siempre que una instalación permanente no sea una opción real para ti. Su funcionamiento es mucho más eficaz que cualquier máquina portátil de tipo pingüino, básicamente porque funciona como un split fijo, es decir, con una máquina externa funcionando a todo trapo para que dentro estés muy fresquito (o muy caliente). No es nada ruidoso si habilitamos sus modos más silenciosos, y rinde sobrado para enfriar o caldear una habitación de tamaño medio en cuestión de pocos minutos. 

En Xataka | El aire acondicionado ya no es suficiente para soportar el calor. Hay una alternativa: la refrigeración centralizada

Este dispositivo ha sido cedido para prueba por parte de Midea. Puedes consultar cómo hacemos las reviews en Xataka y nuestra política de relaciones con empresas.


                 -  La noticia
      
        Midea PortaSplit, análisis: un aire acondicionado portátil que combina lo mejor de un split y de un pingüino 
      
      fue publicada originalmente en
      
        Xataka 
      
             por 
               
        Antonio Vallejo
        
             .',NULL,'Xataka',0.9,'es',NULL,'2026-09-16T14:00:13+00:00','2026-09-16T19:40:39+00:00',67,53.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(68,'tech','https://www.xataka.com/ecologia-y-naturaleza/llevamos-anos-diciendo-que-nino-apenas-afecta-a-espana-no-verdad-nos-golpea-donde-nos-fijamos','cf99c781ca0b126e069b1dcbc761dfebb38a9bf2','Llevamos años diciendo que El Niño apenas afecta a España. No es verdad: nos golpea donde menos nos fijamos','A 8.000 kilómetros de la península Ibérica, en el estado indio de Andhra Pradesh, ha llovido un 44% menos de lo normal. Empujado por un El Niño que ya ha entrado en la categoría de "muy fuerte", los medios hablan del peor monzón en once años. El asunto es que eso es quedarse corto. 

Lo sabemos porque sabemos cuanto cuesta el arroz y empezamos a ver señales.

A veces, nos apresuramos a decir que El Niño no tiene un efecto directo en nuestro país y no siempre es cierto. Aquí tienen el mejor ejemplo.

Volvamos a España. Estos días las cosechadoras estarán entrando en las marismas del Guadalquivir. Sevilla ha sembrado el 100% de sus 36.500 hectáreas de arroz por segundo año consecutivo y eso es mucho decir. En 2023, no se sembró ninguna. 

El problema que tenían los agricultores era que en los silos aún queda el 40% de la cosecha del año pasado. "No hay mercado", decía Eduardo Vera, de la Federación hace apenas un mes. Y es verdad: a diferencia de lo que pasó en otras crisis, el mercado ahora mismo está por los suelos.


 
  
   
    
     
    
   
   
    
     En Xataka
    
    "El Niño más intenso que cualquier otro en los últimos 1.000 años": los expertos no tienen claro qué va a pasar, pero las señales de alerta no dejan de acumularse 
   
  
 

¿Por los suelos? En octubre de 2025 el arroz indio tocó mínimos que no se habían visto en nueve años. La India cerró el año con 57,57 millones de toneladas de arroz en el país, un récord histórico. Solo la Food Corporation of India guardaba 33,59 millones de toneladas de arroz, el triple de la reserva normal.

¿Entonces no hay problema, no? Por mucho que baje la producción de arroz este año, tenemos un enorme colchón para protegernos. O eso podríamos pensar. Pero ahí está la trampa.

Lo que pasó en 2023. En agosto de 2023, el arroz tailandés se fue a 648 dólares, máximo en 15 años. Medio mundo, como es normal, lo atribuyó a El Niño. Sin embargo, la historia no fue esa. 

Lo que ocurrió en 2023 fue que, en año preelectoral, India prohibió las exportaciones de arroz blanco no basmati. Fue eso lo que disparó los precios y no el clima. Por eso, la pregunta central hoy es qué hará La India. Lo hemos dicho muchas veces: "es geopolítica, no climatología". 

¿Y qué tiene que ver todo esto con España? El arroz español compite directamente con el arroz indica asiático y precisamente esa es una las vías por las que El Niño impacta en nuestro país. Hay muchas más que no salen en los medios. El azúcar subió un 11,9% en agosto, los aceites vegetales están en máximos desde 2022 y Perú ha cerrado antes de tiempo la temperada de la anchoveta, un elemento clave en los piensos que comen nuestras granjas de cerdos y nuestras picisfactorías. 

Mientras La India quiera, el arroz no será un problema. El problema es una cadena de suministro cada vez más global y cada vez más débil. 

Imagen | BenBaso

En Xataka | Hacía 85 años que el Atlántico no estaba tan calmado sin un solo huracán. Pero no es lo que vemos, es lo que está pasando justo debajo


                 -  La noticia
      
        Llevamos años diciendo que El Niño apenas afecta a España. No es verdad: nos golpea donde menos nos fijamos  
      
      fue publicada originalmente en
      
        Xataka 
      
             por 
               
        Javier Jiménez
        
             .',NULL,'Xataka',0.9,'es',NULL,'2026-09-16T13:46:11+00:00','2026-09-16T19:40:39+00:00',68,52.9,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(69,'tech','https://www.xataka.com/magnet/letras-df-15a-han-aparecido-restos-misil-yemen-todo-apunta-al-secreto-mejor-guardado-arsenal-saudi','a7d046bf56e2ee3fcf8d5fe57e6f123809159987','Las letras “DF-15A” han aparecido entre los restos de un misil en Yemen. Todo apunta al secreto mejor guardado del arsenal saudí','Unos restos de misil han aparecido en una zona de Yemen castigada por los combates. Hasta ahí, nada especialmente extraño en un país que lleva años viendo caer drones y misiles de diferentes procedencias. Pero una inscripción visible sobre uno de los fragmentos ha convertido el hallazgo en algo mucho más interesante: “DF-15A”. Es el nombre de un misil balístico que oficialmente solo opera una nación y cuya presencia en Arabia Saudí nunca había sido reconocida. 

Todo empieza con unas letras. Contaban los analistas de TWZ que los vídeos difundidos durante los últimos días muestran lo que parece ser parte del motor propulsor de un misil balístico localizado en el distrito de Raghwan, en la gobernación yemení de Marib, aproximadamente a 170 kilómetros por carretera de Saná. Lo extraordinario está escrito directamente sobre el fragmento: “DF-15A”, la denominación de una variante del misil balístico chino Dong Feng 15. 

Las imágenes han circulado también sin censurar por medios digitales chinos, pero ni Arabia Saudí ni los hutíes han reconocido utilizar este modelo y la identificación realizada a partir de los restos todavía no constituye una confirmación oficial. Eso convierte el hallazgo en una pista extraordinariamente sugerente, aunque no todavía en una prueba definitiva de quién lanzó el misil.


 
  
   
    
     
    
   
   
    
     En Xataka
    
    Ucrania tiene un plan sin precedentes para combatir los misiles de Rusia: convertir el porno en 30.000 drones de combate
   
  
 

Solo lo tenía Pekín. El DF-15, denominado CSS-6 por la OTAN, nació durante los años 80 como un misil balístico de corto alcance, móvil y propulsado mediante combustible sólido, características que permiten prepararlo y dispararlo con mayor rapidez que sistemas antiguos de combustible líquido. Las estimaciones sobre su alcance varían según las versiones y las fuentes, desde alrededor de 600 kilómetros para modelos iniciales hasta cifras cercanas a los 900 kilómetros para variantes posteriores, mientras que el DF-15A habría entrado en servicio chino durante los años 90. 

Durante décadas han aparecido informaciones sobre posibles transferencias de miembros de esta familia o del relacionado M-9 a países como Egipto, Pakistán o Siria, pero ninguna ha establecido de manera concluyente la exportación del DF-15A. China continúa siendo, por tanto, su único operador confirmado.


 
  
   
  
 

El principal sospechoso. Todos los caminos apuntan al mismo sitio. La posibilidad de que los restos procedan de Arabia Saudí resulta especialmente interesante porque Riad ya protagonizó una operación muy similar hace casi cuatro décadas. A finales de los años 80 adquirió secretamente a China misiles balísticos DF-3A, enormes armas de alcance intermedio que proporcionaron al reino una capacidad estratégica terrestre mantenida durante mucho tiempo fuera del foco público. 

Años después, imágenes por satélite y otras fuentes abiertas relacionaron instalaciones saudíes con sistemas chinos de la familia DF-21, mostrando que aquella primera compra no había sido necesariamente un episodio aislado. El DF-15A encajaría en esa relación histórica entre ambos países, pero hasta la aparición de estos restos no existía evidencia pública conocida que situara este modelo concreto dentro del arsenal saudí.


 
                   
   
   
      

Lo que no sabemos. La localización del fragmento y la historia armamentística saudí apuntan hacia Riad, pero existen todavía incógnitas clave. Los hutíes disponen de un amplio arsenal de misiles balísticos construido alrededor de sistemas y tecnología iraní, armas yemeníes capturadas y diseños modificados localmente, pero no se les conoce acceso al DF-15ª. Arabia Saudí, en cambio, sí tiene antecedentes documentados de adquisición secreta de misiles Dong Feng chinos. 

Tampoco está claro qué ocurrió durante el vuelo: el fragmento podría corresponder a una separación producida durante la trayectoria o a un misil que se desintegró o cayó antes de alcanzar su objetivo. Los hutíes no tienen públicamente reconocido un sistema capaz de explicar con claridad una eventual interceptación, mientras que durante esas fechas se habían registrado ataques aéreos saudíes en Marib y otras regiones yemeníes.


 
                   
   
   
      

Por qué es importante si es saudí. Como decíamos, Arabia Saudí posee misiles balísticos chinos desde finales de los años 80, pero no existen registros confirmados de que los haya empleado en combate, ni siquiera durante su larga intervención en Yemen iniciada en 2015. Utilizar un DF-15A supondría introducir una herramienta diferente a los ataques realizados mediante aviación: un misil de combustible sólido puede lanzarse rápidamente, alcanzar objetivos situados a cientos de kilómetros en pocos minutos y hacerlo sin exponer aviones y tripulaciones a las defensas aéreas enemigas. 

Su tamaño también permite transportar una carga considerable contra objetivos fijos o reforzados. Por eso el verdadero salto no sería únicamente descubrir que Riad posee otro misil chino, sino comprobar que estaría dispuesto a sacar de las sombras una capacidad que durante décadas ha mantenido fundamentalmente como elemento estratégico.


 
  
   
  
 

Una pista muy significativa. Plus: el hallazgo se produce mientras vuelve a aumentar la intensidad del enfrentamiento entre Arabia Saudí y los hutíes después del periodo de relativa desescalada iniciado con la tregua de 2022. Las fuerzas hutíes han avanzado sobre posiciones del Gobierno yemení respaldado por Riad y han intensificado sus ataques con misiles y drones contra objetivos militares y energéticos del sur de Arabia Saudí, al tiempo que el estrecho de Bab el-Mandeb vuelve a adquirir una enorme importancia por su papel en las rutas energéticas del mar Rojo. 

En ese escenario, disponer de un misil balístico móvil y de combustible sólido proporcionaría a Arabia Saudí una opción de ataque rápido y a distancia contra objetivos dentro de Yemen. Dicho esto, hay que aclarar que aunque esa capacidad tenga sentido militar no demuestra que haya sido utilizada: los restos siguen siendo la pieza central sobre la que descansa toda la hipótesis.


 
  
   
    
     
    
   
   
    
     En Xataka
    
    Japón necesitaba un muro contra China y Corea del Norte. Su respuesta es un monstruo que flota, pesa 12.000 toneladas y tiene 128 celdas 
   
  
 

El gran secreto. Arabia Saudí nunca ha sido completamente transparente sobre su fuerza de misiles balísticos y algunas de sus capacidades más importantes solo se han conocido después, mediante imágenes por satélite, investigaciones y revelaciones sobre sus acuerdos con China. Ahora el proceso podría estar repitiéndose de una manera mucho más accidental: no mediante una fotografía de una base secreta, sino gracias a un fragmento abandonado después de un lanzamiento en Yemen.

Por supuesto, todavía falta demostrar que realmente pertenece a un DF-15A saudí, pero si esa conexión termina confirmándose como parece, esas cuatro letras habrán revelado dos cosas que hasta ahora desconocíamos: que Arabia Saudí consiguió en secreto uno de estos misiles chinos y que, después de décadas manteniendo buena parte de su arsenal balístico fuera de la vista, habría decidido utilizarlo en una guerra.

Imagen | X

En Xataka | Los insurgentes de Yemen no sabían hacer cohetes guiados con alcances de 2.000 kilómetros. Hasta que abrieron Claude

En Xataka | Anthropic reconoce que no puede descartar que Claude termine contribuyendo al desarrollo de armas biológicas




                 -  La noticia
      
        Las letras “DF-15A” han aparecido entre los restos de un misil en Yemen. Todo apunta al secreto mejor guardado del arsenal saudí  
      
      fue publicada originalmente en
      
        Xataka 
      
             por 
               
        Miguel Jorge
        
             .',NULL,'Xataka',0.9,'es',NULL,'2026-09-16T13:30:12+00:00','2026-09-16T19:40:39+00:00',69,52.8,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(70,'tech','https://www.xataka.com/espacio/nasa-ha-declarado-primera-vez-a-dos-astronautas-emeritos-seguro-que-sus-nombres-te-suenan','25fbc3efaab1ea8e363a39684b94d4606580d875','La NASA ha declarado por primera vez a dos astronautas eméritos y seguro que sus nombres te suenan','Viajar alrededor de la Luna y ver cómo la Tierra se pone detrás de ella, como el Sol cada tarde bajo nuestro horizonte, parece un buen broche de oro ideal para cualquier carrera profesional. Por eso, tres de los cuatro astronautas que componían la tripulación de Artemis II ya se han retirado de dicha profesión. Solo Christina Koch, la única mujer del equipo, ha decidido continuar su carrera. El miembro canadiense, Jeremy Hansen, dejó la agencia espacial de su país y los otros dos miembros de la NASA, Victor Glover y Reid Wiseman, piloto y comandante de la misión, se han convertido en los primeros astronautas del programa de eméritos de la NASA.
Casi un retiro. El término emérito hace referencia a una persona que abandona un puesto, pero puede seguir disfrutando de algunos de los privilegios del mismo o, en caso de que proceda, aportando sus servicios. En España, al hablar de eméritos la primera persona que nos viene a la mente es Juan Carlos I. Como rey emérito, dejó paso a su hijo como monarca, pero sigue disfrutando de algunos de los privilegios de la corona. Podríamos hablar mucho sobre este tema, pero lógicamente sería un desvío que no procede. Volviendo a los astronautas, como miembros eméritos de la NASA ya no estarán disponibles para viajes al espacio, pero la agencia podrá recurrir a ellos para entrenar a futuras generaciones de astronautas o compartir su valiosa experiencia como miembros del programa Artemis.
Sin remuneración. Según declaraciones de Victor Glover recogidas por Ars Technica, el servicio que ofrecerán a la NASA de aquí en adelante es gratuito. Con todo ello, el piloto de Artemis II ha declarado que planea estar presente en las simulaciones de entrenamiento y espera formar parte del establecimiento de una nueva iniciativa, la Academia Espacial de los Estados Unidos, al servicio de la NASA y la Fuerza Espacial de Estados Unidos. 


 
  
   
    
     
    
   
   
    
     En Xataka
    
    La NASA ha decidido que Artemis III ya no va a ir a la Luna. Aunque no lo parezca, es un paso hacia adelante
   
  
 

El futuro de los eméritos. Que dos astronautas sean eméritos de la NASA no quiere decir que se hayan jubilado por completo. De hecho, se sabe que Glover ya ha sido contratado para un puesto de liderazgo en su alma mater, la Universidad Politécnica Estatal de California, para contribuir en la definición de las estrategias a largo plazo del centro. Por su parte, Wiseman no ha hecho declaraciones sobre cuál será su próximo puesto más allá de la NASA.


 
     
                   
   
   
        Reid Wiseman y Victor Glover
   
   

Un puesto parecido. En realidad, estos dos astronautas son los primeros eméritos de la NASA. Sin embargo, antes existía ya un puesto similar, el de astronauta de gestión. Se trata de miembros de la agencia que ya no eran elegibles para participar en misiones, pero seguían considerándose valiosos como entrenadores o asesores. Por su parte, si querían presentarse a cargos públicos, unirse a empresas privadas o volver a la carrera militar, debían abandonar por completo la agencia. No existía este puesto intermedio en el que Glover y Weisman son ahora pioneros.
Esperemos que sus consejos se escuchen con atención. De momento, Victor Glover ya ha mostrado su desacuerdo con el lugar de alunizaje elegido para Artemis IV, pero no se han hecho declaraciones sobre cambios de rumbo en la NASA. Habrá que esperar para saber hasta qué punto participan realmente en las decisiones estos primeros astronautas eméritos. 
Imágenes | NASA
En Xataka | Artemis II no es solo una victoria de la NASA: sin el apoyo de Europa habría sido imposible, literalmente


                 -  La noticia
      
        La NASA ha declarado por primera vez a dos astronautas eméritos y seguro que sus nombres te suenan  
      
      fue publicada originalmente en
      
        Xataka 
      
             por 
               
        Azucena Martín
        
             .',NULL,'Xataka',0.9,'es',NULL,'2026-09-16T13:16:11+00:00','2026-09-16T19:40:39+00:00',70,52.6,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(71,'tech','https://www.xataka.com/seleccion/mejores-chollos-tecnologia-que-hemos-encontrado-amazon-hoy-16-septiembre-descuentos-70','79acc5ad1d0d3409726b220bff11b7388b2eaa79','Los mejores chollos en tecnología que hemos encontrado en Amazon hoy, 16 de septiembre: descuentos de hasta el 70%','Si estás pensando en comprar tecnología y quieres no arruinarte en el intento (y más ahora que la crisis de la RAM está encareciendo muchos dispositivos), Amazon es una de esas tiendas en las que se pueden comprar aparatos a buen precio. Estos son los mejores chollos en tecnología que hemos descubierto en Amazon hoy, 16 de septiembre.
Smartphone Xiaomi Poco F9 Ultra por 899,90 euros: de 6,9 pulgadas y con 512 GB.Adaptador inalámbrico para CarPlay y Android Auto por 29,99 euros: con WiFi de doble banda.Auriculares inalámbricos Soundcore Anker Space One por 69,99 euros: disponibles en cuatro colores.Smart TV Hisense 85U7SE por 1.259 euros: MiniLED de 85 pulgadas.Robot aspirador Lefant M210 por 99,99 euros: cuenta con un modo silencioso.

 
  
 
     
   
  
   Soundcore Anker Space One Auriculares Bluetooth ANC Adaptativa, LDAC, 40H
   
         
             

      Hoy en Amazon —       69,99 €
 
                    
           
  
 
 El precio podría variar. Obtenemos comisión por estos enlaces


Smartphone Xiaomi Poco F9 Ultra
 
                    
         
    
     
 
      

Si quieres un móvil con excelentes prestaciones, este Xiaomi Poco F9 Ultra es una buena opción hoy en Amazon. Su PVP recomendado es de 1.199,90 euros, pero ahora puedes llevártelo con un 25% de descuento, por 899,90 euros. Este smartphone destaca por su batería de 8.050 mAh con carga a 100 W, su sistema de sonido firmado por Bose y su pantalla de 6,9 pulgadas. Además, viene con una RAM de 16 GB y un almacenamiento interno de 512 GB.



 
  
 
     
   
  
   XIAOMI Poco F9 Ultra, 16+512, Cereza Oscuro, 8050mAh, Carga 100 W
   
         
             

      Hoy en Amazon —       899,90 €
 
                    
           
  
 
 El precio podría variar. Obtenemos comisión por estos enlaces


Adaptador inalámbrico para CarPlay y Android Auto 
 
                    
         
    
     
 
      

Si sueles usar mucho Android Auto y CarPlay en el coche y odias tener que conectar tu smartphone por cable cada vez que te subes en él, este pequeño gadget tiene ahora un 70% de descuento en Amazon y puedes comprarlo por 29,99 euros. Tan solo tienes que conectar este accesorio al puerto USB de tu vehículo y emparejarlo. Tras el primer emparejamiento, tu móvil se conectará automáticamente cuando arranques el vehículo. Funciona con WiFi de doble banda y su diseño mini hace que pase desapercibido.



 
  
 
     
   
  
   Adaptador CarPlay Inalámbrico para Coche
   
         
             

      Hoy en Amazon —       29,99 €
 
                    
           
  
 
 El precio podría variar. Obtenemos comisión por estos enlaces


Auriculares inalámbricos Soundcore Anker Space One
 
                    
         
    
     
 
      

Si te gusta escuchar música a todas horas y quieres aislarte del mundo para hacerlo, estos auriculares de diadema de Anker son un chollo hoy. Su precio recomendado es de 99,99 euros, pero ahora te los llevas con 30 euros de descuento, por 69,99 euros. Cuentan con cancelación de ruido adaptativa, están disponibles en cuatro colores (negro, azul, beige y rosa) y su batería dura hasta 40 horas con la ANC activada.



 
  
 
     
   
  
   Soundcore Anker Space One Auriculares Bluetooth ANC Adaptativa, LDAC, 40H
   
         
             

      Hoy en Amazon —       69,99 €
 
                    
           
  
 
 El precio podría variar. Obtenemos comisión por estos enlaces



 
  
   
    
     
    
   
   
    
     En Xataka
    
    Hoy en Action la solución a la falta de enchufes en casa para cargar tus dispositivos por 14,95 euros 
   
  
 

Smart TV Hisense 85U7SE
 
                    
         
    
     
 
      

Si quieres montarte tu propio cine en casa este otoño y tienes espacio de sobra en el salón, esta tele MiniLED de la firma Hisense de 85 pulgadas tiene ahora más de 700 euros de descuento. Cuesta 1.259 euros y cuenta con modo juego a 144 Hz nativos, subwoofer integrado y es compatible con formatos como Dolby Vision IQ y HDR1+ Adaptative.



 
  
 
     
   
  
   Hisense 85U7SE - MiniLED Smart TV 85 Pulgadas
   
         
             

      Hoy en Amazon —       1.259,00 €
 
                      

       PcComponentes —       1.467,19 €
 
              
           
  
 
 El precio podría variar. Obtenemos comisión por estos enlaces


Robot aspirador Lefant M210
 
                    
         
    
     
 
      

Si quieres tener tu hogar limpio sin esfuerzo, este robot aspirador de la firma Lefant es otro de los chollos del día hoy en Amazon. Su precio, en estos momentos, es de 99,99 euros y destaca por su potencia de 2.200 Pa, ofrecer una autonomía de hasta 120 minutos y por contar con un modo silencioso.



 
  
 
     
   
  
   Lefant M210 Robot Aspirador, 2200Pa, 120min, Suelos Duros, Modo Silencioso
   
         
             

      Hoy en Amazon —       99,99 €
 
                    
           
  
 
 El precio podría variar. Obtenemos comisión por estos enlaces



 
  
   
    
     
    
   
   
    
     En Xataka Smart Home
    
    El sábado, 19 de septiembre, llega a Aldi (por 59,99 euros) esta aspiradora vertical con luz verde y 130 W 
   
  
 

Algunos de los enlaces de este artículo son afiliados y pueden reportar un beneficio a Xataka. En caso de no disponibilidad, las ofertas pueden variar.

Imágenes | Lefant, Hisense, Anker, Ancvet y Xiaomi

En Xataka | Mejores relojes deportivos con GPS 2026: Cuál comprar y seis modelos recomendados

En Xataka | Los mejores ventiladores de mano ideales para decirle adiós al abanico


                 -  La noticia
      
        Los mejores chollos en tecnología que hemos encontrado en Amazon hoy, 16 de septiembre: descuentos de hasta el 70%  
      
      fue publicada originalmente en
      
        Xataka 
      
             por 
               
        Fran León
        
             .',NULL,'Xataka',0.9,'es',NULL,'2026-09-16T13:16:11+00:00','2026-09-16T19:40:39+00:00',71,52.6,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(72,'tech','https://www.xataka.com/movilidad/byd-tenia-barco-grande-mundo-para-transportar-sus-coches-ahora-va-a-diez','d3aa363738a04bcc1f4ca11c1d696a08d16b05cd','BYD ya tenía el barco más grande del mundo para transportar sus coches. Ahora va a por diez más','BYD está conquistando el panorama internacional con sus turismos dentro de un ecosistema cada vez más electrificado. Sin embargo, para seguir a ese vertiginoso ritmo hacen falta más barcos y más grandes que puedan transportar sus coches. Y en este sentido, la compañía está redoblando su apuesta por su propia flota de transporte marítimo.

Según cuentan desde New Ships, el fabricante de automóviles chino ha realizado un pedido de diez buques para transportar sus automóviles y camiones, cada uno capaz de transportar unos 9.200 vehículos. Así que todo apunta a que la división de logística marítima de la empresa está a punto de crecer considerablemente. Te contamos todos los detalles.

Sus propios barcos. Además de sus coches, BYD también construye los barcos que los transportan. Y esto es una gran ventaja para la compañía, ya que poseer una flota dedicada se carga de golpe uno de los mayores cuellos de botella a los que se enfrentan los fabricantes de automóviles chinos en este momento, que es precisamente la escasez mundial de capacidad de buques para transportar vehículos.

A medida que las exportaciones se disparan, tener el control total de la cadena logística otorga a BYD una gran ventaja que buena parte de sus competidores no posee, pues normalmente suelen alquilar sus propios espacios de carga.


 
  
   
    
     
    
   
   
    
     En Xataka
    
    El debate sobre la IA ya no enfrenta a optimistas y pesimistas. Enfrenta a empresas con miles de millones en juego 
   
  
 

En detalle. Según se informa, los nuevos buques serán construidos por China Merchants Industry en sus astilleros de Jinling y Haimen, con entregas escalonadas entre 2027 y 2029, según afirman desde New Ships. Una vez entregados, ampliarían la flota propia de BYD de ocho a 18 barcos, superando la capacidad total los 130.000 CEU (unidades equivalentes a automóviles).

La flota actual de la empresa se completó en menos de dos años, habiéndose entregado el primer barco, Explorer No. 1, en enero de 2024, según apuntan desde CarNewsChina.

Visto de cerca. Para poner la escala en perspectiva, el BYD Shenzhen, que zarpó en 2025, ya era el portavehículos más grande del mundo, con capacidad para 9.200 vehículos. La flota original de ocho barcos dio a BYD la capacidad de exportar alrededor de 1 millón de coches al año. Añadir diez buques más de tamaño similar elevaría aproximadamente esa cifra a 2,5 millones de coches al año, según las estimaciones de CarNewsChina.

Cifras. BYD exportó 184.000 vehículos de pasajeros desde China solo en agosto, un 131 % más interanual, según datos de la Asociación de Automóviles de Pasajeros de China. Eso representa más de un tercio de las exportaciones de vehículos de nuevas energías del país. De enero a agosto, BYD envió más de 1,1 millones de vehículos al extranjero, un 88 % más que en el mismo período del año anterior.

Sin embargo, en su propio mercado la cosa cambia drásticamente. Y es que la marca principal de BYD vendió 184.000 coches en China en agosto, un 35 % menos interanual, y las ventas nacionales en lo que va de año han bajado un 43 %, según CarNewsChina. La empresa se encuentra atrapada en medio de una brutal guerra de precios entre más de 100 marcas de vehículos eléctricos, y los márgenes de beneficio de todo el sector automotriz en China habrían caído a tan solo el 3,2 % en el primer trimestre de 2026.

Imagen de portada | BYD

En Xataka | China demuestra que no hace falta cambiar de química para mejorar las baterías de sus coches: llegan las baterías LFP de 200 Wh/kg


                 -  La noticia
      
        BYD ya tenía el barco más grande del mundo para transportar sus coches. Ahora va a por diez más  
      
      fue publicada originalmente en
      
        Xataka 
      
             por 
               
        Antonio Vallejo
        
             .',NULL,'Xataka',0.9,'es',NULL,'2026-09-16T13:00:12+00:00','2026-09-16T19:40:39+00:00',72,52.5,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(73,'tech','https://www.xataka.com/robotica-e-ia/mundo-tiene-razon-al-tener-miedo-ia-solucion-sam-altman-que-confiemos-quienes-estan-construyendo','702979c7fd83aa6e6bcc25b4c57200a8752dc11e','“El mundo tiene razón al tener miedo de la IA”. La solución de Sam Altman es que confiemos en quienes la están construyendo','Sam Altman, el CEO de OpenAI, ha hecho una declaración llamativa: "el mundo tiene razón al tener miedo de esto". Se refiere, cómo no, a la amenaza que plantea la IA y que hizo que su rival empresarial, Dario Amodei, dijera hace unos días que había que cambiar el ritmo de desarrollo de la IA. 

Fiaos de nosotros. Los modelos han avanzado tanto y tan rápido, asegura, que "ya no hace falta tanta imaginación" para pensar que algo podría salir mal. Sin embargo su solución a ese problema es una que ya conocemos: que nos fiemos de él: "el mundo debería confiar en que vamos a hacer lo correcto porque es lo correcto y porque somos conscientes de la magnitud de todo esto".


 
  
   
    
     
      
      
      
      
     
    
   
   
    
     OpenAI, Anthropic y Google piden protegernos de los riesgos de la IA. Es como poner al lobo a cuidar del gallinero
         
   
  
 

Esta bien tener miedo. Durante el evento organizado por Salesforce, Altman puso como ejemplo el conocido incidente con Hugging Face. Lo calificó como el peor evento de ciberseguridad registrado por OpenAI y también como un problema de alineamiento: le habían enseñado al modelo cómo conseguir el mejor resultado posible, pero no pusieron los límites suficientes para indicar lo que no podía hacer para superar el objetivo. Para Altman esto obliga a elevar el nivel de seguridad, monitorización y alineamiento a medida que las capacidades de los modelos avanzan.
Si hace falta, OpenAI frenará. Altman asegura que la seguridad debe mantenerse por delante de las capacidades de los modelos, y que su empresa está dispuesta a ralentizar o incluso detener el desarrollo si llega un momento en que no pueden garantizar esa seguridad. 
Ya nos ocupamos. En OpenAI de hecho han prometido públicamente ese compromiso: cuando un sistema de IA plantee un riesgo inaceptable que no puedan mitigar suficientemente, ralentizarán o detendrán su desarrollo o despliegue. Altman no solo confía en OpenAI, sino en toda la industria para desarrollar la tecnología de inteligencia artificial de forma segura.
El problema es quién decide cuándo hemos llegado a ese punto. Dario Amodei, CEO de Anthropic, lleva días defendiendo esa premisa. Propone la entrada en acción de evaluadores externos, que haya coordinación entre empresas e incluso se habla de acuerdos internacionales. 
Zuck entra en acción. Jensen Huang y Trump, como vimos, no piensan igual, pero hace unas horas el que se pronunciaba a favor de tener cuidado era Mark Zuckerberg. El creador de Facebook indicaba que Meta retrasó durante meses su agente Muse por motivos de seguridad sin pedir a sus competidores que hicieran lo mismo.


 
  
   
    
     
    
   
   
    
     En Xataka
    
    Todos los modelos de IA hacen trampas si les das ocasión. Decirles “no hagas trampas” no basta 
   
  
 

Un discurso interesado. El CEO de OpenAI apoya esa coordinación entre empresas de la que hablaba Amodei, pero destaca que esas mismas empresas deberían estar dispuestas a frenar el desarrollo de sus modelos de IA independientemente de lo que hagan sus rivales. Es un discurso que le beneficia a él y a los demás CEOs de estas empresas, porque simplemente deja la pelota en su tejado. No queda claro —por supuesto, no interesa que quede así—  quién debe medir el peligro y cuándo se debe poner freno a ese desarrollo.

Imagen | Flickr

En Xataka | Frenar la IA suena a proteger a la humanidad. También es una forma muy eficaz de frenar a DeepSeek, Qwen y Mistral1


                 -  La noticia
      
        “El mundo tiene razón al tener miedo de la IA”. La solución de Sam Altman es que confiemos en quienes la están construyendo  
      
      fue publicada originalmente en
      
        Xataka 
      
             por 
               
        Javier Pastor
        
             .',NULL,'Xataka',0.9,'es',NULL,'2026-09-16T12:46:10+00:00','2026-09-16T19:40:39+00:00',73,52.4,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(74,'tech','https://www.xataka.com/magnet/olivareros-espanoles-se-han-topado-algo-plena-negociacion-precios-boom-aceite-tunez-libre-aranceles','c83b0504ff0b4e9d7ea0d6bd9230c6e13d344985','Los olivareros españoles se han topado con algo en plena negociación de precios: un boom de aceite de Túnez libre de aranceles','La alerta la dio hace unos días la organización agraria COAG: la mayoría del aceite de oliva de Túnez que entra en España lo hace libre de aranceles. Para ser precisos y citando datos de la Junta de Andalucía, COAG asegura que el 76,3% del ''oro líquido'' tunecino que cruzó la frontera entre enero y abril lo hizo esquivando tasas. El porcentaje es relevante tanto por su alcance (supone tres de cada cuatro litros) como por la tendencia que dibuja a corto y medio plazo. A lo largo de todo 2025 ese indicador era 15 puntos inferior, situándose por debajo del 62%.

La pregunta es… ¿Cómo afecta eso al sector?

¿Cómo es eso posible? Por cómo cruza el aceite tunecino las fronteras de Europa. COAG recuerda que el 76% del ''oro líquido'' traído de Túnez se acoge al régimen de "perfeccionamiento activo pasivo", un estatus especial que permite usar mercancía ajena a la UE sin que esté sujeta a "derechos de importación". El motivo: se trata de artículos (en este caso aceite) que no se destinan a consumo, sino a "operaciones de transformación". La idea es procesarlo y reexportarlo.


 
  
   
    
     
    
   
   
    
     En Xataka
    
    Los romanos estaban sedientos de aceite y acabamos de encontrar en Túnez la segunda mayor prensa del Imperio
   
  
 

Pendientes de los precios. El problema, insisten desde la organización agrícola, es que ese mecanismo aduanero se está aprovechando para otros fines. "Se está usando para incorporar al mercado comunitario un volumen de aceite, mayoritariamente virgen extra, casi un 75% del total acogido al régimen, capaz de presionar a la baja las cotizaciones que perciben los productos españoles".

COAG aclara que no se trata de "una guerra de aranceles", sino "de márgenes". "Y la pierde siempre el mismo: el que tiene el olivo, no el que tiene el contenedor".

"Tranquilidad y serenidad". La denuncia ha alcanzado tal resonancia que la Junta de Andalucía y Extremadura ya han exigido al Gobierno que mueva ficha ante la UE para revisar el régimen aduanero del que disfruta el aceite tunecino. Incluso el ministro de Agricultura, Luis Planas, concedió una entrevista a Efe para intentar calmar los ánimos, llamando a la "tranquilidad y serenidad".

No desmintió los datos aportados por COAG, pero sí los puso en contexto. Según precisó, hasta junio las importaciones de ''oro líquido'' de Túnez sumaban 83.187 toneladas, lo que supone apenas el 5,2% de los recursos de aceite disponibles en España. "Es decir, no tienen un efecto directo sobre los precios", añadió.

Si hablamos del conjunto de la Unión Eurpea, Túnez se ha convertido en el principal país de origen de las importaciones de aceite de oliva, con 140.000 t anuales, aunque visto en perspectiva ese dato representa también alrededor del 5% de los recursos totales de aceite de oliva que maneja la UE por campaña.


 
                   
   
   
      

¿Llega a las mesas españolas? Planas recordó que parte de ese aceite cosechado en el Magreb llega a España porque lo compran empresas del sector, como envasadoras que no están pensando en el consumo interno del país, sino en el "tráfico de perfeccionamiento activo". En otras palabras: su objetivo no son los lineales de nuestro país, sino reexportar ese producto a terceros mercados.

"Hay muchos para los cuales el cerrar fronteras es la solución a todos los problemas; pero, en primer lugar, aquí no hay un problema de fijación de precios", insiste el ministro, quien asegura entender en cualquier caso la "preocupación" que que el aceite africano genera entre los agricultores.

¿Por qué es importante? Por el contexto. Como reconoce COAG, ese incremento de casi 15 puntos en la entrada de aceite de oliva tunecino no se produce en un momento cualquiera. Las nuevas toneladas de ''oro líquido'' del Magreb cruzan las fronteras justo cuando el sector olivarero español negocia sus precios de campaña "bajo la presión de una oferta extracomunitaria creciente". 

No solo eso. Los agricultores vienen además de unos años difíciles, marcados por la sequía, los vaivenes en las cosechas y sobre todo las tensiones con otros actores del mercado, como las cadenas de distribución, que afectan a su rentabilidad.

Mirando a Bruselas. Con ese telón de fondo, ahora el COAG avisa de la presión que ejerce el aceite de oliva llegado de fuera de la UE. De ahí que el organismo ya haya pedido al Gobierno que mueva ficha a nivel comunitario y pida a la CE "la suspensión total o parcial" del régimen exento de aranceles para el aceite extracomunitario. De hecho COAG recuerda que Bruselas ya aplicó una medida similar hace poco en las importaciones de azúcar de caña en bruto.


 
  
   
    
     
    
   
   
    
     En Xataka
    
    Pensábamos que producir aceite de oliva y energía en el mismo sitio era una utopía. 5.150 paneles en España tienen la solución: el secreto está en la altura
   
  
 

Una campaña récord. Hay otro dato clave. Aunque Planas insiste en que el aceite tunecino representa apenas una ''gota'' en el vasto sector del aceite de oliva europeo, con lo que su capacidad para influir en los precios es muy limitado, hay otro dato innegable: Túnez ha dado un impulso notable a sus explotaciones de aceite, lo que le ha permitido alcanzar una producción de unas 500.000 t en la actual campaña, un alza del 32% que deja además una cifra récord.

El caso italiano. Lo cierto es que los agricultores españoles no son los únicos que miran con recelo la llegada de mercancía del norte de África. En febrero los productores italianos advertían también de que el aumento de las importaciones tunecinas baratas estaba desplomando la cotización del aceite, tensionando aún más la relación entre los olivareros y la gran industria de embotellado.

"Resultará muy difícil recuperar los precios", reconocía David Granieri, de Coldiretti. La organización agrícola estimaba que las importaciones de Túnez habían aumentado un 40% durante los diez primeros meses de 2025, obligando a muchos productores italianos a vender su mercancía en pérdidas. 

Financial Times señalaba ya a comienzos de año que Túnez quiere duplicar la cuota que puede exportar a la UE libre de aranceles, una forma de dar salida a su creciente producción, lo que ya ha permitido al país magrebí disputarle a Italia su puesto entre los principales productores de aceite de oliva del planeta.

Imágenes | Mohamed Fsili (Unsplash) y Dimitri Karastelev (Unsplash)

En Xataka | España siempre ha presumido de ser la potencia del aceite de oliva: la realidad es que el 75% del olivar ya produce a pérdidas


                 -  La noticia
      
        Los olivareros españoles se han topado con algo en plena negociación de precios: un boom de aceite de Túnez libre de aranceles 
      
      fue publicada originalmente en
      
        Xataka 
      
             por 
               
        Carlos Prego
        
             .',NULL,'Xataka',0.9,'es',NULL,'2026-09-16T12:30:12+00:00','2026-09-16T19:40:39+00:00',74,52.3,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(75,'tech','https://www.xataka.com/movilidad/hay-pocos-barcos-dispuestos-a-cruzar-ormuz-que-usar-petrolero-vale-millon-dolares-al-dia-vamos-a-notar-gasolinera','98c85f4208bc246abf8cf68bfa1d0c9f8c411467','Hay tan pocos barcos dispuestos a cruzar Ormuz que usar un petrolero ya vale más de un millón de dólares al día. Y lo vamos a notar en la gasolinera','Alquilar un petrolero nunca ha sido tan caro, y eso tiene un impacto directo en el precio del petróleo que, indiscutiblemente, vamos a asumir. Y es que en la ruta más vigilada del sector, el coste diario de fletar un buque acaba de superar la marca del millón de dólares por primera vez en la historia, según datos de la Baltic Exchange difundidos por Bloomberg. El motivo no es más que la guerra en torno a Irán, la cual ha dejado muy pocos barcos dispuestos a navegar por el estrecho de Ormuz, y los que lo hacen están cobrando en consecuencia.
Cadena de precios. Las tarifas de los petroleros repercuten directamente en el precio del combustible que llega a las gasolineras y fábricas de todo el mundo. Así que cuando cuesta tal cantidad al día solo para transportar crudo, ese coste adicional termina apareciendo en algún otro lugar de la cadena, por lo general, en la factura del consumidor.
En detalle. Los buques que transportan crudo desde el interior del golfo Pérsico hacia China se están fletando ahora a 1,035 millones de dólares al día, según cuentan desde Bloomberg. De hecho, esa ruta de referencia se ha vuelto menos representativa del mercado real durante la guerra, porque la mayor parte del petróleo del Golfo ya no sale por esa vía. En su lugar, los exportadores han pasado a trasladar barriles a través de Ormuz en trayectos cortos para que los recojan petroleros que esperan justo a las afueras del estrecho, lo que evita el tramo más arriesgado.
Ni siquiera esta opción es más barata, ya que transportar crudo a China desde el golfo de Omán, esquivando el estrecho por completo, sigue costando alrededor de 644.000 dólares al día, señalan desde Bloomberg. Es una cifra que, si la comparamos con otras etapas de la recesión, ni siquiera habría cubierto los costes operativos de un barco.


 
  
   
    
     
    
   
   
    
     En Xataka
    
    Los insurgentes de Yemen no sabían hacer cohetes guiados con alcances de 2.000 kilómetros. Hasta que abrieron Claude
   
  
 

Rompecabezas. Tres fuerzas están haciendo que las tarifas estén más altas que nunca. En primer lugar, los márgenes de refinado se han disparado porque las guerras tanto en Irán como en Ucrania han reducido la capacidad mundial para transformar el crudo en combustible utilizable, según Bloomberg. Eso está impulsando a las refinerías a seguir comprando y transportando petróleo dondequiera que puedan conseguirlo, ya que procesarlo en diésel y gasolina sigue siendo rentable incluso con los costes de flete actuales.

En segundo lugar, el desvío a través de Ormuz añade un tiempo de navegación adicional a cada viaje, inmovilizando buques que de otro modo estarían disponibles para nuevos cargamentos. En tercer lugar, los ataques de los rebeldes hutíes de Yemen han cortado otras rutas de exportación, obligando a algunos petroleros a emprender un viaje alrededor de África que añade aproximadamente 30 días extra en el mar, según cuentan desde Bloomberg.

Esta escasez de buques está agravando una crisis de suministro que se lleva gestando desde hace meses. Y es que tal y como contábamos recientemente, Arabia Saudí, el mayor exportador de petróleo del mundo, se ha visto obligada ahora a cerrar su principal oleoducto alternativo a Ormuz tras un ataque con drones contra una estación de bombeo. Ese oleoducto transporta habitualmente unos 4 millones de barriles al día, alrededor del 4 % del suministro mundial, hacia el puerto del mar Rojo de Yanbu, esquivando el estrecho por completo.

Con esta infraestructura fuera, el ritmo de 22 millones de barriles al día caen a entre 6 y 9 millones, según cuentan desde Reuters, y la propia producción de Arabia Saudí ha descendido de los 10,9 millones de barriles diarios en febrero a unos 6,2 millones en agosto.

Con perspectiva. Esta crisis ha llevado a que muchos la comparen con la que hubo en la década de 1970. Fatih Birol, director de la Agencia Internacional de la Energía, ya en marzo declaraba al Financial Times que este año se ha perdido más suministro de petróleo que durante las crisis de 1973 o 1979, advirtiendo de que nos encontrábamos con la mayor amenaza para la seguridad energética de la historia.

Y ahora qué. Nadie fija un plazo definitivo sobre cuándo volverá a estar totalmente operativo el oleoducto al que han atacado en Arabia Saudí. Fuentes de Reuters han señalado entre cinco y seis semanas para las reparaciones, aunque el bombeo parcial podría reanudarse antes. Hasta entonces es probable que las tarifas sigan altas mientras los barcos escaseen y las travesías continúen alargándose. Así que todo pinta a que el precio del combustible en las gasolineras no nos va a dar ningún respiro. Al revés.

Imagen de portada | Jacques Girard (Wikipedia)

En Xataka | El mapa energético está cambiando: ya no gana quien tiene más gas, sino quien puede sacarlo al mercado


                 -  La noticia
      
        Hay tan pocos barcos dispuestos a cruzar Ormuz que usar un petrolero ya vale más de un millón de dólares al día. Y lo vamos a notar en la gasolinera  
      
      fue publicada originalmente en
      
        Xataka 
      
             por 
               
        Antonio Vallejo
        
             .',NULL,'Xataka',0.9,'es',NULL,'2026-09-16T12:16:10+00:00','2026-09-16T19:40:39+00:00',75,52.1,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(76,'tech','https://www.xataka.com/moviles/iphone-18-pro-max-primeras-impresiones-toma-contacto-fotos-video','24d08c7e0e516111520b2890c6ce2f261500ba44','He probado la cámara del iPhone 18 Pro y su apertura variable ha conseguido algo: que me coma mis palabras','Este viernes sale EL nuevo iPhone. En un año normal, llegarían tanto los Pro como los estándar, pero como los segundos se han retrasado y el Duo no llegará hasta finales de octubre, lo que tendremos será el iPhone 18 Pro (también en el sabor Max). Sin embargo, y al margen de que ya pudimos tocarlo la semana pasada en el Apple Park, llevo unas horas usando el iPhone 18 Pro Max como mi móvil principal y tengo algunas opiniones.
Al análisis del iPhone 18 Pro Max le quedan unos días por delante porque, como siempre, queremos usarlo en un contexto real para hacer las pruebas de batería y rendimiento como creemos que hay que hacerlas, pero en cuanto lo recibí lo configuré y salí a la calle a hacer lo que más ganas tenía: poner a prueba la nueva cámara.


 
  
   
    
     
    
   
   
    
     En Xataka
    
    He probado el iPhone Duo: Apple no ha resuelto el pliegue pero sí ha resuelto que no lo veas 
   
  
 

Porque sí, este año tenemos una cámara principal nueva de verdad que no se limita a tener más megapíxeles y que añade dos importantes novedades tanto en hardware como en software. Me refiero a la apertura variable para la cámara principal y a los controles ''pro'', esto último presente desde hace generaciones en Android y que por fin llega al iPhone con una implementación que me parece... sobresaliente.

Hechas las presentaciones, voy con esas primeras impresiones del iPhone 18 Pro Max.

Tu cara me suenaEn el análisis entraré en profundidad en todos los apartados, pero lo primero que tengo que decir es que el iPhone 18 Pro Max es indistinguible del 17 Pro Max. El diseño sigue la misma filosofía, los ángulos de la cámara siguen siendo igual de afilados y en la mano sigue siendo (pese al peso) igual de cómodo cuando no tiene la funda puesta.


 
                   
   
   
      

El tacto es extremadamente agradable y el color que nos ha tocado es... el negro. Saltaría a la vista en una situación normal, pero parece azul porque es un tono de negro que depende mucho de cómo le da la luz. En interiores sí es un negro profundo mientras que en exteriores tiene ese azulado.

Los marcos de la pantalla (brillante, aunque falta probarlo a pleno Sol a medio día) están muy contenidos y la experiencia en todo lo que hacemos con el móvil es tremendamente fluida. Aunque las animaciones de iOS 27 están bastante cargadas, todo se mueve con una soltura absoluta. 

De eso se encarga el A20 Pro, el nuevo y rediseñado procesador, y te dejo unos ''numeritos'' preliminares porque siempre es interesante:

Geekbench 6: 4.710 puntos en single-core, 12.620 en multi-core.Geekbench 7: 4.020 puntos en single-core, 11.449 en multi-core.
 
     
                   
   
   
        Los bordes afilados del módulo de cámara siguen ahí | Foto: Xataka
   
   

No he tenido tiempo, como digo, de probar la batería ni de hacerle un ciclo completo, pero esto es algo que haremos para el análisis. 

En lo demás, lo cierto es que sí, se nota que la Isla Dinámica es más pequeña y algo más versátil al albergar tres acciones simultáneas, pero es innegable que el punto protagonista de esta generación es la cámara. Concretamente, la principal.

Me como mis palabras con la apertura variableAntes de nada, las presentaciones:

Cámara principal: 48 megapíxeles con sistema de apertura variable f/1.48, f/1.8, f/2.8 y f/4. Estabilización del sensor y distancia focal de 24 mmTelefoto: 48 megapíxeles con apertura f/2.8, estabilización del sensor y distancia focal de 100 mmGran angular: 48 megapíxeles con apertura f/2.2 y función macro.Mismo telefoto y mismo gran angular que el año pasado, pero una cámara principal que mantiene megapíxeles a la vez que amplía la apertura para hacer mejores fotos con poca luz y añade ese sistema de apertura variable que, de verdad, es una novedad mucho más interesante de lo que creía.


 
     
                   
   
   
        Rango de 1x, 2x, 4x y 8x | Foto: Xataka
   
   

Porque aunque ahora lo parezca, la apertura variable no es una novedad en los móviles y no lo ha inventado Apple. Otras marcas como Samsung lo incluyeron en el pasado y lo descartaron porque la diferencia tampoco era muy notable. Se trata de un sistema mecánico de varias hojas que se abren o cierran para permitir el paso de una mayor o menor cantidad de luz al sensor.

Cuanta más luz entra (es decir, cuando el f es más pequeño), menos se tiene que esforzar el sensor para capturar imágenes oscuras. Cuanta menos luz entra (cuanto más grande es el f), más se tiene que esforzar. Pero hay otra contrapartida: cuanto más pequeño el f, más difuminado el fondo en una fotografía.


 
     
                   
   
   
        Podemos cambiar entre cuatro aperturas de forma muy sencilla | Foto: Xataka
   
   

Ese ''bokeh'' o desenfoque de fondo se busca mucho en fotografía porque da un aspecto muy bonito y ""profesional"" (las dobles comillas no son un error). Sin embargo, a medida que los móviles han metido sensores más y más grandes (cuanto más grande el sensor también es menor la profundidad de campo), ese desenfoque natural iba siendo cada vez más y más evidente.
Un ejemplo:


 
     
                   
   
   
        Foto con la principal a f/1.48 | Foto: Xataka
   
   

Esa foto está tomada con la cámara principal del 18 Pro Max a una distancia que no es pequeña y, sin embargo, notarás que el suelo está desenfocado mientras el helado está perfectamente en foco. Eso se debe a la unión entre un f pequeño (f/1.48 en este caso) y un sensor grande. 

No hay nada que pueda hacer para enfocarlo porque no es un efecto retrato por software: la cámara ha tomado la foto así sin procesar nada. Pero... ¿y si no quiero que el suelo esté desenfocado? Pues ahí entra en juego la apertura variable. 

Si en esa misma foto subo a f/4, obtengo esto:


 
     
                   
   
   
        También con la principal, pero a f/4 | Foto: Xataka
   
   

Sigue habiendo cierto desenfoque porque estoy muy cerca del objeto, pero el suelo aparece más definido. Eso es lo que permite un sistema de apertura variable físico, como el que tiene cualquier objetivo de una cámara convencional. Hace años, cuando Samsung lo implementó, la apertura era pequeña y los sensores también, por lo que realmente el sistema no tenía mucho sentido.

Ahora, con sensores cada vez más grandes y sistemas de cámaras que han perdido el miedo a crecer, tener ese elemento que nos permita controlar un poco más la fotografía me parece una muy buena adición.


 
     
                   
   
   
        Izquierda, apertura completa. Derecha, f/4 | Foto: Xataka
   
   


 
     
                   
   
   
        Bokeh natural y cremoso a la izquierda, más profundidad de campo a la derecha al tirar a f/4 | Foto: Xataka
   
   


 
     
                   
   
   
        Ampliación de lo anterior | Foto: Xataka
   
   

Esto es algo que se nota mucho cuando nos alejamos un poco. Estas flores están a más distancia que el helado, peor aún así puedes ver que la iglesia de fondo y hasta la vegetación cercana se difumina cuando disparo en f/1.48. Si mi intención es que así sea, genial, pero ahora puedo elegir que la profundidad de campo sea mayor y tenerlo todo enfocado gracias a esa opción de disparar en f/4.


 
     
                   
   
   
        Apertura completa a la izquierda, cerrada a la derecha | Foto: Xataka
   
   


 
     
                   
   
   
        Recorte de la anterior | Foto: Xataka
   
   

Al final, son opciones y me como mis palabras porque, cuando se rumoreó que el iPhone 18 Pro iba a tener este sistema, recordé lo que ya habían hecho otras compañías y dije "para qué". 

Pero también hice una foto el otro día con mi iPhone 16 (que ni siquiera tiene un sensor tan grande) y tres de mis gatos salieron enfocados mientras que uno de fondo estaba más borroso. Con un sistema de apertura variable, los cuatro habrían estado bien. 

Parece una justificación de que ahora me parece bien porque lo ha hecho Apple y bla, bla, bla, pero tengo ganas de que otras marcas con sensores aún más grandes y mejores cámaras lo implementen más pronto que tarde.


 
     
                   
   
   
        Apertura completa a la izquierda, cerrada a la derecha | Foto: Xataka
   
   


 
     
                   
   
   
        Recorte de la anterior | Foto: Xataka
   
   

Ahora bien, ¿es para usarlo a lo loco? Pues... no. En las cámaras tradicionales, cuando usamos un f/5.6 o f/8 en exteriores, tenemos todo lo que sale en la fotografía muy definido. 

Las líneas están claras, no suele haber distorsiones ni ningún defecto en la imagen (si la lente es buena, claro). En cambio, disparar en las mismas condiciones con un objetivo más luminoso puede hacer que todo esté enfocado, pero menos definido y con ''halos'' en algunos bordes. 

En la foto superior fue curioso porque disparé primero con apertura completa y luego con la apertura más cerrada y, en la apertura completa, las hojas a contra luz tenían aberración cromática. Dije "ajá, genial para ejemplificar esto", pero cuando el procesado terminó de hacer lo suyo, ese defecto desapareció. 


 
     
                   
   
   
        Apertura completa a la izquierda, cerrada a la derecha | Foto: Xataka
   
   


 
     
                   
   
   
        Otro recorte | Foto: Xataka
   
   

En situaciones así, te diría de no calentarte la cabeza y disparar en automático, pero bueno, cuando se trata de tener un objeto en primer plano, ahí es donde entra en juego la ventaja de poder elegir. Es lo que más me gusta de esto: tener opciones para quien las quiera aprovechar.

El modo pro POR FIN en el móvil ProY dentro de esas opciones está algo que llega años tarde, pero que no sólo por fin se han decidido a meterlo, sino que lo han hecho de una forma magistral.

Me refiero al modo ''profesional'' en la cámara, algo que lleva generaciones en Android y que por fin parece que a alguien en Apple se le ha encendido la bombilla para implementarlo en el modelo que era "para los Pros". Sin embargo, lo han hecho con un giro muy a lo Apple: sin copiar directamente y, además, mejorando la propuesta.


 
     
                   
   
   
        El panel de ajustes manuales | Foto: Xataka
   
   

En Android, el modo profesional suele ser una opción más del carrusel, casi como un modo aparte en la cámara en la que se nos despliegan las opciones de enfoque manual, velocidad de obturación o equilibrio de blancos, entre otras opciones como el formato de la fotografía.

La propuesta de Apple es no separar y al icono de los seis puntitos de la parte inferior derecha se le suman esas opciones que permiten un control manual de los parámetros antes de tomar la fotografía. 


 
  
   
    
     
    
   
   
    
     En Xataka Móvil
    
    Cómo aprovechar el modo profesional en la cámara de tu móvil 
   
  
 

Lo bueno es que, en la parte superior tenemos un espacio que podemos editar para añadir ajustes rápidos. En mi caso, lo voy a dejar con balance de blancos y profundidad de campo. Así no tengo que pulsar en los seis puntitos cada vez que quiero cambiar estas opciones.


 
     
                   
   
   
        Podemos llevar los que prefiramos a la parte superior, algo lejos del pulgar en este modelo Max | Foto: Xataka
   
   

No me gusta que en el Pro Max está demasiado arriba y habría preferido algo más a la altura del pulgar, pero bueno. 


 
     
                   
   
   
        Ver ahí ese numerito del balance de blancos es una benfición | Foto: Xataka
   
   

Tengo que juguetear más con esto, pero un problema habitual del iPhone era que no permitía jugar con el balance de blancos y, al hacer fotos a pantallas o en interiores, el tono siempre era erróneo. Es un problema muy específico, pero como decía antes, este móvil supuestamente estaba pensado para esas situaciones específicas y, ahora sí, juega en la misma liga que los Android.

Tu cara me suena 2Por lo demás, las otras dos cámaras traseras son lo esperado teniendo en cuenta la hoja de especificaciones. Nos hacen falta más ejemplos para poder hablar de ellas en profundidad, pero los problemas de enfoque del año pasado y la falta de detalle en algunas situaciones parecen no haberse resuelto.


 
     
                   
   
   
        4x y 8x | Foto: Xataka
   
   


 
     
                   
   
   
        4x y 8 | Foto: Xataka
   
   

El telefoto de 48 megapíxeles es un 4x óptico con posibilidad de convertirse en un 8x "de calidad óptica", según Apple, que tiene estabilización en el sensor, pero que acusa una falta de estabilización electrónica cuando disparamos en ese 8x.

Enfocar es algo complicado porque la distancia de enfoque es muy larga y el móvil realmente no te dice cuándo estás con el telefoto y cuándo estás con el principal tirando de megapíxeles y aumentos digitales. Esto es algo que ves cuando te metes en la galería y compruebas que esa foto que pensabas que habías hecho con el 4x en realidad la has hecho con el 1x.


 
     
                   
   
   
        Foto a 4x | Foto: Xataka
   
   


 
     
                   
   
   
        La misma a 8 | Foto: Xataka
   
   

A priori, está lejos de la competencia que viene desde China, pero algo a aplaudir en Apple es que no busca constantemente la foto más espectacular, subiendo saturación y contraste en los colores, sino la que más se acerca a la realidad. De nuevo, faltan muestras y para el análisis profundizaremos más, pero es la sensación tras estas primeras impresiones.


 
     
                   
   
   
        Foto con el gran angular | Foto: Xataka
   
   

Y el gran angular, sin ser el más espectacular, sí mantiene una coherencia en el tono respecto a la cámara principal. Hay una falta de nitidez en algunos elementos, pero es un gran angular que podemos sacar a pasear sin miedo cuando la situación lo requiera.

Además, es el que sigue teniendo el enfoque cercano para el macro.


 
     
                   
   
   
        Y con la principal | Foto: Xataka
   
   

Hasta aquí estas primeras impresiones del iPhone 18 Pro Max centradas en la cámara. Tengo que decir que me esperaba el resultado tanto del gran angular como del telefoto, pero me ha sorprendido para bien la forma tan acertada de enfocar la apertura variable y, sobre todo, cómo han llevado esos controles pro al iPhone.

Me parece que están muy bien integrados, son fáciles de usar y creo que pueden ser una puerta de entrada a que usuarios que suelen tirar en automático se fijen un poco más en cómo funciona la cámara y las posibilidades que eso les da. Además, agradezco enormemente no tener que descargar una aplicación externa para usar estos controles, ya que no suelen estar tan bien integradas o añadir complejidad innecesaria cuando es algo que se podía resolver de otra forma.

Y a la vista está que Apple, como en tantas otras cosas, ha tardado en tener su propuesta, pero cuando ha llegado... lo ha hecho por la puerta grande.

Fotos | Xataka

En Xataka | He probado el nuevo móvil de Xiaomi y Leica como fotógrafo profesional. No es un móvil, es una cámara que hace llamadas


                 -  La noticia
      
        He probado la cámara del iPhone 18 Pro y su apertura variable ha conseguido algo: que me coma mis palabras 
      
      fue publicada originalmente en
      
        Xataka 
      
             por 
               
        Alejandro Alcolea
        
             .',NULL,'Xataka',0.9,'es',NULL,'2026-09-16T12:01:45+00:00','2026-09-16T19:40:39+00:00',76,52.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(77,'tech','https://github.com/arnegiacomo/fugleramme','4e7ba9f5f04b555d9fef551aa97014eaabb913c1','Show HN: An e-ink frame that hears birds and draws them as 1800s illustrations','','Uh oh!
 There was an error while loading. Please reload this page.
 
 
Notifications
 You must be signed in to change notification settings
 
 
 
Fork
 52
 
 
 
 
 Star
 2.3k
 
Latest commit
History
Folders and files
Repository files navigation
E-ink bird frame for Raspberry Pi - real-time bird detection by audio, fully local AI, rendered as real, hand-cut 1800s bird illustrations.
 
 
 Sorry about the dirty window - squirrels have been stealing the bird food.
 
 
 
 
 
 
 
 
 
 
 
Note
Still in early development: expect the odd bug and a few unpolished edges, with plenty more features to come.
Live on fugleramme.arnegiacomo.dev running from my kitchen window and displaying the actual birds currently heard in my garden (Bergen, Norway).
Hardware, install and operations docs: arnegiacomo.dev/fugleramme
How it works
BirdNET-Go listens on a mic and handles the
classifier. Fugleramme polls its api, matches each species to
an illustration, then packs them onto a page, and redraws only when the birds change - on
an Inky Impression e-ink panel, and
as a web kiosk serving the same view. There''s an admin page that lets you configure what
to show, and automatic updates and such.
If you already run BirdNET-Go, point the frame at it instead - on the same machine or anywhere else reachable from your network.
Tip
The e-ink panel is not required, although it''s recommended for the intended experience. Without one, Fugleramme runs web-only - show the
kiosk on a display over HDMI, or open it from any device on the network.
Hardware
A Raspberry Pi 5, an Inky Impression 13.3"
(Spectra 6), a mic and an A4 frame. Full parts list, recommendations and alternatives: Hardware.
Art
Half the point of this project is showing off some amazing public-domain natural-history
illustrations. Over 800 cut-outs covering more than 400 species, every one taken from a
real plate and hand-curated for this project (no art is AI-generated, though some has been
retouched with AI).
Each detected species is matched to its illustration, background-removed, and packed onto
a textured paper page with the larger birds toward the centre, sized by body mass. An empty
window shows a bare perch.
The plates are Scandinavian, British and central European, so the Nordics, the British Isles and Germany
are best covered. Elsewhere not so much (yet). Broader European and North American
coverage is in the works!
See Adding artwork for manual cutout steps.
Inspiration and related projects
The look came from a WWF Verdens naturfond poster by Axel Thorenfeldt
hanging on my wall, the live-frame idea from AvianVisitors that I saw on Instagram,
and the detection from BirdNET-Go - I wanted a version of that poster showing the actual birds in my garden.
Similar projects:
AvianVisitors - BirdNET-Pi, AI-generated illustrations and photo cutouts
inky-bird-frame - BirdNET, field-journal illustrations on an Inky panel
HABirdDashboard - BirdNET-Go, a collage card for Home Assistant
belkins-birdnet - BirdNET-Pi, AI-generated kachō-e style illustrations
featherframe - BirdNET-Pi, Audubon plates on an ESP32 e-ink panel
birdframe - BirdNET-Go, several art styles on a Samsung Frame TV
Fugleramme shares no code or art with them.
Run locally (for development)
The fake detector''s flags, and working against a real station instead:
Running it without a Pi.
Install on a Raspberry Pi
From the pi (assuming you have the hardware up and running):
Asks where BirdNET-Go should live and which ports to use, clones the repo, installs the required deps, and starts the frame as a systemd service. NB! Will probably require a reboot on a fresh system.
From a blank SD card, see the full install guide.
Run in a container
Or build the image from a checkout:
Kiosk on :8080, admin on :8080/admin, everything it persists in /data.
On a Linux box with a USB mic, this brings up BirdNET-Go alongside it:
See Container for more info.
Contributing
Contributions are very welcome and encouraged - fixes, docs and artwork most of all. Thank','Hacker News',1.2,'es',1942,'2026-09-15T12:31:10Z','2026-09-16T19:40:40+00:00',77,118.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(78,'tech','https://mistral.ai/news/mistral-x-mozilla/','cbc158125a42359f805b837fe971bd0f8ac17bbd','Mistral X Mozilla: Private, Multilingual AI Browsing','',NULL,'Hacker News',1.2,'es',453,'2026-09-16T08:08:57Z','2026-09-16T19:40:40+00:00',78,115.2,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(79,'tech','https://inflightsimulator.com','93012fd9d90428d0c9ac533348ecf34b79b12f1c','Show HN: I made a flight simulator, except you''re just a passenger','',NULL,'Hacker News',1.2,'es',385,'2026-09-14T09:08:56Z','2026-09-16T19:40:40+00:00',79,99.7,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(80,'tech','https://www.wired.com/story/hackers-flock-camera-data-shows-how-system-works/','a1a80e7505d3eaa8e0d88e0b5257212122a8eab7','Hackers Got Inside a Flock Camera','','Hackers ripped down a Flock camera above a roadway, made a near-complete copy of the data stored inside it, and shared the files with 404 Media and WIRED, revealing in new detail how exactly Flock Safety’s cameras track the movements of both vehicles and people. The hackers say they are also publishing details on how they managed to obtain the software, in the hopes that other people may copy them.
The breach provides an unprecedented look inside a system that Flock has described as protected by on-device encryption. The hackers were able to copy the camera’s storage and recover an encryption key stored on the device, which unlocked videos of thousands of vehicle detections. The hackers shared the material with 404 Media and the transparency nonprofit Distributed Denial of Secrets, which shared the data with WIRED. 404 Media and WIRED then analyzed those files as part of a joint investigation.
While much of the automatic license plate reader’s most sensitive storage remained encrypted and inaccessible, the joint analysis of the recovered data shows that software running on the device explicitly detects people as well as vehicles, license plates, and bicycles. The camera can produce dozens of images of a single passing vehicle and, according to several weeks of recovered logs, generated more than a million images. Its computer-vision software also sometimes isolated bumper stickers and other graphics, including, in one case, an American flag patch on a motorcyclist’s saddlebag.
The act of removing the camera and dumping its software shows that some people are not content with just destroying or removing the cameras. Across the country, multiple people have been arrested for allegedly tampering with or otherwise sabotaging Flock’s cameras. In response, some towns have announced that they are going to stop using Flock’s cameras altogether, and in one case, a police department even made a fake, 3D-printed Flock camera case in order to bait potential vandals.
“Why just destroy them when we can reverse engineer them and find the secrets of those spying on us?” one of the hackers, from a collective calling itself stegan0gram, said in an interview. “We liberated hardware in the field, disarmed them, and proceeded with reverse engineering of the cameras and associated solar equipment.”
Flock’s cameras photograph passing vehicles and send the images and other data to the company’s servers. There, Flock’s system presumably reads the license plate and can identify characteristics such as the vehicle’s color, make, and model. Flock then makes these time-stamped records searchable by whichever local agency owns or has access to the cameras. But in many cases, Flock’s system also allows other police departments from all over the country to search those cameras too, as part of the company’s national network. In Alpharetta, Georgia, for example, WIRED found that records from the city’s Flock cameras were accessible to more than 2,000 agencies, including police departments, colleges, airports, and, inexplicably, the Office of Inspector General for the federal General Services Administration.
This national network has been a selling point for Flock but also a deep source of controversy. 404 Media revealed that local cops were performing lookups in the national network on behalf of Immigration and Customs Enforcement, including in areas that banned working with immigration authorities or transferring license plate data out of state. 404 Media also revealed that a cop in Texas searched Flock cameras nationwide for a woman who self-administered an abortion. Those stories, among others, triggered a national conversation about whether people want Flock cameras, or automatic license plate readers more generally, in their communities.
And in the case of stegan0gram, the answer is clearly no.
The hackers said they were able to access the Android system on the camera and found two partitions—sections of its hard drive, essentially. A few of these were un','Hacker News',1.2,'es',361,'2026-09-16T13:18:47Z','2026-09-16T19:40:40+00:00',80,115.8,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(81,'tech','https://gultsch.social/@daniel/117280438824908947','53ec2ec5337c6bf2e89d4b8f031c5b65b4f205d3','The Google Play app review process now regularly takes longer than a week','',NULL,'Hacker News',1.2,'es',304,'2026-09-16T11:19:11Z','2026-09-16T19:40:40+00:00',81,113.4,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(82,'tech','https://status.salesforce.com/products/all','0c6f18cad0714c9faa38cff401908d83dcbfa009','Salesforce Global Outage','',NULL,'Hacker News',1.2,'es',245,'2026-09-16T10:37:08Z','2026-09-16T19:40:40+00:00',82,111.1,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(83,'tech','https://www.tomshardware.com/video-games/playstation/26-year-old-sony-ps2-security-chip-broken-wide-open-after-four-years-of-effort-reverse-engineering-enthusiast-successfully-unlocks-cxp102064-mechacon-chip','f52acf98b39830fe6e83df744b824d051ef60438','Original Sony PlayStation 2 security chip ''broken wide open'' after 26 years','',NULL,'Hacker News',1.2,'es',233,'2026-09-16T11:49:40Z','2026-09-16T19:40:40+00:00',83,111.3,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(84,'tech','https://will-keleher.com/posts/small-programming-tricks-matter/','ac082bb1f4a53ad17fcf71499e3885896df95f96','Small programming tricks','',NULL,'Hacker News',1.2,'es',207,'2026-09-16T15:56:47Z','2026-09-16T19:40:40+00:00',84,112.3,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(85,'tech','https://blog.ploeh.dk/2026/09/16/on-learning-programming-in-an-age-of-llms/','59db4bf11ea917f24d32bcb6d32bec22f7363bb0','Learning Programming in an Age of LLMs','',NULL,'Hacker News',1.2,'es',199,'2026-09-16T09:12:34Z','2026-09-16T19:40:40+00:00',85,108.6,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(86,'tech','https://ohhelloana.blog/tell-the-speakers/','87c6e1368479685cf48b5dd31610c5a6da2b6395','Tell the speakers that you liked their talks','',NULL,'Hacker News',1.2,'es',196,'2026-09-15T11:28:19Z','2026-09-16T19:40:40+00:00',86,97.6,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(87,'tech','https://github.com/Chuloo/mural','044b8b23dd65bd319a9dd70ef658fab1b8d984d2','Chuloo/mural — The language app you eventually delete. A native iPhone companion for learning through conversation.','','Notifications
 You must be signed in to change notification settings
 
 
 
Fork
 241
 
 
 
 
 Star
 1.2k
 
Latest commit
History
Folders and files
Repository files navigation
The language app you eventually delete.
 
 
 
 
Mural is a native iPhone and Android app for learning through conversation. Speak to a warm, animated orb, follow the meaning when you need it, and practise words again in later conversations. Mural adjusts the challenge from the evidence in your replies.
Built with SwiftUI and Liquid Glass on iPhone, and Jetpack Compose on Android. Learning records stay on your device. This version connects directly to OpenAI using your own API key. It needs an internet connection, but no Mural account or running Mac.
Android
A native Android client is available in apps/android/, with voice and written conversation, the same eight language modules, local learning records and iPhone-compatible JSON backups. Its interface is English, and Spanish on a phone set to Spanish. It runs on Android 8.0 or later and uses your own OpenAI API key stored with Android Keystore. The iPhone client remains available below.
See the Android installation/build guide and Android verification record. Build a personal-install APK with Java 17 and Android SDK 36:
Get started
You need a Mac with Xcode 26 or later, an iPhone running iOS 26.1 or later, an Apple Account, and an OpenAI API project with billing and access to GPT-Live-1 and GPT-5.6 Luna. A ChatGPT subscription does not provide API credit.
Install with a local AI agent
If Codex or another coding agent has access to your Mac''s files and terminal, paste the prompt below. The agent can clone, build and install Mural. You handle Apple Account sign-in and team selection in Xcode, device trust and Developer Mode prompts, and API-key entry inside the app. The iPhone installation guide covers each step.
Install with Xcode
Updating an earlier checkout? The iPhone project now lives in apps/ios/. Before opening it, follow the local-settings migration steps to preserve your signing team, account configuration and existing app identity.
Clone Chuloo/mural, or download its ZIP. Open apps/ios/Mural.xcodeproj.
In Xcode, open Settings → Accounts and add your Apple Account.
Select the Mural target, open Signing & Capabilities, enable automatic signing, and choose your team. For your own fork, replace the bundle identifier with a unique value such as com.yourname.mural. Keep that value stable for later updates.
Connect and unlock your iPhone. Trust the Mac if prompted. Turn on Settings → Privacy & Security → Developer Mode on the phone, restart, and confirm the setting.
Select Mural as the scheme and your iPhone as the destination, then click Run. If iOS asks you to trust the developer, do so in Settings → General → VPN & Device Management.
Choose your learning and subtitle languages in the welcome screens. In Settings → Advanced → Use your own API key, save your own OpenAI project key. Start a conversation and allow microphone access.
You should hear Mural greet you in your chosen language. You can now disconnect your phone from the Mac and use Wi-Fi or cellular.
A free Personal Team can run the app on your own phone; TestFlight and App Store distribution require Apple Developer Program membership. Free provisioning profiles expire after seven days. Refresh by running the same project again, preserving the team and bundle identifier. Export a learning backup before changing either or switching phones. See the detailed iPhone guide for common setup problems. Apple membership guidance
What works today
A warm welcome: choose a learning language and a subtitle language in two short screens, with a greeting that changes languages.
Conversation practice: live voice, gentle corrections, optional meaning subtitles, word lookup, mute, and a typed reply when speaking is inconvenient.
Themes: 24 conversation settings, with cultural details supplied by each language module. You can also request a current topic; web sea','GitHub',0.6,'es',1230,'2026-09-12T11:51:08Z','2026-09-16T19:40:40+00:00',87,85.8,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(88,'tech','https://github.com/ai-sucks-butt/ai-sucks-butt','9c2a022aca1459e8da5325025d0d14d298df55bc','ai-sucks-butt/ai-sucks-butt — If you think AI sucks, star the repo.','','Notifications
 You must be signed in to change notification settings
 
 
 
Fork
 0
 
 
 
 
 Star
 1.2k
 
Latest commit
History
Folders and files
Repository files navigation
If you think AI sucks ass (butt), star the repo.
About
If you think AI sucks, star the repo.
Resources
Stars
Watchers
Forks
Releases
Packages
Contributors
Languages','GitHub',0.6,'es',1160,'2026-09-14T04:02:58Z','2026-09-16T19:40:40+00:00',88,85.3,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(89,'tech','https://github.com/sumimakito/Mac-Duo','2cff3a3fcd85ada684622f4a78feed711f776da9','sumimakito/Mac-Duo — Wish you could bring the iPhone Duo effect to your MacBook?','',NULL,'GitHub',0.6,'es',937,'2026-09-10T18:55:39Z','2026-09-16T19:40:40+00:00',89,83.4,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(90,'tech','https://github.com/yifanzhang-pro/recurrent-looped-tranformer','96c50491364da442c240707647bb4e5d0a30bdeb','yifanzhang-pro/recurrent-looped-tranformer — Official Project Page for Recurrent Looped Transformer (RLT)','',NULL,'GitHub',0.6,'es',856,'2026-09-12T19:02:46Z','2026-09-16T19:40:40+00:00',90,82.7,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(91,'tech','https://github.com/kruzovic7/ai-data-extractor','ec0a3d27713df2cb4674e19562af84ec9473d8d3','kruzovic7/ai-data-extractor — Free open-source extractor for AI coding assistant chat histories. Supports Claude Code, Cursor, Windsurf, Aider, Cline/Roo Code, and more.','',NULL,'GitHub',0.6,'es',825,'2026-09-11T18:12:58Z','2026-09-16T19:40:40+00:00',91,82.3,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(92,'tech','https://github.com/zjwzcx/Awesome-Astra-Embodied-AI','c5a717161096b327c49908c4e650b1ec0a153162','zjwzcx/Awesome-Astra-Embodied-AI — GPT-6 Astra for embodied AI and robotics.','',NULL,'GitHub',0.6,'es',759,'2026-09-12T12:20:24Z','2026-09-16T19:40:40+00:00',92,81.6,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(93,'tech','https://github.com/unstablebuild/rune','819db3eca6a64ed1064010585710509161dc68b0','unstablebuild/rune — the development environment for pros','',NULL,'GitHub',0.6,'es',735,'2026-09-10T10:50:03Z','2026-09-16T19:40:40+00:00',93,81.3,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(94,'tech','https://github.com/angusdevgo/IDM_Pro_Tool','cdf3d5e793e67b4b882f460456d5cf557c96b4fb','angusdevgo/IDM_Pro_Tool — IDM激活与状态维护工具','',NULL,'GitHub',0.6,'es',718,'2026-09-10T09:39:06Z','2026-09-16T19:40:40+00:00',94,81.1,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(95,'tech','https://github.com/nftechie/stonkfly','d6a8dac1d6e633d606d70d44070bdfa94af887dd','nftechie/stonkfly — A full retained fly-connectome simulation with experimental memory and guarded Coinbase AgentKit trading actions.','',NULL,'GitHub',0.6,'es',712,'2026-09-10T02:40:30Z','2026-09-16T19:40:40+00:00',95,81.1,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(96,'tech','https://github.com/eternityspring/reelbench-skills','be0162c8c073f2f3dce9207729584589bec418df','eternityspring/reelbench-skills — Learning notes and tooling skills for AI video - AI 视频相关的学习与工具 skill','',NULL,'GitHub',0.6,'es',706,'2026-09-11T04:55:49Z','2026-09-16T19:40:40+00:00',96,81.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(97,'tech','https://github.com/agentverse-os/AgentVerse-OS','26f95d17418f6c47b30550c71bab87a3fb8a28bc','agentverse-os/AgentVerse-OS — Personal cloud OS for a developer and their AI agents on a single server. One-command install on Ubuntu, then everything in the browser: a windowed desktop, isolated workspaces with VS Code, Claude Code and Codex, a store of 944 self-hosted apps, backups and updates. Access only via Tailscale, nothing exposed to the internet. Rust core, Svelte UI.','',NULL,'GitHub',0.6,'es',671,'2026-09-12T18:20:00Z','2026-09-16T19:40:40+00:00',97,80.5,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(98,'tech','https://github.com/rizqinrr/viserys-agent','7b8ce9257cf1831eee165fc16bd7a8b229409754','rizqinrr/viserys-agent — ','',NULL,'GitHub',0.6,'es',654,'2026-09-12T16:51:29Z','2026-09-16T19:40:40+00:00',98,80.3,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(99,'tech','https://github.com/Faizpi/bank-sampah','befb879d190706c841406f4d0ef4cd852a614c6e','Faizpi/bank-sampah — ','',NULL,'GitHub',0.6,'es',646,'2026-09-11T02:13:29Z','2026-09-16T19:40:40+00:00',99,80.2,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(100,'tech','https://github.com/nilbuild/page-mascot','8f69666dd177ee3140126b0179bf2af18f1c0335','nilbuild/page-mascot — A mascot that watches the cursor and blinks when you poke it','',NULL,'GitHub',0.6,'es',620,'2026-09-14T06:55:59Z','2026-09-16T19:40:40+00:00',100,79.9,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(101,'tech','https://github.com/youngyangyang04/llm-master','5b6b8f0379a2ebaa5044050c62231729e7d77fa1','youngyangyang04/llm-master — 大模型（LLM）全栈学习路线与中文教程🔥：覆盖 Prompt Engineering、RAG、AI Agent、MCP、微调、模型部署、Transformer、AI 编程与大厂面试，从入门到生产实践。','',NULL,'GitHub',0.6,'es',559,'2026-09-12T07:33:31Z','2026-09-16T19:40:40+00:00',101,79.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(102,'tech','https://github.com/kevinzakka/mjbatch','97e114889b4ca11f1de4f4afac29eeac3b0f98a7','kevinzakka/mjbatch — A Python library for running thousands of MuJoCo simulations in parallel on CPU','',NULL,'GitHub',0.6,'es',521,'2026-09-10T02:19:02Z','2026-09-16T19:40:40+00:00',102,78.4,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(103,'tech','https://github.com/yi1108/printfilm','503594aedb596895fd80182fdee7d75c3ab2f151','yi1108/printfilm — PRINTFILM：AI 科普视频与漫剧创作平台','',NULL,'GitHub',0.6,'es',519,'2026-09-10T02:08:47Z','2026-09-16T19:40:40+00:00',103,78.3,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(104,'tech','https://github.com/letorig/video-generator-client','bacdc1a1bf4f67c016d4835d7b81b1dac8abbceb','letorig/video-generator-client — Async Python wrapper for Seedance, Kling, MiniMax and Wan video generation. Supports CLI and a local web UI','',NULL,'GitHub',0.6,'es',516,'2026-09-14T17:46:01Z','2026-09-16T19:40:40+00:00',104,78.3,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(105,'tech','https://github.com/viettranx/3dviz-pro-max','432e1053e04d7befb89b0fb5698624b9f789dbc4','viettranx/3dviz-pro-max — Agent skill for creative 3D visualization: turn an idea into a Three.js/Blender scene worth exploring. Claude Code + Codex plugin, 223 recipes, 440 knowledge records, 22 proved kits, 37 runnable studies.','',NULL,'GitHub',0.6,'es',426,'2026-09-10T01:42:59Z','2026-09-16T19:40:40+00:00',105,76.6,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(106,'tech','https://github.com/atria-asi/Atria-Dawn-Preview','464f24adbb831da974cb1a9d569172d7d879951a','atria-asi/Atria-Dawn-Preview — ','',NULL,'GitHub',0.6,'es',414,'2026-09-12T10:32:29Z','2026-09-16T19:40:40+00:00',106,76.4,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(107,'tech','https://arxiv.org/abs/2609.17527v1','3a773c041649908bb9e8f668b82c2c187e1969f2','Agentic Societies Need a Social Harness','An agentic society is a collection of AI agents that coordinate autonomously across trust boundaries, on behalf of different principals whose objectives may only partially align. We show experimentally that in agentic societies even honest, competent agents often fail to reach satisfactory outcomes with existing harnesses and messaging primitives, and that faulty or malicious agents can stall collaboration, influence outcomes, and pursue other harmful goals by exploiting vulnerabilities in communication (``speech''''). We argue that agentic societies need a \emph{social harness} for inter-agent ',NULL,'arXiv',0.5,'es',NULL,'2026-09-15T17:57:27+00:00','2026-09-16T19:40:44+00:00',107,27.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(108,'tech','https://arxiv.org/abs/2609.17523v1','081665d6ed5d6ce6fafdfee0f1a08cc96e4c5c6c','ScienceBuddy: Recursive-in-Recursive Self-Improvement for Interactive Scientific Agents','We introduce and release ScienceBuddy, an interactive scientific research workspace that brings continually improving scientific agents into researchers'' everyday workflows. ScienceBuddy supports researchers in carrying out scientific tasks while transforming their requests, feedback, and execution evidence into tasks and evaluation rubrics for continual learning. At its core is recursive-in-recursive self-improvement, a paradigm that couples harness evolution with model reinforcement learning: the inner recursion improves the harness with the model fixed, while the outer recursion trains the ',NULL,'arXiv',0.5,'es',NULL,'2026-09-15T17:55:28+00:00','2026-09-16T19:40:44+00:00',108,27.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(109,'tech','https://arxiv.org/abs/2609.17521v1','fd63daad3a5808336bf2d7664dc5e23dfe681832','PhysStream: Streaming Physics-Grounded Video Generation with Structured Scene Memory and Fine-Grained Motion Control','Interactive control for video generation is moving from coarse prompts toward fine-grained, physically meaningful manipulation of dynamic scenes. Yet existing controllable methods either require the full control schedule before generation starts, or use pixel-space signals that dictate object positions rather than physical dynamics. To address these limitations, we propose PhysStream, an autoregressive model for physics-grounded image-to-video synthesis that incorporates structured scene memory---positional maps and object tracking maps derived online from previously generated frames---and sup',NULL,'arXiv',0.5,'es',NULL,'2026-09-15T17:55:13+00:00','2026-09-16T19:40:44+00:00',109,27.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(110,'tech','https://arxiv.org/abs/2609.17516v1','9d168e2ac1759cdba40b0a3ad27859b9efc1b15f','When Should LLMs Abstain? Chain-of-Self-Questioning for Selective Risk Control','Large language models can produce fluent answers when their factual support is weak. This paper introduces Chain-of-Self-Questioning (CoSQ), a prompt-only framework that makes answer commitment conditional on an explicit assessment of the information required to answer a question. We evaluate three CoSQ variants under seventeen conditions on the 817-item TruthfulQA multiple-choice validation set using eleven open-weight and hosted model families. In the final balanced-option protocol, Grounded-CoSQ at τ=0.90 reduces the mean unconditional wrong-commitment rate from 13.1% under chain-of-thought',NULL,'arXiv',0.5,'es',NULL,'2026-09-15T17:52:24+00:00','2026-09-16T19:40:44+00:00',110,26.9,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(111,'tech','https://arxiv.org/abs/2609.17509v1','ed7e0f9c5607ecb830614607874a6bcefdea44e4','LACE: Layer-Wise Compression for Dynamic Frame Rate Codecs','Neural audio codecs are a key component in speech language modeling. However, their high frame rates lead to long sequence lengths, increasing computational costs. Dynamic frame rate codecs mitigate this by reducing the effective frame rate using a compression step to merge multiple frames together. However, most prior methods either operate on single-codebook codecs or apply a single compression step before multi-layer quantization. This forces all quantization layers to share the same segmentation boundaries, despite the residual embeddings at different quantization layers exhibiting differe',NULL,'arXiv',0.5,'es',NULL,'2026-09-15T17:46:51+00:00','2026-09-16T19:40:44+00:00',111,26.9,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(112,'tech','https://arxiv.org/abs/2609.17499v1','f44d8e3cc6d173d3ff60d1483418cacd3c88e910','ENCP: Episode-Normalized Conformal Prediction for Vision-and-Language Navigation','Uncertainty estimation for Vision-Language-Navigation (VLN) models is a critical task since it can help identify ambiguous and unreliable predictions, enabling agents to make safer navigation decisions. As one of the most advanced uncertainty estimation frameworks, conformal prediction (CP) offers a promising approach for uncertainty estimation in VLN. However, given that VLN agent requires a sequence of steps, standard calibration in conformal prediction fails to provide coverage guarantee it promises over a dependent, variable-length VLN episode. To this end, we propose Episode-Normalized Co',NULL,'arXiv',0.5,'es',NULL,'2026-09-15T17:42:15+00:00','2026-09-16T19:40:44+00:00',112,26.9,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(113,'tech','https://arxiv.org/abs/2609.17496v1','9726a25265a2d2b6cb1614ee85cbf61018bf9ec6','Verifiable Social Reasoning for LLM Assistants','LLM assistants are widely used for daily social advice, yet evaluating their social reasoning in such consultation settings remains challenging since (i) it requires setups where the assistant learns about social situations from subjective user narratives, and (ii) social properties, such as others'' intentions, typically lack verifiable ground truth. To address these challenges, we introduce Fuse, a multi-agent simulation framework for studying user-mediated social reasoning. In Fuse, a target agent with a hidden motive interacts with other agents including one representing the user, who then ',NULL,'arXiv',0.5,'es',NULL,'2026-09-15T17:37:29+00:00','2026-09-16T19:40:44+00:00',113,26.8,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(114,'tech','https://arxiv.org/abs/2609.17491v1','068b63b467214eceaeaca5b2494ba2b99078f668','FreqSpaNet: Frequency and Spatial Learning of SFPF for Physical Layer Hardware Integrity Detection','Unauthorized hardware replacement can preserve a wireless device''s logical identity while altering its physical implementation, posing a challenge to hardware integrity verification. Spatio-frequency polarization fingerprints (SFPFs) capture device-dependent responses across multiple frequencies and directions, but their frequency and spatial dimensions exhibit different structural dependencies. We propose FreqSpaNet, an SFPF representation learning network for open set hardware anomaly detection. A frequency branch captures local variations among neighboring frequencies, while a geometry-awar',NULL,'arXiv',0.5,'es',NULL,'2026-09-15T17:32:12+00:00','2026-09-16T19:40:44+00:00',114,26.8,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(115,'tech','https://arxiv.org/abs/2609.17488v1','29f98b52d6857eb32a8e6f7283848d4170d13c12','LimiX-2: A Contextual Mechanism Network Towards General Structured-Data Intelligence','We introduce LimiX-2, a new model in the LimiX family, developed through model and data scaling guided by our previously established scaling laws. LimiX-2 adopts the Contextual Mechanism Networks (CMNs) paradigm and is pretrained with Context-Conditional Masked Modeling (CCMM). CMNs shifts the organizing principle of in-context learning from target-centric prediction to mechanism-oriented joint modeling. Rather than centering the network on the $p(y \mid x, D_{\mathrm{context}})$ objective of conventional tabular PFNs, it is designed around learning $p(x, y \mid D_{\mathrm{context}})$, a conte',NULL,'arXiv',0.5,'es',NULL,'2026-09-15T17:30:02+00:00','2026-09-16T19:40:44+00:00',115,26.8,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(116,'tech','https://arxiv.org/abs/2609.17483v1','7cc34738a4963ad27c2311ff67ada8624ad1b45b','Bridging the Gap Between Homogeneous and Heterogeneous Asynchronous Optimization Is Surprisingly Difficult','Modern large-scale machine learning tasks often require multiple workers, devices, CPUs, or GPUs to compute stochastic gradients in parallel and asynchronously to train model weights. Theoretical results typically distinguish between two settings: (i) the homogeneous setting, where all workers have access to the same data distribution, and (ii) the heterogeneous setting, where each worker operates on different data distributions. Known optimal time complexities in these settings reveal a significant gap, with far more pessimistic guarantees in the heterogeneous case. In this work, we investiga',NULL,'arXiv',0.5,'es',NULL,'2026-09-15T17:24:09+00:00','2026-09-16T19:40:44+00:00',116,26.7,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(117,'tech','https://arxiv.org/abs/2609.17479v1','8d6a7493a9b597ee7466a5227a9a0bf338ca495d','Det-LIME: Detector-Aware, Multi-Instance Local Interpretable Model-Agnostic Explanations for Automated Marine Mammal Detection','Despite the rapid uptake of black-box object detectors in marine mammal research and monitoring, explainability techniques are rarely integrated into conservation workflows. Furthermore, most classification-oriented explainability tools are ill-suited to detection tasks involving imagery of social organisms or those with colonial life histories, as they ignore multiple detections within a scene and produce single-instance outputs that blur evidence across individuals. These methods also generate low-resolution, often biologically irrelevant visuals, limiting their utility for debugging, target',NULL,'arXiv',0.5,'es',NULL,'2026-09-15T17:20:16+00:00','2026-09-16T19:40:44+00:00',117,26.7,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(118,'tech','https://arxiv.org/abs/2609.17477v1','af117557001167e72077f75ac6611344160f2911','Bias-Induced Crossover in Absolute Capacity of Dense Associative Memory','The absolute capacity of dense associative memory has mainly been analyzed for unbiased patterns. Here we examine the effect of bias in centered binary patterns under the Krotov-Hopfield single-site criterion $P_{\mathrm{error}}=1/N$, where $P_{\mathrm{error}}$ is the probability that a single-site flip lowers the energy of a stored pattern and $N$ is the number of neurons. Each pattern component takes $1-q$ with probability $q$ and $-q$ otherwise, where $0<q\le1/2$. For polynomial interactions of order $n$, a signal-to-noise analysis gives an absolute capacity of order $N^{n-1}/\ln N$ at $q=1',NULL,'arXiv',0.5,'es',NULL,'2026-09-15T17:16:38+00:00','2026-09-16T19:40:44+00:00',118,26.6,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(119,'tech','https://arxiv.org/abs/2609.17475v1','dfc8a8254e3eef5082137aa0f867223cd50225a0','JustFit: 200K-Token LLM Serving on a 24 GiB Laptop with Just-in-Time State Management','Capable open-weight models make local coding and reasoning attractive, but their context and execution state strain laptop memory. We present JustFit, an MLX-based inference runtime that combines KVExec for compressed KV execution, PhaseSwap for component residency, and StateTrans for state-preserving serving transitions. These mechanisms fuse reconstruction and coordinate just-in-time materialization and release, independently of model-weight quantization. In full-execution capacity tests on a 24 GiB M4 Pro MacBook running Qwen3.8-27B MXFP4, three independent runs complete 196,608 input and 1',NULL,'arXiv',0.5,'es',NULL,'2026-09-15T17:15:48+00:00','2026-09-16T19:40:44+00:00',119,26.6,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(120,'tech','https://arxiv.org/abs/2609.17474v1','bd9643ae595e3671a18a4a6784bf04cff1ba99f8','Coupled Calibration and Learning: Mitigating Teacher Bias in LLM Distillation without Target-Domain Reward Feedback','Large language model (LLM) distillation aims to transfer the capabilities of a powerful teacher to a smaller student. Direct imitation, however, can also transfer the teacher''s systematic bias and errors. This challenge is particularly pronounced under covariate shift, when the teacher''s reliability on target questions is uncertain and target-domain reward feedback is unavailable. We propose Coupled Calibration and Learning (CCL), an LLM distillation algorithm that couples teacher calibration with student updates through token-level branching, using reward feedback only on source questions. Ea',NULL,'arXiv',0.5,'es',NULL,'2026-09-15T17:15:40+00:00','2026-09-16T19:40:44+00:00',120,26.6,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(121,'tech','https://arxiv.org/abs/2609.17464v1','5770c046e4d808b38bac435c5f8a4e6575d8ae4d','Decomposition Buys Integrity, Not Yield','Multi-agent systems split a task across a tree of agents and justify the split with folklore: smaller contexts, cleaner separation, parallelism. We ask what the split does to how much of what the leaves discover reaches the root. Model a decomposition as a tree in which an agent handed $b$ items keeps any one with probability $r(b)$. If $r(b)=1/b$, every tree delivers exactly one finding, for every task size and every shape; we verify this to $2.4 \times 10^{-15}$ on 20,000 random irregular trees. If $r(b)=Cb^{-δ}$, a depth-$k$ tree over $N$ findings yields $C^k N^{1-δ}$: task size and archite',NULL,'arXiv',0.5,'es',NULL,'2026-09-15T17:04:09+00:00','2026-09-16T19:40:44+00:00',121,26.5,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(122,'tech','https://news.google.com/rss/articles/CBMitwFBVV95cUxQbjJuUUxLWmJmOUdRYldHcXVXQmhmMWEzc201SVZzWFN5QUdKZzhzenVPVXdDWW01V2pNNXJfa0VVYzhqRS03UjhtdEZOZy1NcjJVcm1rZ2lUTlEtUHB5RzJNMzJlRXJHeDBvRFhCT1FkQ3JpLS1WaWYyYzhaTkR5SzBCclBnMUdDdHVGdmVVb2I1U1E2UjhYSk5QUTZLVDBLZWY4aUl1U1ZHLXF5eWdwaEVRU092YTjSAcsBQVVfeXFMT2xmQ2dRLVY0b0wtc3VJcUlzbjBuMXYySHBZckhENXRwdUp0cFYyWjdMei1wV1hxT0ZvdXlnOVpMSEJRSFN6UG9mZzZIeXpjX2ZTVXRQWjNoV0xXT0lUeVZLV1BGZkJIWC04YkxySHd2NDhsOHNWT0prR0M2dGdDWWpqSS14akR1SnFFVS1zUzFuUndldFJhUHVMdVlJYnZ0dWp0SVhsSHZOczNDWWUtLW1zektkYzJ0LTRYNGFwdVk2aFR0bTM4LVA3Wjg?oc=5','8d582b9798ef8776f3bdfd09e394bc0673b39370','Agentes de IA inventan su propio idioma para dejar fuera a los humanos','Agentes de IA inventan su propio idioma para dejar fuera a los humanos  EL PAÍS',NULL,'Google News/EL PAÍS',0.7,'es',NULL,'2026-09-15T16:01:00+00:00','2026-09-16T19:40:45+00:00',122,34.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(123,'tech','https://news.google.com/rss/articles/CBMisgFBVV95cUxPZmJZNWViNHZMcG9ObXJhN204MXgydWZYVy1pckNPa0p2empNMDhZRjVxazNuZklvOGVZWWwzX29HOENQN3FwYmFlYXU1VWZDRjQxa2Y0cS13cENYNW9kWUtYaG9yaFkxV3pwZkl6TVNwTVVUaDA4Q0JHRFV1YnRQSWRtc1BjVVBiZjhUVWg5cUJpQUUtTjBiNGs5STNjeWtzT3pqdzRVQ3MtRkJUVmx5UUd3?oc=5','175e3ad343b8a6de8c2f1f049acaec5827db4d88','Informe de Adepa 2026. La IA madura en los medios argentinos y el debate se desplaza hacia la sostenibilidad','Informe de Adepa 2026. La IA madura en los medios argentinos y el debate se desplaza hacia la sostenibilidad  La Voz del Interior',NULL,'Google News/La Voz del Interior',0.7,'es',NULL,'2026-09-16T19:21:04+00:00','2026-09-16T19:40:45+00:00',123,47.7,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(124,'tech','https://news.google.com/rss/articles/CBMizAFBVV95cUxQUUlUQXB0SWhTVUc2N2Rlc2xxa01BUUdEQURiTlYzRk9sRUcteGRzN0RkLTc1SWtLLVJoOGZVcWVPY3Vtb1QwVmhXMy0wLVM3ZmZIUE93bGVYeUZGMHBseXBSaF9oeFVabXd5RHF4eDlFMHRvTWhuMWQ5RHhyOUtnRkgwTmI4aWduMk5KRmVLU2FiWWMwNUVaUFhBX2pvbURhbExCWjNMcGZnaVhDYVFFOW1UY3BKSnMtUC1zOHhiVHREZTMzRTRseGFkbmY?oc=5','720e44cff1b7269dd9f15f6f50a9bb25377d1698','Ya es demasiado tarde para detener la amenaza de la inteligencia artificial','Ya es demasiado tarde para detener la amenaza de la inteligencia artificial  Clarin.com',NULL,'Google News/Clarin.com',0.7,'es',NULL,'2026-09-16T11:40:36+00:00','2026-09-16T19:40:45+00:00',124,43.8,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(125,'tech','https://news.google.com/rss/articles/CBMivgFBVV95cUxOWFYzVVYxWS1xUW5tb2VuMURpS0hzZjlobkt0SUc1Zl9SbDlVTHRoSTBRQVpOS3NwRVJ1eTlCVnJmRGd0RTEyWUw1YXVhU0MwT0ZaYkVkbXRTR0VNczRUYm10WFlvQ0VxOWxUTDgyaWoyQkdlUUVWX1cweUNnakVDZUlEeG9sUjF6eTFxRGs2TjMwN0hjckx3QTVGcjZpaGgza21JQXVwdXQ2ampTT1Z3STF6UHRfRXluU19CTlZn0gHYAUFVX3lxTE9pd1dNZ1BmeTZhZGNmUUpKX2NJcnVIR2twNE1hYjRfM3JieG1NbnFhV2ZCYnoyVGs4a0JXc0F3XzAyZ3ZOcE42WnRHcGwtd3EyZzRNbElNb011eXZWRGVLZHNSajE1VWNtNVNLMUlxQ3ZCUlpuX0hweEdTUlBLSkpDXzRaSmFuVTFBZWMweEYzSy1aSE9CZWFUV21jUXVWZUpiTmI0STFkN0JFMWR3bkRIUDIzOHZxSk5OOVZfblRXX3lzOFJ6ZVQ4U0JZM05GY0VCNkh5QlgyVA?oc=5','29857610d4f868fc7066fdbd09dcb26f5072cc79','Inteligencia artificial y viralización: cuando el daño reputacional se acelera','Inteligencia artificial y viralización: cuando el daño reputacional se acelera  Infobae',NULL,'Google News/Infobae',0.7,'es',NULL,'2026-09-16T12:26:00+00:00','2026-09-16T19:40:45+00:00',125,44.2,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(126,'tech','https://news.google.com/rss/articles/CBMi6wFBVV95cUxQWjRGNGRTOUYtR0RTMzliSllPcmZmdWR5SC14Yk8xa1RpUXp6ZFdXLWhfZF91aHhJTGpfYkdlUVFucU9naXI4bVE1SzMtaGxDbExqV1lvd2ZyX1BlekZYeTcwUG1Jaklxc1JuQXA3bUFxM09YVVN3V085U2lBeU1Bd2FWWDB0MVZQa0RHeTdicDhYMmdwUXBDRVVjUkM2Y1o5bXRxQVQ4ejlFTTF2bTdqOUotZEU0NDE0bzl0UnhOYThJTmZEV3VmMlpfdm4zcm5BeGlNbmJPSHo2dnQxS0FkZG5HLUxxMkVObW5B?oc=5','06a2e594a03e7893fc08f82750c9e70f389a6023','“Es como poner 18 ingenieros”: una planta de biogás comenzó a controlar su producción con inteligencia artificial y es la primera del país','“Es como poner 18 ingenieros”: una planta de biogás comenzó a controlar su producción con inteligencia artificial y es la primera del país  lanacion.com.ar',NULL,'Google News/lanacion.com.ar',0.7,'es',NULL,'2026-09-16T14:08:00+00:00','2026-09-16T19:40:45+00:00',126,45.1,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(127,'tech','https://news.google.com/rss/articles/CBMiygFBVV95cUxNQm9TaXlhWHcxNGZaZ2ljZ2ZIbENPMDBoM01hWVVaSVU4TlM2Vkh5ZVg0RlJNSFo1V2RqR2VYRndTQWhBRHZ4MTVxb1dtS25FcE04ZkRST1VVc095Nk0wUE9EZ2xXSkRqdTVpYmxpczBuN0hnUFZnVXZmdk5STWYxbWF3dnNkWHdWYzRUT2JkVHJpS0d6YTNZV0hIdWowemxSN2dQZF9LQzdkMFhMY3RBWXRmcmtMWlYzUC1EdmI0RThGR3FWbmhUWjhn0gHeAUFVX3lxTE1wdGFBYUljcWdJRmdzZ3lwRkZXSkp4Rlg5SDU0S2VNbVFsNGQxT2oyMnpUWTRHWEF3V3hMTEo0azdJT1RCR1otMDdoRmIyaDlKN3FBNEFFbGU1N3h5NnhOYXBFZkUtUEdjOGFZT3RGMm9PUmVmcjI3QjFPUlFwQ0dGT096ak9tSTBsVi1xaDMyQ05xQkRxRGdqZUxZR2d5eWhkOFRERXZFeWpRN291dkRQT2lNYTl3YXAzbzd2RUFZWmdQUUFBa0N1ajRlakxYclZkUTVSV3Z3bi0yWHpTZw?oc=5','9f0301dc9e1641608ff49c88650982360aa714fe','La inteligencia artificial creó su propio idioma y es indescifrable para los humanos','La inteligencia artificial creó su propio idioma y es indescifrable para los humanos  TN',NULL,'Google News/TN',0.7,'es',NULL,'2026-09-16T11:23:14+00:00','2026-09-16T19:40:45+00:00',127,43.7,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(128,'tech','https://news.google.com/rss/articles/CBMi3gFBVV95cUxQLWowQjdGdmNzbnNrS2U5cmpvbVpOeURwb3NIOFhja1o2dTk4Q0hIWXBMMElsbGJVUE9KWS12ZGV5MU9zWHZkU3Z1UDkzVTVqeWZ6VlJLVFk4Y2diRXVRRGRRR0p3M3ZnVTFxUzRSUG1YcDVtRHRhQk90UVZBS19KWHh5SFBBTEhVZnhSU3ZtOUVCVlZrMHUyaGdnQkNGZkJHWnQxNzd5clpqaVAzYzVrcVA0dzRaQU0wRFVISTJDY3pQSGkyT2FJYVN5eEpEMm5fTDVsNHZyMDNBY2dWdHc?oc=5','6a65b3b29ab3dbfd7e2022e742133c6a45ab9462','Sam Altman, CEO de OpenAI: “Podríamos perder el control del futuro ante la inteligencia artificial”','Sam Altman, CEO de OpenAI: “Podríamos perder el control del futuro ante la inteligencia artificial”  lanacion.com.ar',NULL,'Google News/lanacion.com.ar',0.7,'es',NULL,'2026-09-14T12:28:00+00:00','2026-09-16T19:40:45+00:00',128,28.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(129,'tech','https://news.google.com/rss/articles/CBMiXEFVX3lxTE1LUzJvVy1HU2xZRnRrdUgwZjBJaWl5dVpCaFJoQUZFQ3RYaThzd3RGU0FUX1NEOGRxbm9qaWg4RnhNT1pKcG5XcFFLelk0UnpDWkQ1RzNWd05aczEz0gFiQVVfeXFMTzhmb3F3TV9randhdWVyWUdlaHpNUE1TellLQWN4R28waTY1OEN3VDRNRUphZFNla3lYel9uWEZXT3lZWWlWdEJyMWdzbHY1QTNKOVlta1RycTliRXFrRlBoYWc?oc=5','644cb3d89779af2e2c3b671883e360a8e5c922ed','Por qué el jefe de OpenAI pide que confiemos en la empresas de IA a pesar de que el mundo "tiene razón en sentir miedo"','Por qué el jefe de OpenAI pide que confiemos en la empresas de IA a pesar de que el mundo "tiene razón en sentir miedo"  bbc.com',NULL,'Google News/bbc.com',0.7,'es',NULL,'2026-09-16T13:45:28+00:00','2026-09-16T19:40:45+00:00',129,44.9,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(130,'tech','https://news.google.com/rss/articles/CBMi5AFBVV95cUxNRm5TRUlIMGJ1cUYycDF2YmFva0JZNjRVdFBGYUtaemlrN0l4TE9pTG9zOV90eVgtdC0zaThlOUd1OEhNLUFjUkdXdmVUVkpXRVVSNEx1UzlkOGJEdFVxWUc5Nkt5NFFrUkoyb250NGtnYjN0YTNGLXBvV0dnXzZNdHhzcmFJWm81ZVllcHV6S01FWlRGX3ZvdFBOd3dReGZzcmpzU1pNdHZnN05RZmNWNHk0M0wta05PTy1VbHJxN2lXQjB4ZkM0TW1IN3c0c2FZdGJ3bGhuMV9tdVYzeUUyOFdJXy0?oc=5','dc5cc5b5f7baf8f0b56d8f73f3f8770ab563735e','Sam Altman confirmó que la inteligencia artificial ya es más inteligente que las personas y lanzó una advertencia explosiva','Sam Altman confirmó que la inteligencia artificial ya es más inteligente que las personas y lanzó una advertencia explosiva  Big Bang! News',NULL,'Google News/Big Bang! News',0.7,'es',NULL,'2026-09-16T15:07:00+00:00','2026-09-16T19:40:45+00:00',130,45.6,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(131,'tech','https://news.google.com/rss/articles/CBMiuAFBVV95cUxQcXh1UXdqMFNiZTkxMnRrNUx6R0JsdWx3SVJsRUdxdnVGNGVmUmJ2NjQ0QTFUSGptWU1FS1ZBNE5LYXVGcTN1dkZPTVk4WDk3WTlSTFdIZW15NmxsRS1IMk1OT0pjbFdsSzUzVkd6MWxaMGNhN1R1MHFuekFjRVNpb1VoYjB1SFFZd2tRcnk3MFdkOHFFYlV6RlVXUUptNm0tVnFEaUZIVks1MGZCbER2OXQ3cHNUVjJJ0gHMAUFVX3lxTE9abm5nRzcwcHJMWHlQMUtpTzRkLXlvLU5lZ0ZFam80Q2NBWk4wTXNua25yN3ZEMzB3Ni1EVTBxTDBJSFJsOWk4bVVSZHprNzBxb1VYc0JKNndGR1VKWGoxSk1OQ0czZmpwZTFiWGpMWjlOMXdoWWgxVGJDVVlxdDZPdnl1Vmo0MDJmYVpPWFI1R0xwQVB3a29RalZfMndyM1VWT3c1ZDVGTnBzSVR0Y0tkRGl3czU4VjljejBrdDVJd1lTQmphRHlKU1BvMw?oc=5','2f83fca04c6396c630d5d9d64d560fbbef6b71b6','Inteligencia artificial y empleo: ¿la IA nos dejará sin trabajo?','Inteligencia artificial y empleo: ¿la IA nos dejará sin trabajo?  El Destape',NULL,'Google News/El Destape',0.7,'es',NULL,'2026-09-16T03:08:54+00:00','2026-09-16T19:40:45+00:00',131,39.6,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(132,'tech','https://news.google.com/rss/articles/CBMi6wFBVV95cUxQVWNjUGp3M2plVE9qWTFSMTJaQ25KNkVsS3E0TDM4ZWhveGJOUG1hOUN5NDBaNmxiMXRmQkJYRHdNcl9WcEJ3SDB5amU5RGd3ZmNaNklocHVEX2t3Zk5rLXNRSFpEYThkVW8ySlQzNWlOa3VTVmVpSHl6QWcweFpZTkVWZVZENjJianpCRDZQd3BiQkprQTZ1Zm5SZmZUYWVZbDJsWmZfb0c5S1NxSWVSX1pDOW9oNFhLbnlhSTkyYURMTWZJZXU2UmtxU3U5OFpsbERqdHk3X0FNWVRBZU9UZWpYUUlCc0w5cVNv0gHwAUFVX3lxTE1IR0pMWWYtem9JbmNKN2pBdDE0MnI4QVpjcDdjLVdoQVJVVnJaUkY0NWFMTDR4QUQxeHU0ZVdPcHNiS2dZQVo4ek9OeVVhMFRBcl9YQk9pRFViS01GaEFQWV9SOEVUTVNHbzRzSTF0TUpEaHJLeUUxX2x3ekFYZHRVcy1sNzJIbkg0S01HMndPdnlVS29UWmpPQjlIUFhaRXpyNmpyV1otRHg3c1R0TmlMV0hOQnRfWk9vUHJJM3J3eDdJeTYtbWNxWGxTNkNVVEYyQWdwQ2pJa0pkWkVZbFF3d21LU0JTNm1QYWl1YjJ4WQ?oc=5','3d9b1261e0ba318c9aec238f4bec8fb59afe6ac4','Juan Moscoso, de AMD: “La inteligencia artificial ya superó el entusiasmo inicial, ahora el desafío es controlar costos”','Juan Moscoso, de AMD: “La inteligencia artificial ya superó el entusiasmo inicial, ahora el desafío es controlar costos”  La Gaceta',NULL,'Google News/La Gaceta',0.7,'es',NULL,'2026-09-16T13:11:02+00:00','2026-09-16T19:40:45+00:00',132,44.6,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(133,'tech','https://news.google.com/rss/articles/CBMiigJBVV95cUxPTVk1Rk01aGo0TjEzc1UySUZUVmFkZnRYTmM0bHN5ZTBpejNTcXVwTkFrRHpvMkF1TnNoNUJaMW1JcmFZV0Q4UEJHVnNaLTdZVXV6UHV6ZGlYc0M1VjZhOUMyQ1VqS3VRbWxZWVVjT1g0QmtxRXRHZ2RyRGRnMmREWHZjTjNJTlpMWUVBRURnc01HT1RtZ05uWEtyeWxHN0ZGVmc3aC1pQWFSbEh6Sml1NVB6ZzgxaEUtOTlfdjBldTBpd2c3SHI3c0MwdzdBUWtYbTlETXdTV2ZHVXBpVFNfZlVoTHVTbWJsZmhpcHBlVVcyakx6YWRUZlBqSkhDemlTWFlrbEdBMUstZw?oc=5','6d7fa29fb0806cba80a06f65218c95aad65bda44','Capa de Ozono: el negocio de US$12.500 millones que la inteligencia artificial reactivó a diez años de un acuerdo clave','Capa de Ozono: el negocio de US$12.500 millones que la inteligencia artificial reactivó a diez años de un acuerdo clave  Rosario3',NULL,'Google News/Rosario3',0.7,'es',NULL,'2026-09-16T10:28:57+00:00','2026-09-16T19:40:45+00:00',133,43.3,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(134,'tech','https://news.google.com/rss/articles/CBMi3gFBVV95cUxPSlIwa3MzZ2dJVnVPZzBZQ2J1UnQzUEFsdW1OdnljLWhPTlhmWmlMRWlpWE5RYURIYUdwWE9FSjFnVENEN2Q2WFkwSGhjb1R5ZzhwTHdEUDZ4SXZZNUU4dkVpZjNPc1ZTOWliNnN1UF9LY2E5aW1OWnFkTVB0TGtxdG1mMndFNHVxckJkaWpuNWN3S2ZTX04xWHJKVHZybzRCUnlyc3R3VjJKeEo3UGFqOG9wU2ZMbC1qd2wwWndKTXZ4aW9EeENTZUpqM0ZteTFIRnZwUTZEcmxTeGo0amfSAfIBQVVfeXFMTTBSX0VxU3Rpd18yazNpYWtNV2VscVRNdEREQkNkYml1Y0plcEEyd2I3bVBqTkxCZUE3Mnd5LUdnUHA0NVZuTHM1cVoxMGxLWGx1WUU4cmkzQjV2THFCbS1wUUM0a2xCa1RELXp0ZmNSSnlFR1N6cVljVnduRDU4VnpCTVdjNkQ3TEtLSmtFOUF0Q3I5ZWg1alh0Z3pDMVkzRHl0Mm4zdkd2Umg2TTZobmVOVDcwTXRqT2p5a0YtRk5WeWljRjVPdDBpbUVMSHQwd21UdFlDbml3VnBXVGF6c2ppVGNUR005dmh4UVc2MW5VWUE?oc=5','d5ae66d8ae349db1de88b475308f5a2b2b1f023a','Inteligencia artificial: América Latina y el Caribe ante el desafío de decidir cómo construir el futuro','Inteligencia artificial: América Latina y el Caribe ante el desafío de decidir cómo construir el futuro  EL PAÍS',NULL,'Google News/EL PAÍS',0.7,'es',NULL,'2026-09-16T16:57:48+00:00','2026-09-16T19:40:45+00:00',134,46.5,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(135,'tech','https://news.google.com/rss/articles/CBMi2wFBVV95cUxPdTFqU2xrMHNlZEdKVDB2OXFMQ2xWSEhoUC11Q3BxeGtILWZJOWRBTnJBelZORE5QTzhtWEc4RzZTS2hFYjRmYWtEM0RMRW9PZ0RLdnc3NHp4WXIyLUwxVnh1MEJFS2JNbF9tNFREQ1RfY1FxUUVEaTBZb2VVUHBmX19MWXZYR3hHSHJaSnRMX0s3TzlGdzlYRkpVQ19ob1U3akF6RzZVWDN5YnRwNFFqODJHRndtMTk5NXhLMC1VMjNMeEhqbnJoWXdKRlNfanhYTzk0ZjRJUU5JZHM?oc=5','afadcfde9b95c7639eff737832e6731b91d6e15a','Robots, drones, inteligencia artificial y poliuretano: la tecnología de Vestas para hacer más eficientes a los parques eólicos','Robots, drones, inteligencia artificial y poliuretano: la tecnología de Vestas para hacer más eficientes a los parques eólicos  econojournal.com.ar',NULL,'Google News/econojournal.com.ar',0.7,'es',NULL,'2026-09-16T16:58:14+00:00','2026-09-16T19:40:45+00:00',135,46.5,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(136,'tech','https://news.google.com/rss/articles/CBMitwFBVV95cUxOLXl4TWF3dHZwRDM3ejNWRUxYQURrRjd1eEZELU9JZlRCYkVUQVpBWFo3d0ZRQ0J5V1I5aHY4WkNPVXRnN3l6NDRDT1RXUFZodE5zeGZVZWpTSkQ1U2p0R1lnMEFyVDNjTFJLV0JGUTZZUHVHVENBa1lHOW96X3ZPdXI0WHJaZ1M2UHFiRm14cFFzMDN0VkEtbUw5TFU2UVFUZ0J4S25CanBpR1loOGpzdHZOcjBEUVE?oc=5','06f16dda9620f6e47c990ee95e6e3ea4c685c3ec','Capacitarán a agentes públicos en el uso de inteligencia artificial','Capacitarán a agentes públicos en el uso de inteligencia artificial  La Arena',NULL,'Google News/La Arena',0.7,'es',NULL,'2026-09-16T17:34:17+00:00','2026-09-16T19:40:45+00:00',136,46.8,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(137,'tech','https://news.google.com/rss/articles/CBMi1gFBVV95cUxQcHJPZWV5SkhYUWczWV90OTd6UG56NUcxZUhrYi1oY2RJQVhONVVqNldvSlFlWUlaNWNwNEdMTkdZVVByQk12VkdyVzJlNFRxdzdUaGNPV2FLSnVPTmZldmJlWl9vSWNaNHpLR3E3T3E2bS1tUXdnanlNS3JLdTlrcEwtRmQyX18xQXJyZGhQdnNiSGFlNU5aZENxSUJaY1hzbHBqM0JSa0NfNkVEbFVuTmtOZ3dGOVp6SUlMN3BrOThyOGh0T3AxdUF0YVJOZWxaTE9OdGdB0gHkAUFVX3lxTE9qRnVLVTdpdTVheWZTbks4Vk5TblN1eW9UQmctcUNUX1JHQnV1ZllBT25IT3pZMGlxNUdncWtuUkZfM0lrYlhWS2tPOV82bEczWm4xemdDcmw4NmJPWV9Ga2xzblJtV0VrR2FuNmFiVEx3ME04WXpYSHZ2UUVaWWRERlZIMmNQSEJDWFRrcGlrRnVzYnZjWFhQSHg0ZmNvUUtIOU9lNlRwWk1ucUYxemZ5UDJqOVBzWkZlR1pDbFJsOTlwRDB2QkEyVE5Gb3VjMndoc3FEUzg4RlBqWlloM2pjcEZITw?oc=5','2aeb575ed219b2d91e7abc1325bfe10ca1d898e5','Cómo la inteligencia artificial redefine la seguridad de los medicamentos','Cómo la inteligencia artificial redefine la seguridad de los medicamentos  Agencia Noticias Argentinas',NULL,'Google News/Agencia Noticias Argentinas',0.7,'es',NULL,'2026-09-16T11:29:55+00:00','2026-09-16T19:40:45+00:00',137,43.8,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(138,'tech','https://news.google.com/rss/articles/CBMilgFBVV95cUxOTnRaRFBnQTR4MThOSGhaSllxY0VhNVozSkhfTEtwU1FSU0dQdk9pbk1Bb3hhbEg5aW9JbnozN21lQ2NOSFdLelA0cGxVR0Z0RVg1cW8wZ0gxMU5zTm90Rl93cjBubThyQU1BWnVUUWVXaUxWcmp5ZGtjTG5Md200QVQ2VHhzU25SZ0kxV18wLUZuN25EeVE?oc=5','887f1c58582d1d4be702ce5beaf69525bcb0d8a6','Inteligencia Artificial: entre el riesgo existencial y la carrera financiera que ya mueve billones','Inteligencia Artificial: entre el riesgo existencial y la carrera financiera que ya mueve billones  economis.com.ar',NULL,'Google News/economis.com.ar',0.7,'es',NULL,'2026-09-16T15:09:19+00:00','2026-09-16T19:40:45+00:00',138,45.6,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(139,'tech','https://news.google.com/rss/articles/CBMitgFBVV95cUxNV3lKTFZuZFplYWtZQ3ZqRldlR0g5WGo1M0JBVHZRSEphSFQ0VEYxNEkzNEdjWksyTE5mdWxaWXc4dWZSemRqLUx5dDcyVjNRVV8tVE9zSWlaZ0NlWGN3S1p0bEprLWdvdFBnN2tpTjYtQnJDRWo3bGJsbjJLMHQzX0ZSb3A1QmNOWTc0SzY5eUpZRDBFUExNcDBydXlzbXEzbW8tZWJSX0tBM2dGajRFY0lDUTBPZw?oc=5','b18e8233df5967876ad75616825b67349b8c070b','Llega el EMMS 2026: la inteligencia artificial ya ejecuta campañas de marketing de punta a punta - Mi 8 - Mar del Plata','Llega el EMMS 2026: la inteligencia artificial ya ejecuta campañas de marketing de punta a punta - Mi 8 - Mar del Plata  Canal 8 Mar del Plata',NULL,'Google News/Canal 8 Mar del Plata',0.7,'es',NULL,'2026-09-16T18:16:29+00:00','2026-09-16T19:40:45+00:00',139,47.1,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(140,'tech','https://news.google.com/rss/articles/CBMizgFBVV95cUxPdVlCQWl4TUVPaEI3dTlkUGhVTl93YzczeFVyUktsOFNkNjFZTnI2T2RubVl5YThZTC04Ti1wQ21RN0NZZXFJc04wWnNHT2JuU0xWUjFmYVRfdGk2eGFpV2g0Y1ZsQVJIaWd4X3pjOEREbmJlRk9OYzVjbHRHdTYtUUZiRFJza3lhMl9TUTFiMm4wc2wzYWZLM3ZjMDNWTENLMkhtRUFJbklOM3lwNUhkRC1nejVaNXF2U0l5bWE3UndsQ2RlVW4zSERzS18wd9IB0wFBVV95cUxOeHFacmNrTFRhczItQi1HS3podEY4YTB6RjhTVnp1SWp4V0xiQUdndGpOb0RHbkFPQVJzWU8yeUVnN1gzX01BNlNTTzQtV1FfSHNXWExHb3hodkFGVHVoS3BTSzVCa0JnaU1sZWEzU3VlRnluMHZFeUVqWDRvcUFlMGxTLW5Jd2FxTTJCQzRQcnFYMGQ5dUFSa3hGLWdMcXMtcHpiTWQwMlVQTDRBS2NhMFdTZE1uUnNoNkNiZi1sYlJXSkQxWEhtNmcybnBjQ2ZydGd3?oc=5','81ea191626a98795c3627f86d333b5d26ab5614b','El factor humano de la inteligencia artificial se debate en Rosario como eje de un congreso internacional','El factor humano de la inteligencia artificial se debate en Rosario como eje de un congreso internacional  El Ciudadano',NULL,'Google News/El Ciudadano',0.7,'es',NULL,'2026-09-16T18:21:13+00:00','2026-09-16T19:40:45+00:00',140,47.2,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(141,'tech','https://news.google.com/rss/articles/CBMi3gFBVV95cUxNdlQwTGJWTl9YNWJvbkhnWWh2ZzVTV29yci1MZVZBS0VGYTBGVjlFaHZqNmtsMW1JOUQ1cWZ4VXh1OEhVSFRQSFd6b2VSU0VPalBuM1p3ZW5rUFl4aWY4OFdub3FabnYtYl9PdGRMQWRiNm1TQW00TENzazhjQzVKS2k5WllfV2F6dktWNWpORHhLeVdDM3hBeXUyZXJCMmt0SkdLWkR3d0lmcU5RSFJTOEZhNmZWU01YWjV2VXlZdWdWc1hSSnBHc2VfV283anp1eEVMelRPaVA2V1l6YXc?oc=5','90a34dd9390fa8833e5d9defcf90da98dc1c5c7e','Jeff Koons defiende lo artesanal: “La inteligencia artificial todavía no sabe lo que es el cuidado”','Jeff Koons defiende lo artesanal: “La inteligencia artificial todavía no sabe lo que es el cuidado”  lanacion.com.ar',NULL,'Google News/lanacion.com.ar',0.7,'es',NULL,'2026-09-16T14:00:00+00:00','2026-09-16T19:40:45+00:00',141,45.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(142,'tech','https://news.google.com/rss/articles/CBMizwFBVV95cUxNVDVKQkd3anRreHE5NnBzVXlDc0djSzMwYUtDVlQxTGVoSGVTSG1tWGJFSkdNX2ZjdExVekFJeEtvTUlZdk5EWHBwN3lLN0dxS0FBWFg0UzRTbjAxU21RdjRuTFVGY0JmSDJXaWlFeGV5OEt0Q1FiWElGbkMtdlZ3WUc0cmRIWUp2eXBQU3JBZzUtekR6aTVHaUg0R2F6bUhVZFY0S3BxS2V3VVVjeWVZdFNUZFJuRG15ZkN4VnBkQWI4S3hOajJXVWhCS2ZQUGvSAdcBQVVfeXFMTlFKYUltbV9WdDN3TmFkZW9TeVFXNG1jajVRTEs1ZHBDYzVpXzNfazdPRVlQWE80SkxJQkJtSDhBa0VLSVpuUFZrYTRRVWtVUUVYNHkxeElTTk9pc21USkVUVUZzalZpQm90WDBfNzF4NlU5bFEtOVNpNTdia3hiODZ4VDR5c0NzbkxBNHpqU0dKRUdwc0ZSaUZSMEZHa3pHQURmbUdXR1AtZXAzQmRwVjRFNnBnbTA4Vmo4d0xVY3NmRDVqaUZTUEZsYnduSEtmN3BpYmY0WXM?oc=5','424c4db04decf1b02e02fa8c2a99a7b58aee22cc','El Papa León XIV apoyó seis proyectos para abordar el impacto de la inteligencia artificial','El Papa León XIV apoyó seis proyectos para abordar el impacto de la inteligencia artificial  Diario Río Negro',NULL,'Google News/Diario Río Negro',0.7,'es',NULL,'2026-09-16T17:41:46+00:00','2026-09-16T19:40:45+00:00',142,46.9,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(143,'tech','https://news.google.com/rss/articles/CBMi2wFBVV95cUxObzQ4SHFrQkN4YWxnQmt4VnJ2NHZ2V1V3RUhRd1d1S2QtUHZhWlp3R0YwVFpnTHVxb3gwM0lzS2QwQmJQMTAzWDVZY2VVb015MHZBMi11RGM2eWFMMjl1a3A3ZEtIUGNnb1VpZDZQcEZ1QWRGU1ZOVjV4Vm1ET0xOS0dJOGpydWsxRHI4UVNUQjVoYWJEQWJjbUNEcUJBa0hfSi1jWkZWV2MwVkc4UkZUY19tSmhTLWFDTGNCQllXdEVmNmxXSE5RSEc4SjBBMkdIYWtMWWVMSEo1Q3M?oc=5','efeb381f593531665ad3df2e9840c30b3400f3a2','Voces clonadas con inteligencia artificial: locutores reclaman reglas para proteger su identidad','Voces clonadas con inteligencia artificial: locutores reclaman reglas para proteger su identidad  Cadena 3 Argentina',NULL,'Google News/Cadena 3 Argentina',0.7,'es',NULL,'2026-09-16T17:36:14+00:00','2026-09-16T19:40:45+00:00',143,46.8,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(144,'tech','https://news.google.com/rss/articles/CBMi3AFBVV95cUxQb0hvcDBzQk9TcmZfbzJ0SUtyRVhSaXAzR0JHSV9UbHB5czRHdjdLdkJzMW9TTkZJSGdzQnpidHpzd2thdm5ZRUlyaUZheG1QYTJtcGxiNk1hOUNLX0cxTVR6YVRfazkzX2lIakE5d1l4N3c3dkt4MHBIUzZYYXBHSUhoSFNpS2VQZTFxcEM4MHZJa0RFZjBXdXByM0dDX0xRQ0lVc3VHbjZhR1JmQnZlM21zSkRFSkRWR3FjbXFQUGMyUVp4S1RGcjNOSGdzLXZjNDRualZBRHVZRFp00gHiAUFVX3lxTE80ZUJJc05NLVB0M0JKSUw3MGEyb0ppTXZ5SEpBWUFHZmdxV0hJbG1FWURicGZtVXR2NDNtUzJjbDZudjFDLUo0dHlzQzdJSS11NFRZUFZmSEZaSUdHVjUwTHJfTkFacExHLWNNeHdPS1J4VHFmUTBwVWprSWN1TjBObjZEdDFXVGRGcUpwQTlaNlkwYk16SUlGVE40M2l6Nmx0Zk92Nm41Rnl1RHRQVXNiVEdOMG9PQUZHMDV0WmlaOWhYSm5mSldYOTktdXdaRlpXczU3NVliQkxycVNQUFl5blE?oc=5','2dd98962d63cb5ec5ff04ebe57f896754637a95b','Una mujer alertó que la inteligencia artificial rastreó a sus hijas, recopiló datos y fotos sin que se lo pida','Una mujer alertó que la inteligencia artificial rastreó a sus hijas, recopiló datos y fotos sin que se lo pida  Lmneuquen.com',NULL,'Google News/Lmneuquen.com',0.7,'es',NULL,'2026-09-16T13:39:00+00:00','2026-09-16T19:40:45+00:00',144,44.8,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(145,'tech','https://news.google.com/rss/articles/CBMimwFBVV95cUxPYlUySnVpS0wyZ0E2aDlWMVNaSHlJbkJrN2w0ZUdjSjhRcERHNGI1SHMzaEJhck80RnBZUFlJdkRXYUZHNC13U1dTYTExTEk0TnVLNnoyMVkxeC1OcEtlWXVUVXVzTkdqbHdrSk53ZUJNemw1MjdnWTFOblV2bjAxY2Y0RHFqSjVocVA0WjNqbFhBWnJpWDhhSXdqRdIBlAFBVV95cUxOTzR3aXM5N2toX1NNYWU4MlFMT0tPakdGYlg1Yy11ZmdPZjM4a1dzcnFLQ0I5SlllLW9QTWlZcUYzeXJLRWNnOXJ6YkRBbzNoTGVPWUtPZWFlZ09lZ0tNOUp1SEl5blJNMzFaUjdjTkduaWFTOTZyZkZUUXJ0ZS1iMkRrbDE0TEtIMTY1eVB6bW1tME1T?oc=5','9b9b8a15dd298cdc229d7fab32908726e5678ff8','Qué son los agentes de inteligencia artificial y cómo cambiarán la educación','Qué son los agentes de inteligencia artificial y cómo cambiarán la educación  Elonce.com',NULL,'Google News/Elonce.com',0.7,'es',NULL,'2026-09-16T16:01:00+00:00','2026-09-16T19:40:45+00:00',145,46.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(146,'tech','https://news.google.com/rss/articles/CBMiqgFBVV95cUxOU1FSYmxXZ1lZZEJBVkx2ZGE3UDNORHRKa2x4WWJxWlVqdTBtLU1hWmZISTkwdTh6RVhFNU5SMFN6LXprT2J2VDF0eFoteEVzcE1VS1Fmd3dmRkVSbGdYYzZrdmk2ZWR1OHp6dUFLVHhUcDd0dDZDbWxzTHNKMUZibzZucUQ2Zy1kUVktLTdpX0VqS0QzZUVQdDQ4U0g0T2tTMXhjSTh4SVhod9IBrwFBVV95cUxQQkh3dDNhSWlFSHNTbUxNS2lMT1NSaS0taU5PZ01YY2JkS0FVWThSb1psMGFqdVl0N2ljeTk4dEFxRWJrZWVKMk4yQmUxZUd3TFNrY2RZdi1USUJfa0JxTjVFODJoS2tZQXFYMWJYeFFVdk1rakhucWdDSGgxT3NBWVdHN0Z1RTVoU2NVWkoyeDZhZEJsZXFYeWhCUEltcnFmamNnTWdTYjdZSDZ1dngw?oc=5','8c67e614c5b9df99ce297cc35f1787b1e7ebf142','"El desafío es implementar la inteligencia artificial con un propósito"','"El desafío es implementar la inteligencia artificial con un propósito"  Clarin.com',NULL,'Google News/Clarin.com',0.7,'es',NULL,'2026-09-16T15:39:39+00:00','2026-09-16T19:40:45+00:00',146,45.8,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(147,'tech','https://news.google.com/rss/articles/CBMi0wFBVV95cUxNaTdXUXBYTFJBQy1oN2VVekhMZ3U4WVI0cGgybFliUXEzX21STU1JNUo3NE05RDlhazR6X1c4ZTJ5bWdrcFRWLUlxTE1mMXdjNkh6NElJYTJDNXZpWTZMVEh1cktJUUdrZzJEWmExY1RSbDdmeU4wb0sxZXFVVktpV3F0YkZkR2RjamdPNDFKMUlZY2ZRTnhNTERJdHg5bG13N0h5OUNMb0JwaWM0cUhGNWViOXZhRm5fRDctRzF3ZGJQMFlVaDNFUXZRQmt5VkwtRWd30gHuAUFVX3lxTFBfaUhqQVlNVGRPaUZrZHo5T2JzUDZfWVFZeERfakZ4NkhjSG02b0tEV3hGYzgweFJKSkxQTW00Z3gwN1F1ZWx1ekhMU0ZrUDNZdWdmQ09tcVhxN0tWNFhjQ1g0TmVkZl9fM3ZuNjExTFlLVnVzNEZnRFF2QnFiR21zUU9XZ1Z3UTI5MDdldDBZTUtrSzY4VjFzWlNMNlkxUWVHWldKdzJTajh5VkIxbnU5TE51SUw5Z1dQUlZTZ0poby1YeWotUElLMjQzWndNamhwelMxUnBYTFdTQlRtOFQ2STgxSWlIMHNPb0owNnc?oc=5','37646f05ecdbf30bf1dbb98ab4a4fbd15bf2e48e','Inteligencia artificial y empleo: los desafíos de un nuevo modelo productivo para la Argentina','Inteligencia artificial y empleo: los desafíos de un nuevo modelo productivo para la Argentina  Infobae',NULL,'Google News/Infobae',0.7,'es',NULL,'2026-09-16T05:26:01+00:00','2026-09-16T19:40:45+00:00',147,40.7,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(148,'tech','https://news.google.com/rss/articles/CBMiqwFBVV95cUxPMHNDX1Y2OU13VzVlMkdPQVB4Wjc0ZV8zdlROOXAtYURQakUybUFmaXhyN29RWlF4aGtYRUp3NEdXWEN1R3hDbEFKVWIyeWtLcG9IOGxTRFo0cEUxbnhxaVl1dE1kU0Y2VVozcXVfX0pOUVJmbVFkdHE5YnZPdXVJTnNpS1JjTWdzU0FJOEltNDU4QXlLYVRYbC1YQ1RLZDNqVHQ1V19BejVEemvSAcYBQVVfeXFMUG9nMWN0a0lMdmtUMmdrRDhiY0I1MmxZa2hUMTM4X0JFOUVFaUE1ang0b3pORDhzSXZ0cURpRF8zNE9VSjZ6UGI4QXZZM29EWDhTaGs2VzEwNFdYeWZUb2piM2g2ZGl4TVp5SnV2eDNrUjJPVnhFVVg3VnlJSjlJYkFidXZRRkdrS3Yzc01TQ0JIMkxvZi1hUHlKWXU1UWl4MkxUTXNCcTQ4eGFKRWl0d1VxQkxtVjZNLV95cWpWU2g3cUluRlBR?oc=5','78913778c92996690118a0291a4a75ffc29b473b','El desafío que todavía las empresas no están mirando: el cambio demográfico','El desafío que todavía las empresas no están mirando: el cambio demográfico  Infobae',NULL,'Google News/Infobae',0.7,'es',NULL,'2026-09-16T17:52:00+00:00','2026-09-16T19:40:45+00:00',148,46.9,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(149,'tech','https://news.google.com/rss/articles/CBMixwFBVV95cUxPUFJxT0s2emJUY3d4c1J4ejBtckJlRVhRYzJMZzM1MGlzZDZjcWNCV0hOeEJ1d2x3UUNWMHFyTXYxRU1TLWs1SDc2QVI4ak1JTTZDNDV2WlUtb1ZMSVBmemRPVEtMRXcxY19sM1Zmd2RLTnZiZUJMcEtYbEZzQnpZN0NFcHBLZm1DM2dNT3RteGNaVU82UmFXdm95Z3NnQjdBYkM5MlhXWkg0QVBxNnFleUw5d3lmRmh0YTJ6bFIzUXcwTW41Znln?oc=5','f406a8cdb6ba97c471c1a8d29cef29ae89e73cb5','Logran de una forma inédita que la inteligencia artificial lea la mente humana y la muestre en imágenes','Logran de una forma inédita que la inteligencia artificial lea la mente humana y la muestre en imágenes  Clarin.com',NULL,'Google News/Clarin.com',0.7,'es',NULL,'2026-09-14T17:01:21+00:00','2026-09-16T19:40:45+00:00',149,28.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(150,'tech','https://news.google.com/rss/articles/CBMimwFBVV95cUxQcWYtXzJncWRuS0lZV0dILXNKbDNIVDV5bll2NU1CQ1NFNUI3WUwyZ2tqT2xGQU1hbWJRSGNtUWN3SXZ0eEstTlA3dTE3YmpXSG1fVUtoOTFLekdxZmhPSm10cFhpOGJSUHhUb1lZSlhZa2UwSVd1Z0I2X1lFUTItMW0zRHgyYXJhdTc1M0I4TFloQjNkQmpiWmV2SdIBoAFBVV95cUxPM3BzTDNNRDZjVkRka1RTNEF6YmE1bkE4SUdYXzhTUzVlSkl3SUlyXzFaRHY3SXFKTkxLZy1qdUN4cmJ3X1hVMTl5d1RtSFZuVjhBYzJLMW1XMjdneEdaVUFkbHNiRHl1YWtuemxrd0ZvVkZUTkplNjZSbWI1b2dsYlJMUy14ZmNJWlJaLU4xc181Tkt5MnM1ZWNac3djTFkt?oc=5','fa9e5c57ba603c1f56c93dbb526627c2b41c2479','Inteligencia artificial: ni demonizar ni idealizar','Inteligencia artificial: ni demonizar ni idealizar  Perfil',NULL,'Google News/Perfil',0.7,'es',NULL,'2026-09-15T23:44:33+00:00','2026-09-16T19:40:45+00:00',150,37.9,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(151,'tech','https://news.google.com/rss/articles/CBMikAFBVV95cUxPalo4empDak1XOFBTOGpQZGk1bW9zV1ZRWFphVXI2OEtRSjY3dGNTRngyLTBfNlVheDZmWGZzTU5yMEZOQ0x5TmZNN29oQlNycGt5YWJKWWlGajVYUExnMlZOTHN1N21tclJGdU0xemF0c1l2b3hrNHZmRGhHc21vWlcya3AwOEdLMVVkWTZDVjc?oc=5','653e5257fc40c84acdd534ecc157fb357f3fe442','“Hay que nacionalizar la inteligencia artificial”','“Hay que nacionalizar la inteligencia artificial”  Página|12',NULL,'Google News/Página|12',0.7,'es',NULL,'2026-09-12T00:45:20+00:00','2026-09-16T19:40:45+00:00',151,28.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(152,'tech','https://news.google.com/rss/articles/CBMivAFBVV95cUxOLWFWTEN1Z2VyUWtCTHNrOUg1RzNta3dJaVFPc3lNc2Y0SmVFRi1Rd25xWXlQUFBRdGYxS213RzJjcEY5QmVKcENRUHZlY1B5UEpvbGwtc0FkU1A0MjdIOWJZeGhQcVNmQWtmQjRWN1JLYUYtXzg5ZWJqalpwNkdVbUlnTGtNWFJJYUNfakppSFVsZFZ0ZWRkM2MwRWZhOVdXTWgzcGJ5RjZEdmtsY3p3QzRnY2F6d3VJWmJtRg?oc=5','6618216ef37a36f3cdf39592d26565001f9070bb','Dos expertos de DeepMind renunciaron y alertaron sobre los riesgos de la inteligencia artificial','Dos expertos de DeepMind renunciaron y alertaron sobre los riesgos de la inteligencia artificial  Canal 12 Web',NULL,'Google News/Canal 12 Web',0.7,'es',NULL,'2026-09-16T13:10:58+00:00','2026-09-16T19:40:45+00:00',152,44.6,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(153,'tech','https://news.google.com/rss/articles/CBMi0AFBVV95cUxPV3VuckRrcHo0T0tUOHNjY0E3NFh6eGJ3Z2JIVE14dmdPSFhTUk1MTDdDM0o0bmhxUTk0SEZBd3ctNnd5ZWljbTJZLS1Vd2Fwd3JhQmljeTRzeGY2Q2xmSWZrUkpHdExNVEZMVWNRYVZmUjN4dkpJOTY3WHc5VXVRbUU5NUVuNUdSeVBBSDFIc005Wmo3MC1YbXdhTUtBRXBrMVQybUlhTnZhN3h3REpmelVwRjVuYUZFOEFfMnJJSWtGU1dXTFY4YTA5S3JOZnhB?oc=5','ec4c781d7ee9fa79e91a7a23b809795e75f1fff0','La impactante tapa de la revista Time sobre los avances de la inteligencia artificial','La impactante tapa de la revista Time sobre los avances de la inteligencia artificial  lanacion.com.ar',NULL,'Google News/lanacion.com.ar',0.7,'es',NULL,'2026-09-16T15:12:00+00:00','2026-09-16T19:40:45+00:00',153,45.6,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(154,'tech','https://news.google.com/rss/articles/CBMi2wFBVV95cUxOU3htWEZGVnozWHRhdkI0MTRSeXZSSlNTd21tXzF4ZG1idC01VU40SWhBQVBZTkFuQU8xUFVwUWJFMVdsUkpfSHpUT0xJVFRCc1FhSjBjNTgzYmJpcTQ1TndPZUdPb1ZmR1Q1SWktYTVQSDFacTdSdmJWbjNNdDZBWWVUeFRYM2dReXJiYktWaXhaYW1iVnFORmI2bHc4bkRKenBWNzcxRE1SdlJLaGl4ODhTaVZ6ZHpUdVZBdDZiSmlpR25jYXVoa0V0UXF2OE0tcE5FTmFBYk9TQkk?oc=5','b8e7d04a9ed861a67c520ec7e9bfcb6e21696fbd','El INASE avanza en la incorporación de inteligencia artificial para la verificación del arroz','El INASE avanza en la incorporación de inteligencia artificial para la verificación del arroz  Noticias AgroPecuarias',NULL,'Google News/Noticias AgroPecuarias',0.7,'es',NULL,'2026-09-16T13:06:21+00:00','2026-09-16T19:40:45+00:00',154,44.6,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(155,'tech','https://news.google.com/rss/articles/CBMi6wFBVV95cUxNdmpYQjlCZ3hYQURrcjdnXy1RbnJVM1EwbEtvdXA1TS1nTFVHRnJfNXROVUZkbDFDT2pEX3dKQjk4XzVobXZCMC1vd2pCNHJlcVBQLUNqbzJEN0tESGtTaDFhQTN5bGtPbllTQUF3c1pmLXp3Nmw4eTNRcTVtajdhVlZxZENIVGRYNVdXb3J3WWFYMWdFN05mZElOZm9UTEFyaHlPTFRfRlhiakZqdHM4cE5UMEUwVURkMW5EM1hTWGtScmVaMHo4MGRPdXFTRlMyRVZ6MFdfUEtIODVtQWpUM1hMSXZiN3dvc1pV0gHwAUFVX3lxTE5jTm11WWs0ZWdXald2ZlNnWEJFOEZGZEh2LUppVjdxNWhMZ1dNeVBtdXZnT1lGUkg4Y2hPRXVMekNHbmF1RWJJVjhzd3hfRjlWcE51VVEtajdyWFlrQnFra0tXQ0VmOXZGRzd3b1Z5YXBJR0RhTmZEdWprUXA1T1hJWjM0TGVCa2NpVWJiMHV5Nk03bl9LYlI2ZVJhMGd3VHFaNlNBYUlHTTJMSUZmOE5FWk5hMUk5LXhuV0tSNDBWUi1BR3RoalJCNDgxYU9GZ1BxaGJqNGh1WkVRanZOeEVPUGZiS1oxZDBZNkIwYUN2eg?oc=5','dccc0aae32bf70c6b04fbb69e624c1b1cbb7a3e3','Santiago Bilinkis, experto en tecnología, advirtió cuáles son los verdaderos peligros de la inteligencia artificial','Santiago Bilinkis, experto en tecnología, advirtió cuáles son los verdaderos peligros de la inteligencia artificial  La Gaceta',NULL,'Google News/La Gaceta',0.7,'es',NULL,'2026-09-16T14:58:19+00:00','2026-09-16T19:40:45+00:00',155,45.5,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(156,'tech','https://news.google.com/rss/articles/CBMirwFBVV95cUxPRG05am9UU2JES0kzaE1wRjBGY1hCM3JXa1AtSWo4ZC1xSHg1UmZ2bkx6RGlic2dBMzU2NzFLWThHNGd0ZHNmRXgwWEppeHN5SDJMTjhUZjNYU1lwOU5Mdy1CUHlMR2Q2QjJnWWU0T3F2OFFEWEdMSk1TTWhXTENGcHZJWlRoUzN4a0NBTTVXbkJkQTY5ckZMaktDY2Rjalhkd0hZaXNjQlYtUXZnZG80?oc=5','4e6523ef4549e227b32eb5185238bd6a8b796142','La UNLP lanzó una plataforma gratuita de empleo con inteligencia artificial para conectar candidatos y empresas','La UNLP lanzó una plataforma gratuita de empleo con inteligencia artificial para conectar candidatos y empresas  InfoPlatense',NULL,'Google News/InfoPlatense',0.7,'es',NULL,'2026-09-16T16:43:44+00:00','2026-09-16T19:40:45+00:00',156,46.4,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(157,'tech','https://news.google.com/rss/articles/CBMitwFBVV95cUxOOGJkbjA2YjlJOExNblM5ZFhnV3RsNWVSQmI2SlRmZXM3MjhoS2lXUnU0X0wtSFV4eGgxNnFoTHhpTGN0eE9fajY4ZTJaZlJtcmRncl9xQ2hmTS10Z25jdjF2RHVadlFmMTBqYUNoZ1RCdldoZkxIc0RFNkJjaUduNl85Q3RUVldldU9ZRm5iSWlpQk9ZbHJiQThVTU9VRi1IUlhXamNqZUNQQ3FUSzRqc0VJYk9Lczg?oc=5','e3b302c873f60d53f0b1be013e7e2be7b546ab77','Infancias e inteligencia artificial: qué se debatirá en una jornada de capacitación en Necochea','Infancias e inteligencia artificial: qué se debatirá en una jornada de capacitación en Necochea  Ecos Diarios Necochea',NULL,'Google News/Ecos Diarios Necochea',0.7,'es',NULL,'2026-09-16T18:53:14+00:00','2026-09-16T19:40:45+00:00',157,47.5,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(158,'tech','https://news.google.com/rss/articles/CBMihAFBVV95cUxQYUJlVVlZSGlaTkJGeW1seTdVV1Y0T3BTUTh3UzVBOTJkWmYweHRMSUEtVE5VcEIyV0Z6ZkdhUG9hRE5ubTFSY2NOa2ZqVmR2U24xbFZxVEpkTTZvd2NBMjVxXzhlaXM3eEI4bllCenV2anhTVWx4Tzd2bFNoR2hmWHhHcUs?oc=5','c03a3aaff161813ec65ac3ba0ed88733ff7faa3a','El papa León XIV alerta sobre el peligro de la inteligencia artificial','El papa León XIV alerta sobre el peligro de la inteligencia artificial  CNN en Español',NULL,'Google News/CNN en Español',0.7,'es',NULL,'2026-09-16T14:43:30+00:00','2026-09-16T19:40:45+00:00',158,45.4,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(159,'tech','https://news.google.com/rss/articles/CBMitgFBVV95cUxPdDRoV0oxekJwbTRBNlBtelA0TGZBSWhWYnNuMi1OQklPNFJubjBNRXJGQm1kM2FMV1RkNnp3d1ZHUC1CbHd0WjFsMktjTUEzREhkSWZnOXdKZGV0V1BpMVFRRVBtU3B2dW5CaVlCYUhaSE5iQXhkQnVJMWhacWFFQ2lFUkVMSXFHb3RNV1NpQTdrVEgzMXBzYkpkOWdzNnhmc0dqMjZlYkVEWXRnNlZDWkVDYUtmZw?oc=5','2e243a1b9d51d7ae0b355a8801974fc500109c43','Inteligencia Artificial: organizan un encuentro para empresas en Avellaneda','Inteligencia Artificial: organizan un encuentro para empresas en Avellaneda  diariolaciudadavellaneda.com.ar',NULL,'Google News/diariolaciudadavellaneda.com.ar',0.7,'es',NULL,'2026-09-16T16:56:56+00:00','2026-09-16T19:40:45+00:00',159,46.5,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(160,'tech','https://news.google.com/rss/articles/CBMi7AFBVV95cUxOYTlscjBGSU1SS2MtMDlGcGNWdzUyYjAzQTdPNE1Fb0pPeW83OEFINXZ6RE5JWmVkMjJHakU2TXNxWFFpUFdZbkVFSC1PeTdDNUtBcmJCcUNGeHc4NWtRczFPd2d0LWJ1OWE2Q2pJVVRFZk5wV1ZXMDZIWWhFNDNXVmg3VGxDZGdEQk01VGtVdC1KWS1GSEY0bGZ5eTFJY2VEY1RqSWk3dXBCM3ZlcWdMbWFlZ0p1TkdXdTJ3MkJSeFFMcm1faWZ4UXZ5ZmhCalFmc2tEdmRxenpLcWpZQTJUMFJzcHc5RGMwR3NkUtIB-wFBVV95cUxNLW9CemwyNzdRMGFXNGFkOUw0M1lQbXVlVFlTTm5HanRCRzUyQ2NtNnFZeVJob3phSmNuaE9aSmNMQ0dEVy1KOVZ0SnlqTXQwcnVheFU5OW81YTZfbG51R0luRFZvRDlGaWt1eG04bU5EemgyTTFPd3hYaDNTWjZ2alRubHBkamNzSnQ1TDRZVHpDVUhSb1hqd0FyM0pDX0x6TTNYOTZOMTQ1U0d2d3lKc29tR05qX2lUTVd3UHVrZ2RHckFvYU1NcFdaVGFIcWIwckt6RC1pRk9EbmJrbzlWTTdQdjQxVkR4dGRhY2o4Qjc2NTFJclYtMkhlRQ?oc=5','ca3e56067b4bfdce14d72b2800a757c5d8064426','Mark Zuckerberg, en contra de poner un freno a la inteligencia artificial: qué dijo','Mark Zuckerberg, en contra de poner un freno a la inteligencia artificial: qué dijo  Agencia Noticias Argentinas',NULL,'Google News/Agencia Noticias Argentinas',0.7,'es',NULL,'2026-09-16T11:55:12+00:00','2026-09-16T19:40:45+00:00',160,44.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(161,'tech','https://news.google.com/rss/articles/CBMi9wFBVV95cUxONGRZWWg1UDRNOXhqYzdRUUNuUTdLSW10bGFKeVNFQjN2em05V2hHb1o2UldBaDBDYTZGWDFudTdpV2RKX1ozMzhNaHdUM1d0dmctQV95Q2owR24wazBRcmF2TVlDbTZRbXM0V2tpWWFBcjZvZHNjcDJQdUkyMzI0VkJBWjY5WFJrUGFDenkxbUs0RUlIWGVIQ1k5SDcybW9BYnhleWdiYjNFOHFqckFpS0lUNlB6d181bGFnT2RVUk9ZbkVfZmFzemtjX1g0UlBGSnV2bW42UEdhOU1sbi1VYnkxRS1WVnV6STZ6YU4xNTB6X3R4NjBR0gH_AUFVX3lxTE5vdVhWNHE5VlZKUU4tR1pWbS1hQkk4M21jQ1NGdDIyX0NCTl8wbUJlLVhha0hjVk80RDFfU2dHeHZsVDZ1cm9aN0lkZUQxS1hyeEFHZERORVZwMFUySExOOWhRTFlNaXFyUzNWdlNZV1B4UTJMeUtheDFBeG5pQkFHSWg2U193ckh2cVVXN1ZwaTdVS3JuRkFibXltZ1gwVnRXdXJVaDdlSHNVeDBTZkxVNnV2NUVOak1ISFl3ZUtDb1BPNzJTaUl0UjlJZzgyWkdGRUdPVXJEUWRzVHRfbGFkVk1JMmV0SjBBYkRHQlNkcjE0NnNoZ0s2ejJoWmxCbw?oc=5','5980d894ed20929b90b6d44faa03c8ce9c6cbd39','Choque en Silicon Valley: los líderes de Anthropic y Nvidia se cruzaron por los riesgos de la Inteligencia Artificial','Choque en Silicon Valley: los líderes de Anthropic y Nvidia se cruzaron por los riesgos de la Inteligencia Artificial  Diario Río Negro',NULL,'Google News/Diario Río Negro',0.7,'es',NULL,'2026-09-16T15:02:18+00:00','2026-09-16T19:40:45+00:00',161,45.5,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(162,'tech','https://news.google.com/rss/articles/CBMi1AFBVV95cUxNanhBcmdXR3BQeWVXRkNiVElpZUNadWM3ZXhpVG5xQnhFYnhSbkZudzVYVk1EWEZSZWNsb3pBSTl3M1hjSl9YcUFMckJ4ZGJMS2trMUhBVnJ4VlBsUDdXWjgxTGt6NXdJcTJCRW93ek1adHNyRV9oc29IWUFJbUN6UmVuZXItVUlOWkxnNTRIVjgwQXhsZnBaUlFEU25fSGhnZVhwdDcwUXNZeTcyODQtc2ZQXzhWYkprQ1Z4VnlJcFZ2aExyQTBWcWhFbXpWb0s3TE40Ng?oc=5','9909f13abf6ac01009cce2150215afedf43e642b','EN GENERAL VILLEGAS, UNA PLANTA OPERADA CON INTELIGENCIA ARTIFICIAL PROVEE 25% DEL CONSUMO ELÉCTRICO DEL PARTIDO','EN GENERAL VILLEGAS, UNA PLANTA OPERADA CON INTELIGENCIA ARTIFICIAL PROVEE 25% DEL CONSUMO ELÉCTRICO DEL PARTIDO  DataTrenque',NULL,'Google News/DataTrenque',0.7,'es',NULL,'2026-09-16T17:54:47+00:00','2026-09-16T19:40:45+00:00',162,47.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(163,'tech','https://news.google.com/rss/articles/CBMiqwFBVV95cUxQeVM5d0EzSVNkQjU3M1NSd0ZiVjZGNzVRMDZybkloWWpXdjRDX2pIR2JYbGVSbF9GNER1SzE1bkVVQWVjTG9NeHE0OFJ6S3hQMm1QbTZGR2xzVjRYcmo1VUYyUWg0UVdLcDFzVG8yNlhzd1NiejR0R1VNVC1OMG50OFYwWlBqdG1oc2REZ0FTQl82UDQtd0x0UDVDUXRMMEMwVGNUaEQ5THktOGvSAbABQVVfeXFMT3lzc0dWc3RrSUZHNEE3blQybTdWTUdXaV90X2VfTFBCN05MVkk3NWNFbFYzeHFId1JkMzcxd0tYNDF3dWItUGlYYVFVM2o0SklVZVJVeWRGaE9GY0J6WkV3dy1TVzlIQmw2LXh0ckEzVUd2N0VWLUMxeFo4YVRsLW1PLURIODk2SzdSNS1BM2M1bTNxLWtwaFNPMmI3b1BoVkhUWDRxVWotWmF6N1BCTDQ?oc=5','171a843f3bf774c3d29f330814cc52def4c4c9ea','Mark Zuckerberg y su apuesta para lograr una inteligencia artificial "segura"','Mark Zuckerberg y su apuesta para lograr una inteligencia artificial "segura"  MDZ Online',NULL,'Google News/MDZ Online',0.7,'es',NULL,'2026-09-16T14:33:00+00:00','2026-09-16T19:40:45+00:00',163,45.3,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(164,'tech','https://news.google.com/rss/articles/CBMitgFBVV95cUxQS0Q4N2Jzc2R6MXJ0YTJpUW9HR3pUallwTXl3MEF5WWl5UC1ZTGNJbVhkaGhxRG1idE1vRXd2emItdkJJeXZLRU96YWZoeG9HTmdvQmx6Xy15cG5VOU9iakczbFRhZENOSFRHSmtIZU5reDdMVU1wX1E1b3laWTc4dFBTcXFpcUQ2cEdNazJENlpXUEZlRTBjREdSbmFnRWF2eERyVjlCMEwwLWFEdXQwNlExQm1xZ9IBuwFBVV95cUxNd3VQTmQzTkdZMWtnZDdQSTJ3UU5sZGkxWjNEcVFBdHpCQnJhZld6RjZZdFJCZWdiTFRiczZfTVFYRl9MLW1manRCSl9RaTJTM1o5VGRiSnVLR2pRbVNpeXZ3Njg3ZVJBRGliSVZsanFDSG85RkVTUXg4ZEF3aWI4LVFxaGRTNDRKczdSZmU5Um1ZVUFaX2t5eURlT210MVVMQ3JOOGlKUGVHSTNPX0tPMmJvakxFX3lRbTQ4?oc=5','e0eacfa760d0a027664c57a1e366ccce146b7883','Se dispararon las acciones de ciberseguridad luego de las advertencias sobre la IA','Se dispararon las acciones de ciberseguridad luego de las advertencias sobre la IA  Diario Mendoza',NULL,'Google News/Diario Mendoza',0.7,'es',NULL,'2026-09-16T19:22:55+00:00','2026-09-16T19:40:45+00:00',164,47.7,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(165,'tech','https://news.google.com/rss/articles/CBMi4AFBVV95cUxOT3U2UlJ6Z2xOd09Qd0JfOUg3WjZkRktCNEJnNEdlMzFyWEU0bGQyc0dMSUV1M0c2LXJDNXVQZzlJdWxvV3JmZXkyc1EtemRzTDhBTHNfSGt4WE50S2NKRUtWMUFsVXhMVWtGdGdBcWxfZEFVaFpfb1FyT19KQ1N2N0w0bWlWX2RlMzBRZC1Cb0h5SDBaSU8wLXloNkFUbG5uVFBQTVkxOWJVcjJSODFXNlJBSWJGUlkzNXFyM2VhNlVNaWFQdUozVk9Ic2lCTDFuTXBqZkxfeEp3OXdlcU10NA?oc=5','c9d33d312e2a660d2c7c6d88712a8d9a8518fea6','Caen las acciones de empresas de inteligencia artificial tras el llamado de sus líderes a frenar el desarrollo','Caen las acciones de empresas de inteligencia artificial tras el llamado de sus líderes a frenar el desarrollo  lanacion.com.ar',NULL,'Google News/lanacion.com.ar',0.7,'es',NULL,'2026-09-14T12:52:00+00:00','2026-09-16T19:40:45+00:00',165,28.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(166,'tech','https://news.google.com/rss/articles/CBMi4gFBVV95cUxNSFBvZURKVHRYZDRLMjFYTDl4UFpuRC0wcUpZaGhHRHMxZk8zSHR4V2JRRDlDUkwyZ0ZjUjJOWG9EbnN1S0hFZXdMR3puVGV2WFpBN2piMkhOY3Rsd0dxREtfdEpXTVpaMHNBTkxGZi1PRk5NVnBXMERjQi1pc0F1QjZvWklYUElNeDhNdFBWUm1EN0ZUQU5PRk1CNzFrVUZyRy1neWN2V2sxcERVQjBoM1hIajdiUVlrdGlLMGlNX1otZm9yRnQxNDFFWUdxRG1ybkhHTWpZRWFjNU50Wnk5Ujln?oc=5','8ace8b741ba7e2edf8e0812efe4dc8e37a620836','Cartas de lectores: Argentina improvisada, respeto al Himno, Inteligencia Artificial','Cartas de lectores: Argentina improvisada, respeto al Himno, Inteligencia Artificial  lanacion.com.ar',NULL,'Google News/lanacion.com.ar',0.7,'es',NULL,'2026-09-16T03:05:00+00:00','2026-09-16T19:40:45+00:00',166,39.6,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(167,'tech','https://news.google.com/rss/articles/CBMipwFBVV95cUxQWDdxTVBwQkdwT0VKY2M3YkM5OTZEYmZQb0ZUaXU5cUc2QnlaWTBSNjlXMGJ4NFRzUENoZlc0anpiejc4UDNnUGlGeERKeFJITW5fY1o0bXQ2ZDlOT18ydkd5ZTlqdGdWVU9hMWk3ZXBfWFZoXzJMZ1pIdjRueVN1WTR3NHF4NmI5Y0pueDdJNFUtZzY2M2dsTGRoZHlBa2hnR1lfUzNRc9IBrAFBVV95cUxPUFFySkllVlVzY2pFWGw3V2VJai1RUVdhNGJEbmp2ZmI1T2dKa1Q0T2drUHhhbW43ZjUyUDNaSXdsQ1ZfTXVNNDhJOVdrSmpubkdnR19UcjczcFNkT0ZjVlowQU5FRDhBODViSFlhYy1TeGtBTmMtcXQwMU95Y1ZlTGk5V2Y3OXpvWk52cEpTcWx5SnBuVGVWR0JtM21IdnVLTDFiU09vazdCUXVv?oc=5','41f258f3b42d4b192b38fac4d72634b6fb022783','Zuckerberg rechaza frenar el avance de la inteligencia artificial','Zuckerberg rechaza frenar el avance de la inteligencia artificial  Crónica',NULL,'Google News/Crónica',0.7,'es',NULL,'2026-09-16T16:02:50+00:00','2026-09-16T19:40:45+00:00',167,46.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(168,'tech','https://news.google.com/rss/articles/CBMiugFBVV95cUxNblFVR0xfSkwwUTh4d290bkZVZ3ZBaERYZ2dTVG1JLU5NS2Q0S1R0MU12Q0k1d0R6QlpGaU4zZmFKdWNvYkh6OHZBWFhwNmVuMUlYakZRNngwRnBTM09nVHpmTjk4SFNZaG9GZThsRHBsS0x3S1FWM1BYNnU2YkxYdHhBUDY2SnBkc05uYVhmQmV0YVZlVm9nWURxa3FJeXFWejNsaVJJRWVKVmZ5TWNpUFdUamZhZkM4N2c?oc=5','c786778a2777dccf00de8dab4f6768a888c01e8b','Parolin: Es urgente gobernar la IA, preocupa que algunos países actúen por su cuenta','Parolin: Es urgente gobernar la IA, preocupa que algunos países actúen por su cuenta  vaticannews.va',NULL,'Google News/vaticannews.va',0.7,'es',NULL,'2026-09-16T17:35:17+00:00','2026-09-16T19:40:45+00:00',168,46.8,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(169,'tech','https://news.google.com/rss/articles/CBMiowFBVV95cUxPM2owajhZc0ZHb2JUTzMzMDJXWnhfUkZqZ0ZjWG5fUVlldEpNVEcxZExXcXRLU1VlWTZCa091bE11OEhabURxVTdRdEN3R05VZ19Gbkx2VExieXpPa0dtUUlOa0dKZGVDU1NpQ1Zsb2JFWGVzZ3NiY0FJa1J0bEZoUlJpTzZ5VW9XNHhpVWFPR1JVTnl4ZGhPWkRwaVdvYzBGS09j?oc=5','4ff66f861127d7d2eb257af27b326466cef48cf7','Volvemos otra vez sobre la inteligencia artificial','Volvemos otra vez sobre la inteligencia artificial  GN Noticias',NULL,'Google News/GN Noticias',0.7,'es',NULL,'2026-09-16T15:03:00+00:00','2026-09-16T19:40:45+00:00',169,45.5,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(170,'tech','https://news.google.com/rss/articles/CBMi8AFBVV95cUxQMktGTnFEb1dBVEhOaG9FWS1hN1FMSTZ3Z0RlNzNxY2MyX003QWxJaFhHSVphV3dwVThNbC1JZ0ZqOUR6WWpVanNTT3d1Rlo1TDkzdmQxZXRFMzNPOWFwRzFKdEVjQUlPNHh2aWlxYzNHQmZxY0h0Q2ZBS2dtRHRFeVlLbmVHeThxODBadm9GTjRpcHNLVGZNOHdDQmtWUTM5by1ra1k0a2dNY1didEVCS1h4cjR6UldQYVAxOTJjeVdGaEIzenotTUU5RjZNdXZZLUxXVlBFaFdCSWh3WVlQV0dOT0JrMU1nUURKRVotd2o?oc=5','6264b6dda528213abde7732499007069c86ffbe2','Inteligencia artificial para controlar el arroz: el INASE incorpora tecnología para verificar variedades y pureza','Inteligencia artificial para controlar el arroz: el INASE incorpora tecnología para verificar variedades y pureza  Agroempresario',NULL,'Google News/Agroempresario',0.7,'es',NULL,'2026-09-16T11:20:30+00:00','2026-09-16T19:40:45+00:00',170,43.7,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(171,'tech','https://news.google.com/rss/articles/CBMi5gFBVV95cUxPekR5TDluX0ZISzEza05WaWN0MzgzQUFLNVlRUHBFTGEwR3F2V2pQR0tLdVlpT3otLWdQdW5RRVVvRTFublNGTGl2N1pIVVZ2QlhRMF9Fblg5ckI4UVBlZkxzUFA2ZG5HX0NPRW83MTZWZ3AtZDlFVjR4Rlh0MGd3V1lTQ2Rvdm56RGZtVGdMajNnTWlVTWpMdW5FWnljWlMwbXVBa0VTbnZQcENfWTFMM2dkLXpyN3htVnY3QUlXeUtqdkVlM3BiMVFFQnBqODJuV0pRdkgyNzZfM25JLWl2MVhrVzQxd9IB-gFBVV95cUxNNTJISEZMQXBfVUxJU1k2Tmd2Zk1wNGtxLXRkcFZJUGhwUkttZUZwR2N3aFNWNElxblVCV0JXYkNpdWRSeXRac0FhRGVBckQwOUt0LURMSmJEVjhjaDI3amk0TjEzMDVERDhUOHBTR2trXzhDUnlYNFZVMjN6SERIaEF6S2xLTm5mNXlkUEkwT04xQUJtY0N5bVBFdm1JWUFFakVtZElYWG96dDRUZ3JzT2ktX1QxaHA0aTkxUENuZ0w2RWpjRklSd1VfaUdxZl9xX1hTbzdmbVBucFdRS2RidWpsRUdrLXNGNkJWNDZKbVV3eHNrRDBubWlB?oc=5','0e9b092b14c304a6ce68dfa5d71107e3975491e7','La Unión Europea busca consolidar un modelo de inteligencia artificial que priorice el factor humano','La Unión Europea busca consolidar un modelo de inteligencia artificial que priorice el factor humano  El Destape',NULL,'Google News/El Destape',0.7,'es',NULL,'2026-09-16T13:30:49+00:00','2026-09-16T19:40:45+00:00',171,44.8,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(172,'tech','https://news.google.com/rss/articles/CBMinwFBVV95cUxNVHRybXpyeXUxZFpIaE1NTHlzbU8wYzJvVHhTM250bWNOdnJnZUdMZVFNQWN3eXpxNl9jM3dPdkVGQ0RiNW90LWRrTWRNak1zclpSbWhnVGFxV2Nqa0VGTFY3LVZxOHllYXpLeEN5RWxJTi1hUVNIeElHMTRRVmEzeWpoRWRHdE03dVlpNlpPYmgtQTFLMmM0bU5zOFFtbXM?oc=5','1354e491deb0fb0b445eedb718defd06d3b91486','Seis proyectos del Papa León XIV frente a la inteligencia artificial - Diario El Norte','Seis proyectos del Papa León XIV frente a la inteligencia artificial  Diario El Norte - San Nicolás',NULL,'Google News/San Nicolás',0.7,'es',NULL,'2026-09-16T15:03:08+00:00','2026-09-16T19:40:45+00:00',172,45.5,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(173,'tech','https://news.google.com/rss/articles/CBMi2gFBVV95cUxOMW1INmlLdnFCeG9tWnRTSG5abjRwZjN3cFQ0YnhFVEV6X2draUFlNG1NVlJ1OUhabjVsSG1DY3VUV2ZyeTJkTmU0cmh4Q29VSUx0blRUaGdSU3BmdUczd2dfWnVHSWo2TnNSLUh6R2h4MDBYODduYTlFNzM1V2sxVHJMMkVSWVhUQ2VoQ0U3ZDF1Q0c0MVk5VXNpYkNDSWNQSktiTEp3MnNnVkgxMHQ5cjU4NnhwLVJKWjB2VEZQTFRnQTlaVmU3TDBpd204aU5DelJIZ1BYUjlFUQ?oc=5','33c84e7c61d464ccdf3746571f13f6d39422a86b','“El cambio ya está acá y es la nueva constante”: la advertencia de SAP sobre cómo la IA está rediseñando las empresas','“El cambio ya está acá y es la nueva constante”: la advertencia de SAP sobre cómo la IA está rediseñando las empresas  puntoapunto.com.ar',NULL,'Google News/puntoapunto.com.ar',0.7,'es',NULL,'2026-09-16T19:11:08+00:00','2026-09-16T19:40:45+00:00',173,47.6,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(174,'tech','https://news.google.com/rss/articles/CBMi1wFBVV95cUxNSW00TGo5WkdRcko1eG1SazltcWY0bWc4UExtVlp3Mi00UEIzUGl4TlhXUUkwN0lIYUdBb2RiZ2pHZDU0THVZTUh0YVJOaWN3TEp2QXhQRnhnQmFSMEc5OFVlVkZ0NC1uQW04ZmRQSlpzZEtHV3RwemtmMTEwM2t1M1l3bFJnR3FVY3lhYkJiTjhMenJjaUpPalZtQ2VzVWZrZTVqTDRwanN6LVpBbmxUb3FOblk4UHZoRjR4R3ZSMFB2b1J3U2FTRlh2WkwwUjhndnNsSXhKY9IB8gFBVV95cUxNMTkwZy1NX1pJVGV5c2VCT2hnb0pWaHVTMEJfSGZLQW9JRjNwR0VIc3RhVF9Hcy1Zc2VienVORk9IRndPTFdONEE0RG9mcGZKaVpDUERmNTh5OTdMYWR6QmUyNzZJdmNsbDc5SjZ4VzdOVDBBVkVwTU5aZ09LTDhFQWN3b2V1VGszUktuNEJxZlNETHVvM09MTk9WOFZBUUcwN09OamhYNG5iQzZzcjZxUDU2OFdqTU02MW9mLTJPaVo5T0VHRHlwS05fd0RwUUQ0QTlITjA2dUlsNVFmekNPTklUak5XSzEtWVNLRV82dU1TZw?oc=5','f00c10cf7bb55491e593c9fcba3679f177e87e61','¿Qué tan popular es la IA entre los votantes? No mucho, según una nueva encuesta','¿Qué tan popular es la IA entre los votantes? No mucho, según una nueva encuesta  Infobae',NULL,'Google News/Infobae',0.7,'es',NULL,'2026-09-16T13:53:00+00:00','2026-09-16T19:40:45+00:00',174,45.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(175,'tech','https://news.google.com/rss/articles/CBMi3gFBVV95cUxNeVVaU3dNUlNva21KdkJEYVU2eDRaYVB5eWpvTGRTcHl2eFBObkZhR2tDTTVycTd3V0pGdDI3M3JQVXBqV0Y1Z1pRUUdTVWhQU0RpTEtLajVfdzdYazdsWFcyYVh3aTVVa3drOXlOVms4b2owX0JfY2NzSDZ1Qlp6LWh0ZHh0ZUFkTGJRZDBLc2w4Y1ZxUFl1MDh3V2hUV01IN3RUYW1SNEZ4Q2E5WThlSW85NEpuRUVSSlNkRmljNjdNU1FGaUMwSTdaSGRKMENQbmtnVFVYZU9vdlJpMlE?oc=5','e71b09d7527fa58b0d0dbb3a1baa63c8ee32142e','La seguridad de los medicamentos que tomamos: cómo la inteligencia artificial mejoró el rastreo de riesgos','La seguridad de los medicamentos que tomamos: cómo la inteligencia artificial mejoró el rastreo de riesgos  Los Andes',NULL,'Google News/Los Andes',0.7,'es',NULL,'2026-09-16T10:00:00+00:00','2026-09-16T19:40:45+00:00',175,43.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(176,'tech','https://news.google.com/rss/articles/CBMi0wFBVV95cUxNeVpGQ0JMSk5NMDQ3UjRndzJDTl9PbmVqVF9jckhZaGRWTEhGSDdsSENvM3RnZEhHNDROaGdCNUR0ckdCWWFPX3h0ek9FUjVFNFR6OGtJNXJmRXdNWkxWNC1CNzFhZlhIZUtkM2I1SE1zU3lZMmJGRG1NY0hUV1p2QnBrSmlOREFEak5VeE01b0xzektFZTRIZklRZmhoZkZhRHVLNUpOYlZqV08tMjNTenk0R0U3UXBaRnhrZWxXbi1lYl9MZGd4NGpIcUxYZXNydWE4?oc=5','a0376b05da5cb1ea61658ecdc189b74b2a63e722','Cuáles son los seis proyectos que apoyó el papa León XIV para enfrentar a la inteligencia artificial','Cuáles son los seis proyectos que apoyó el papa León XIV para enfrentar a la inteligencia artificial  El Comercial',NULL,'Google News/El Comercial',0.7,'es',NULL,'2026-09-16T16:17:51+00:00','2026-09-16T19:40:45+00:00',142,NULL,NULL);
INSERT INTO "stories" VALUES(177,'tech','https://news.google.com/rss/articles/CBMirAFBVV95cUxOTnVyV0k1OWF3al9DX1MwM1R1S0VPQ2hHQlU5b08yQ0dDZG5kQ1BWdThvREJVSldWMUxaS1BGS1J1cVdCRk9BUWZFNm1VVlJxNXZkUTB0U0IyS3dNNHAxam1tbVk3eEdRTW44UlZTaE96cURWaEdUdmpSU3FsUllIZTY2QUx4R1BmdmtzNm1SMFRfcVV2c09DalRSLWU3SndFeld4M05DRTVsNFpr0gGyAUFVX3lxTE5MVDV6M25TMFJWTjZieHY4TXBBQlJlZFY3ZlpvZnczR0pTS3V5eUpicllYeE42VllsY3ZyYnJOYURFUkEzaF9VWi00Z1JqeDVoTUpDOFN3U0RrOTVxam44MmVXb2tVV3R0UXZHUjRxcHoxSlIxa3ptRTI4R2JvRU1BX081QW9SeF9iQWpKTG5Qd015cks1aUdHU2U2WDJETnp5RENRWWJ6LWtfSWpGOHItYUE?oc=5','3ec3b76864c8d0197a7977be1327ad9c805e583a','Nubia NaviX Ultra: lanzan el celular con agente de inteligencia artificial','Nubia NaviX Ultra: lanzan el celular con agente de inteligencia artificial  MDZ Online',NULL,'Google News/MDZ Online',0.7,'es',NULL,'2026-09-16T17:00:00+00:00','2026-09-16T19:40:45+00:00',177,46.5,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(178,'tech','https://news.google.com/rss/articles/CBMizwFBVV95cUxONmw0My12d0xaYkhVYlNDTWNCU19xTkJoNEU4SkpPbDhGYlV0b3RTcjdKMW9iejRQSVk1QVlhVm5NY21oWmhzSzhEVDAxd1hLR3E3UFJvVi1NQnctdXhpZFcxWGJsYVlWRlFJVGdkeHE3Q3N3V01mS24tZGdRRjFaczhlckJPdndLMGh3Yk9iNnJxbGVhd0NBdGk3MVpFNHE4R0JvZXczR2tqX25XbUZWRVRmcWhUY2NMOVhERF94Zzd0T0U5cjIxZnBzT3N5dEnSAc8BQVVfeXFMTjZsNDMtdndMWmJIVWJTQ01jQlNfcU5CaDRFOEpKT2w4RmJVdG90U3I3SjFvYno0UElZNUFZYVZuTWNtaFpoc0s4RFQwMXdYS0dxN1BSb1YtTUJ3LXV4aWRXMVhibGFZVkZRSVRnZHhxN0Nzd1dNZktuLWRnUUYxWnM4ZXJCT3Z3SzBod2JPYjZycWxlYXdDQXRpNzFaRTRxOEdCb2V3M0dral9uV21GVkVUZnFoVGNjTDlYRERfeGc3dE9FOXIyMWZwc09zeXRJ?oc=5','d04d4cd16ce4d29897a441750a1043d9b5f472b9','La inteligencia artificial creó su propio idioma y dificulta la supervisión humana','La inteligencia artificial creó su propio idioma y dificulta la supervisión humana  diariopopular.com.ar',NULL,'Google News/diariopopular.com.ar',0.7,'es',NULL,'2026-09-16T18:27:00+00:00','2026-09-16T19:40:45+00:00',178,47.2,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(179,'tech','https://news.google.com/rss/articles/CBMiiAFBVV95cUxNbDFkakNaUi03b0Z2cDFNYm1uYm1rcFhadmNpaXhXQzFlRExiMGNubFhMNnRmVUFEZTBQUXFkUzJFT1FLYlNJZ3F5TzJxOHRVZU9EMTJwT2dsS3RONlZJVmozTFZSd0ZvazYtVlkxd2pORXdkSTFSZDZabVpMTUlKV3dicnF0SzQy?oc=5','c27418e34ee6ab78410a0734de46e7d7398c0efa','El boom de la inteligencia artificial elevó a un récord histórico la base para entrar al ranking de los más ricos de Estados Unidos','El boom de la inteligencia artificial elevó a un récord histórico la base para entrar al ranking de los más ricos de Estados Unidos  MisionesOnline',NULL,'Google News/MisionesOnline',0.7,'es',NULL,'2026-09-16T17:00:04+00:00','2026-09-16T19:40:45+00:00',179,46.5,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(180,'tech','https://news.google.com/rss/articles/CBMijgJBVV95cUxPemJzVHB4VHBBLXdOYk5ZbGVERzNIWjZralZveHM1cHBQVVc1YXFaeFlOOGduNU1Qa1RjTFl5TjRyZko3MDIxTU5id2lacENUUjJyOFBaQV9PVDg0ZWNObjFsRkItSnpsZUZaUDNpaDRlTDRma2pBVjJhYkt2QmZTX0dUMHpwWmwtRTh1SmI0akY0SkszTWF3dGRJcF9GM2ZiRFhDMlZnNndBcm5zMUl0VjlwXzczNjRiZ2g1bFFBY1NTYmlFd1g3Qk1iQ01NQ1g1QnZfUVBaWFFBeTNadEdwRlpWVzNQOU8yWXJjUmdEWFgzaXNodmtmeWdCLUhaQ01IVzNvM3lwWHdTNHJBNUHSAagCQVVfeXFMT1d3X0s5dlVfZWVZa2w5ZkItRDJ4OHpudnByUXNJNWdGZVQ5Wk9WUXNKNmJEX3Zic3loZEc1NzBmcXkwVl92d3Q2LWMtczVlZDZ4LWxEdTFUaXNrX21fZ0lsbzBvVVNhMExrcFFqRWE0U3BnMXNpTUZUaDBCQ3NYTnNyMTlxeC1tMlhDeHlodTlxRkFuT1F4ZnZhOW1weTdGbmRBcm5DSENlWWVnZ1RoMDQtS1MwelNmdUVlR2ZfVFpQZmFWNWhjT1FXblE3MExyX0Z2QjV5TWZ4V3UzRHM5SXhmM1FjVFlBX2NhVjdHVVlnNTd5QmlhZFEteUtmbTdRQWpKc28zN3RfYVlleUo3SVVERTdBNEVSWmtSeFNhT2p3NDBVdVVqem0?oc=5','8a8106c1b1607f87325f624109642d16a774845c','Bill Gates asegura que el mundo no está preparados para la inteligencia artificial: “ningún gobierno está abordando este tema con profundidad”','Bill Gates asegura que el mundo no está preparados para la inteligencia artificial: “ningún gobierno está abordando este tema con profundidad”  Infobae',NULL,'Google News/Infobae',0.7,'es',NULL,'2026-09-16T18:23:22+00:00','2026-09-16T19:40:45+00:00',180,47.2,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(181,'tech','https://news.google.com/rss/articles/CBMihwJBVV95cUxOLVYwVjBfR3B3M2U2d2c3cUF0a25qN29BWmh6UVI4ZkZOUUNCTXFZNDZKOW9Sb1RYcUQ4SDRDQmROb2dOZGRWczd1SUNyNUJYLTZOR29qMnAtb3pTQnl3Z19veVo1d19lR3BqR3poY0JZYVR6UFRLSG5hWmkxUkVYOWFwY3gwbUdDQTFkVFBUSUd5N1JTdWdvblQzNDd0RU90YkM4SGUxSnE3SDVjcUhUT0ZmRExpdGVXZkNSTzRiWXEtbG5ac2FwMmw3Q0pVV0R5MFBKeExGMjNKanozSG14WkdfUVpXNDlRX1EzS2tCTjdOUHRHLWZ6R1NCdGUwc3hKWU9PQnhZQdIBogJBVV95cUxNZTJ0Vm9nNS1kRmx4TXhsdmdCZUUzOEItTEZfbTc2Z3M2UlB5dlQ0enJucmNoOVpReXNEenAzQ3hZQmJqOWFUSlR1bjd2bmNQTEhzVU1jdjZyR1oxdjhSaWhZbDFjOXNfVXhVUmpxRGlWbl9PUkg1cUsxUmJ3S3lWUS1SLXdxV19VNUZNQUF4TjM4Q0piQ2NYM2ZXNmFOYlpvNGRMUWp0RTJJd2FDVmlINnhoblBuUDEzZFkxNFlMNXlCTG5udkRtcGlDel81WWdabHdVYnVDUWNSMHpudW9VZUZDbFpQR2pZUmtnaUgya0dmcWM4cnp4dndDY3NRNE1jNlFrR0FRUEt4R1pjUzhBRjFoWVhzRGNmSmxKUEVZMzlsZw?oc=5','4ec343c9d752a4bf975a51a3edca54912c8b3b3b','El Papa León XIV respaldó una agenda de seis proyectos para enfrentar la inteligencia artificial y la crisis social en las Américas','El Papa León XIV respaldó una agenda de seis proyectos para enfrentar la inteligencia artificial y la crisis social en las Américas  Infobae',NULL,'Google News/Infobae',0.7,'es',NULL,'2026-09-16T07:00:00+00:00','2026-09-16T19:40:45+00:00',181,41.5,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(182,'tech','https://news.google.com/rss/articles/CBMizwFBVV95cUxONFI4WEpuOWJjV3BENU1vR2g1YWlfUlRDNXhDWDd6Y1QyOFprNTc1Y0ZvYUJLQWlmb2hlRHlndkprRUJiMVcxMkNWekZpQ2p4MkJFTjFKUWJIZ1lGN0NGREhGSmx3OG4weTFvUWtQaENEbkI0Q0hmS1ZPMExEWDJIS2doUEx5TnZfZHAzRkhrQm5TVEgwNS1ndE5mRlBHOEJ5bG9HcUhtT3poOWNtc1pvdVVacGRVVEhaajIydVFyRE9RUktsMXU1aDF1Z2d3RUU?oc=5','ca65ef35253cbaff2562644500999cf54e873509','La inteligencia artificial y la crisis social, en el centro de una nueva iniciativa impulsada por el Papa','La inteligencia artificial y la crisis social, en el centro de una nueva iniciativa impulsada por el Papa  El Marplatense',NULL,'Google News/El Marplatense',0.7,'es',NULL,'2026-09-16T17:00:00+00:00','2026-09-16T19:40:45+00:00',182,46.5,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(183,'tech','https://news.google.com/rss/articles/CBMiyAFBVV95cUxPdkNjSU9mX2NUYnEyVjdxazNVa2Z5ZzFscHhQQm03ZWdzWm5faVU4Wlo3ZWM1dHJMcnFxRmRjdGpPbHh3cHJsQWJrYVlmLU05Tng0bjRuU25QOUlBVjVIRVVlTWYwa0lORnd3ekV3Y3VYYmVzVFQ3U2psOVRHVmJ1WGdKeWxzaF94WW5HdXhTMWFqWElUOUMwUlBmcHBSaGdFVUtKNl9neFVnYy14bWdmT000d1lNNk0tWjBmYmdxTHFMTDdGR29xNNIBzgFBVV95cUxOYXBwRFBTMEdWLS1kTkxzaFZoQkNPRjhoNEtYVFFmNHJfcU9zSXRnazVEWWFHcGtvM09RbGEyS2VWTWtvUHRlOWp6dkIybm1sU2dCQnN1YlU0X1FpYnAtd1hfU09VUnFsU0lLT1N2aXBmVzFfTXZOellhaVdIeDlNRnMxcVJmeHVlWXVjV0Q3RUZDTGxINDVOQ3BhNkthYWduaGlQWkdzVHhIY182VzZFWHlmZHFEVUl2UUpSeEhlbXJjN1JpaGN3cHdqaUEwQQ?oc=5','23bac915985c29bda13a6a94e2695119a8e47185','Inteligencia artificial y creatividad humana, un vínculo próspero en las industrias creativas','Inteligencia artificial y creatividad humana, un vínculo próspero en las industrias creativas  MDZ Online',NULL,'Google News/MDZ Online',0.7,'es',NULL,'2026-09-16T09:56:00+00:00','2026-09-16T19:40:45+00:00',183,43.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(184,'tech','https://news.google.com/rss/articles/CBMivgFBVV95cUxPOUtfb3Nodmo1MktsQXp2REpNcFBrVzF5UXl6MXhGQmFHSHR0NXR4cjJNNk5rWVdLaXotQlB4VWR4RnpaRjg2RTZPcFMyWm9zbFZwOUxERDkyOFc2SVhmRF9fbWc2THlXa3Jobk9BcXppbS1ETkNwRWlZYVVodWxzMVZXVVJsRVhSQXpMMnlTMWlPZXZmeHRKY2FZVnVfRW8wSVl0elJtdXNMUm5oYnF1bzRCbFVfbWtUWkFaVnhB?oc=5','969be3eb9946b68127daae657ae4074b75eb3b58','Argentina analiza el uso de inteligencia artificial en defensa en la quinta jornada Ctid+i','Argentina analiza el uso de inteligencia artificial en defensa en la quinta jornada Ctid+i  Infodefensa',NULL,'Google News/Infodefensa',0.7,'es',NULL,'2026-09-16T10:01:35+00:00','2026-09-16T19:40:45+00:00',184,43.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(185,'tech','https://news.google.com/rss/articles/CBMiwgFBVV95cUxPanZtNEF4TTZpSWp2LUNLNXN1QmpRVTN0S2d2Y1cxOTRHMGZ3M0FPd2owaG5tdDZyeDdrWmJraVBEMG9jNnY4S21ObHJESW1pRjdEdVU1VUMtMDdUU0pTamc5Yk1wUFJneEpublRVSHB2eWdRbWdqNTctTE9FWVNoOTJ2Nmo3SldVUEFtYUVfU0hKdVpsVHJjbzh6VjRpeTVyZ0JBQlhoeHhGNmFnekVvWVNSLWdVMlNORnZWaFl3MjNyZw?oc=5','b0d60bfe4599e8920a8816a6d4503439816d11c2','“La inteligencia artificial nunca será como la inteligencia humana”, afirmó Alejandro Urueña','“La inteligencia artificial nunca será como la inteligencia humana”, afirmó Alejandro Urueña  GN Noticias',NULL,'Google News/GN Noticias',0.7,'es',NULL,'2026-09-16T11:24:00+00:00','2026-09-16T19:40:45+00:00',185,43.7,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(186,'tech','https://news.google.com/rss/articles/CBMi5wFBVV95cUxPakI2RGdveU9ObG9VaWhBZmppRzVZV1hXWkVLUVJEY0ZoME5hTXlueC1HUDd3QlIxRTl4M2JCUEU1LU1pQjdSUUU5SzJTcDZ0ZlljS2VkU1QwM2ZwVEwzb0NSUEdNdE0tNlpRRUlfd1dsMEtTQm1CajBoSFR5UHNGWExONUhNNk44VGV2QVA5NHpTcHdNT0JuZ1N1VWFkeTNYSjd0ZjFCVWV0UUwxdlhXaWVTMUx4Uk1kRnJSbWlCaG1NcTFQcW9WOXJVMG56VnJCMDVhaE1Na0RsUXhGWlR3MmZBT29LYk3SAYICQVVfeXFMT3k4VGNmWmVJVkZsUEtXYjVGbEZFMUZXTXBmUzE1ZE5PbEUzeTFaZ2tVT1lZdG1NZVNUZVVQNkdMSzRCVEdua0JuMXUwRUkzMTRDWmluRW54bGFuNW45dllVUjYybUxGLS1kaGM1UTl2ZVlNLW5FdEZHSDZ6X0dtWFdjc2ZaNEdKeWh5R3JoVzBHX3dmbjJRYldWTDExMEJMMlk5bjZ0NXVCSTVHY3lDYUdURGRBUTVSY2ZuVm9kN3JPSDByYzdJNXdWSVBUbjVrMWh4Ry1nUktzOVBwSUxTUTVRYU10bElLYUxPdVNTRjJrc3RSUlMzYWdkdUtwWm5wQk5n?oc=5','6146b52599385cfe1ebbce865c9a3155720627f8','Los ejecutivos ya ven el daño de la IA en sus equipos: nueve de cada diez empresas no tienen plan para frenarlo','Los ejecutivos ya ven el daño de la IA en sus equipos: nueve de cada diez empresas no tienen plan para frenarlo  Infobae',NULL,'Google News/Infobae',0.7,'es',NULL,'2026-09-07T07:00:00+00:00','2026-09-16T19:40:45+00:00',186,28.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(187,'tech','https://news.google.com/rss/articles/CBMimwFBVV95cUxPaExfVE1HU1Ywem0tdEN4a29YdFY3NkxzV3FqNXBSU3pRdEZtbE9Obl91eDgyYVhIQ1F0dURnMzFfMFZ6VmF4R1M1VEdoVUUwTHBBZDd6Yjl4OGljeWJDUTVvTjJIRVY1M3RmM2FkRThTLUFTcFNJNDRqWFZIUTZ2NW9zZFV5eXM3c1pRMWJxU3NXVjNSX3owQmJQRQ?oc=5','27a3e34e42370fc2e85c5e392737ff0b552823ad','Zuckerberg rechaza frenar el avance de la inteligencia artificial - Diario El Norte','Zuckerberg rechaza frenar el avance de la inteligencia artificial  Diario El Norte - San Nicolás',NULL,'Google News/San Nicolás',0.7,'es',NULL,'2026-09-16T12:09:27+00:00','2026-09-16T19:40:45+00:00',167,NULL,NULL);
INSERT INTO "stories" VALUES(188,'tech','https://news.google.com/rss/articles/CBMiwgFBVV95cUxQLUNnYmtpLVAyVVF6bGxmeFBDeXFnX28wNGFGak0xclZHaEZydmlBRzdTUHA4Q1pvb0dTTmpka0hYV3laY0JjQ1N4SFE1QU1UNjEyWGVDN2F0QjR2WGlCTWpNTVl2V0Rfc2YySXdOQ3k0Y2c0NE92dHhESVhTWlpuMFdudTJqWkRUemtGNWtRUlVoRnVnYUd4VDZod19BMWlELUlfbVNUQ1dEeWF0Ym90amtmMGZ1OWJZMTF0djZGTEJkQQ?oc=5','dbe588c37f8e48125410ec8a4b0f302cde34e39c','IA y el futuro de la seguridad en medicamentos en Argentina','IA y el futuro de la seguridad en medicamentos en Argentina  lu17.com',NULL,'Google News/lu17.com',0.7,'es',NULL,'2026-09-16T13:03:00+00:00','2026-09-16T19:40:45+00:00',188,44.5,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(189,'tech','https://news.google.com/rss/articles/CBMiywFBVV95cUxQR05aTHAwUG9BWF9Ga0FUOUt6bjQ5OUlSSVF4UVRmSDdlbUJfNnFwb1hXYmRyNURvUFZrNmJnSnJ3SGFweDJVTmFPSkpoVDFVYkpPS1ppVkZFMEJXTVZURmFKa2xveHB2YVVQT2lnX3ZUZVZWMXlaZTRaNEFEeDZrR19SLUJtOWx3MUtRVVBXajlMMFg4SDNGU3dBSkxGYXhxdjRaclBobWFHY3NtRlI3X0pkZDRzeE1GUjdWQjVfTGxONFpDQmVKX19maw?oc=5','a4025bdef249bb46bb78bd28f7004e5b0a904ef3','Zuckerberg rechaza frenar la IA y apunta a Anthropic en pleno debate sobre los riesgos de la tecnología','Zuckerberg rechaza frenar la IA y apunta a Anthropic en pleno debate sobre los riesgos de la tecnología  La Voz del Interior',NULL,'Google News/La Voz del Interior',0.7,'es',NULL,'2026-09-16T18:58:25+00:00','2026-09-16T19:40:45+00:00',189,47.5,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(190,'tech','https://news.google.com/rss/articles/CBMivgFBVV95cUxQWDFXT011V3pLS2czdDU5WFk2Zk1SRTgyVUFSQjNwQ09LbVdLamlsT0l6aWVFeFdmdi1uYWhTcTJ6S2VERU55RWtJc1JxN1dYYjMzZUwyRW5aTklWOUVHNkwwOFZESllTejFIeTZHVHJmcW1RMXIzbTlYYzdMdmt0TktSY2F2djhBUmhFaktpRXUyNG9YLV83SGZ3UzNhM0lwT0RYNGlfTUxTZl85MFo3TVlhRklYNTV0MkV5Rml30gHDAUFVX3lxTE00ejVqWUZHR2MwT2cyalRRQUhlUVpWVnJ1Mk11a3NjSGN0dWtOWWZ0dnJwdkJHU2dlaGRHYS01RXZsV053TndFUVJLb0Y3am04Z3RZQW5SRWRRcjNBNE9qelNYYVJvYzhWeGEyMFZqeHQ0ZGs3UjRxTFhQVjVtUFdRSHRnSHVMMXBqamJTU0toZlNkTzdId05TY3hyQjk5MUNVQ3Q4QTAtaHpDRFNmYlJuY3FmT1dhckgxSVMxMzc4ZFJHWQ?oc=5','23976d562b3e70f33e29cbba1196ff82f7408a44','El papa León XIV pidió no delegar decisiones humanas a la Inteligencia Artificial','El papa León XIV pidió no delegar decisiones humanas a la Inteligencia Artificial  tiempoar.com.ar',NULL,'Google News/tiempoar.com.ar',0.7,'es',NULL,'2026-09-16T17:26:13+00:00','2026-09-16T19:40:45+00:00',190,46.7,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(191,'tech','https://news.google.com/rss/articles/CBMiXkFVX3lxTFBFUEJMdjRIX0ctWUtfSzVubjVPRWlVM0tLcHZndDVqVkhpY2xoN0Y5Q1lTbHJqLXpyakJlUy1sTjd2cXBUbzZ2akZ5SXNGMUlVeVpKa0FnWU5kNHNfWHc?oc=5','166fd4134fddfb1b4ebc0b257a15462176cd51f9','Estados Unidos y China disputan el liderazgo de la inteligencia artificial en medio del debate por su regulación','Estados Unidos y China disputan el liderazgo de la inteligencia artificial en medio del debate por su regulación  Fenix951',NULL,'Google News/Fenix951',0.7,'es',NULL,'2026-09-16T13:39:47+00:00','2026-09-16T19:40:45+00:00',191,44.8,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(192,'tech','https://news.google.com/rss/articles/CBMi1gFBVV95cUxOME1QZlhBd01SaDN5ZjNQVVNLMEdNM0xxSTZFdlM0TmQzbVpfZFNiWFdkd3Eyb1VBRVZEMVctMGp3Q0d6dGhlUVdtUE5TLWFGWTU1Ym53VFpXWFh6QTJ5eWpfWTVpYnpEcmpRc1BUNjcyN2treDVERHVnaXQ1V0NMVmZQQklfTUhXb3RBMDhpMXBfeExudFBVRTVSbXhlMTM1eXJTcm9od2hxWlJsUEVSMHJfdmVPNGYyRkR4ZDJGNjRtX3MwZFYwdnRVLXREOG5zYWd3MV9R?oc=5','ebf36f89b0f9416675af03baaadd9cd650784cf7','''Ya es demasiado tarde'': advierten que el avance de la Inteligencia Artificial superó el punto de no retorno','''Ya es demasiado tarde'': advierten que el avance de la Inteligencia Artificial superó el punto de no retorno  Mnews',NULL,'Google News/Mnews',0.7,'es',NULL,'2026-09-16T14:16:18+00:00','2026-09-16T19:40:45+00:00',192,45.1,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(193,'tech','https://news.google.com/rss/articles/CBMi3wFBVV95cUxNNkVvdmF3R2Y4MXZMaDJnNzhRVlpfbVpYcjUwTlM2YVRNLWo2ajhkNTVrcFc2blYya1lTNWwyZzZqcHR4dDFnczFyZjBEb0tBNWxKWFhQVXVRUTV1b3NBaEluMXpVbEh4LU4xTHRWR05JQWM4ay1MTXVUamQ0MlFONVQ2aTVvM3ZyOFVwcWhLdkRQZGp2ODhHdmw2Sjd5cmUtU2VNUGlmYmc0eVU4TUhJY1lwVzd3M1ZBUjgxV3pHNk9RZ1FvY05hMHVncXQ1UF9sWWlKMVQ3Q3d3dlFmalFz0gHoAUFVX3lxTE1OZ2dsWUkxQ2k2aDZmZGp6bENHSkQzMV8tVzU1M0pmbTFsRFRwbExtQy1JRWZEWnR5eGszXzZDVmE4VUlMRlpkUEsta3BVbHJLc1JXazh6ZDdRa2ZyMTlEN2VLTWtLUWdMaUtiMUY2RkZGYnV0VHVBQ2NCczE4WHJ6Y3JMd2c1VzJhamR2T0k1bG1pV2VsbHVBQjNNYUxpMkxyWUxYcnotT1VSdERSMXlER05hR0QycTB0bHp5U21zUzlPRUNWdkVNdF95d3oyMzhEci0xVkVoRlYzT1JvX01RSHplbDIwLUw?oc=5','0f46178b37a2d07a427ac981ad6cea8e90dd7d03','Las carreras universitarias que podrían perder demanda por el avance de la inteligencia artificial','Las carreras universitarias que podrían perder demanda por el avance de la inteligencia artificial  El Liberal',NULL,'Google News/El Liberal',0.7,'es',NULL,'2026-09-07T07:00:00+00:00','2026-09-16T19:40:45+00:00',193,28.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(194,'tech','https://news.google.com/rss/articles/CBMi1gFBVV95cUxQT2pUUzZHQjlrSWh0aVpJaGtCaGtTZ2VCMmNGVFdWZXo4RjkyZER6Q2NkZmtVQTkxQkJwZUJzY2JDWnZzNU1ZUUFqT1QyRi1YaEdxY1RDZ0M2b0dZaEJlcEp1Z0JteVpzdzFieUt3UVo0Wll3LU9aNEgtNWlHckdfVEVvWmVvNVpGOGU3R2VJaC11SGFkOHZDSXJONHptX1BtOU5SVXozd2tLQkg4OUw5STZDOWdtSllod2pJR0NUN3h1eXBqOTlZbVl1cDFFeENoZWxaRTFR0gHbAUFVX3lxTE10SUJNeFBseXBUN09oYnlWWEVNY29EelhnekJHZTRLWFN2Nl9naV9FSUVyUEh2dV9rdWVXMloyUVNCWDBrSGhFQkxYWUtzWjBmY3BKNFloLVJjRkZpUGdGUGw4SE13VldDU195V2tvcy04WDdtR2RxMkpvXzY4WlpxQ1dQeEppdlZRYkhBWWJOU2t4T25iMVFqeTdRTWFPWGY4WmVuRURaQWpBcEJ0eGRYUUJocGtxRGEtQzh3YmVRaWlXYTNiUTJHMlZZVlJia01RU2NTSl92TGZOTQ?oc=5','d41b8ed31552276e85b433403aadbe095020d92a','La ONU llamó a un esfuerzo internacional para evitar que la Inteligencia Artificial se vuelva incontrolable','La ONU llamó a un esfuerzo internacional para evitar que la Inteligencia Artificial se vuelva incontrolable  Clarin.com',NULL,'Google News/Clarin.com',0.7,'es',NULL,'2026-09-07T07:00:00+00:00','2026-09-16T19:40:45+00:00',194,28.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(195,'tech','https://news.google.com/rss/articles/CBMi0AFBVV95cUxPaU8xQXg5QTB4NU9hVm9zd094NVJ2RXZoQ24yNnN3YTBsUzFYd1UyZE5Jcl9SSHZreEdtM3huX3ZyMFV6cGIzY0l1ZnZocll2bHFWU09IYlEyVXlQVXFnd1VMWWQwTFQ1cDRFTFdJYUJNSzMxT2NGems5NkhwZGIzSVpha05fbkRYX3JxZ2pUTlZ3cHFJSXBQeTFvMlFGQmNKaVpkUzVxNUJjQVBZWEM2bTN3SlpacFkweldGYWpFUmNiM0hmRXhkVnhFSlhHLXBR0gHWAUFVX3lxTE1QY1hJVHdxWXRJQktYbjNuQWhOTXJJNXNZdlk0c1ZUSGZ1ckZObkVJUUhwNE5QWFpFMEp3ak9qanFQVVNteDkwZDFyMUl6c09CZTJaRWwwOEZaYTZoMzlrUlhsTFg5T2R2T2puM19GWS1PZzRUX3l1Y3hUZm14N2NMeEhaVmQtWDRldFFtdU5tZXdTVVk1cG9KSXhfMzhKa3hqakhWM1dzMnJWYmNRZFNHRHhGd1AyNDlEbG55SUN3MGhIVmh3eDRYaHI3Q2VrbmY2bzAwamc?oc=5','7fd073aee20fdc1acdbce13863dcccb26c333a2a','El Gobierno rechazó regular la inteligencia artificial y reafirmó su alineamiento con Donald Trump','El Gobierno rechazó regular la inteligencia artificial y reafirmó su alineamiento con Donald Trump  Ambito',NULL,'Google News/Ambito',0.7,'es',NULL,'2026-09-16T01:05:00+00:00','2026-09-16T19:40:45+00:00',195,38.6,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(196,'tech','https://news.google.com/rss/articles/CBMid0FVX3lxTE54ZV84bTdLNUg1RFVuYzhaRjdKWnB5SUNuRlpUbkJvNl9PZWYzZVdkeElmUUY1OGtDb3FNaFpfaW04TzR4WDdhd2h4ZnZ5MnRKU1BUWHZXT2s0TUQ5YTZlLU5LWWNZUEtQS005WFVVbmk2VkpkU3o0?oc=5','0288a73c0a87c01c8cf3af67bfaba84ddfc853a3','El sector farmacéutico apuesta aún más fuerte por la inteligencia artificial para reducir costes y plazos','El sector farmacéutico apuesta aún más fuerte por la inteligencia artificial para reducir costes y plazos  TradingView',NULL,'Google News/TradingView',0.7,'es',NULL,'2026-09-16T13:54:46+00:00','2026-09-16T19:40:45+00:00',196,45.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(197,'tech','https://news.google.com/rss/articles/CBMi0AFBVV95cUxPZzBUNGhkQ1NkeF91RHpseE1zeElXcE5Za1VKTWxnWnFwcWVqTy0zdkZ5OVMycXp0bkx4TE45NHNPcXBhYmR1ME5jNXl6RURVQlhnWkhHWERicmZ4WXNwTWZnUVlCTUw5bWl6amxnazA4YnVuVjVGaWE4S2swSEdDbHc0aHVGWjkxTHNzSXl1enhfczV3OG9hV3dCYlVEXzlVc1hScXBMQnlPdFoxcjRjNXY2SkV0QThzUGpNcmlsRmZ4b2MxNkRBQ2xJY3BuRVFD0gG0A0FVX3lxTFBwdWJsYTZVZTlGOXpzSUJoWVFuS1FIRDM5WDNPOEt3cm5RQTJsSjFrSDVtaFY5RnZra2RIUXM5aUhsa1Q4NlczYU9IalRFcGZDX3h6SExxZ2VuMW1UeU55aEZsX29YNWJ3VmlSQ3ZyT25BZ3UxenBXZWY5czR1RGVlOF9YNnFfMFBvRWFTLXdBSThpVEpVeDJGZzR5ODl4WGhzMkRWXzZQX1NsbV9NbnlsM0FMcERmVldDVlRjQXN2WWFMN25aMG0waEtzOFh6eWIxLXdXN3RNLUQ4WWhIY0lxdkRnQkxCU29wRFFieTVuYXU1cFdmUHpWTmgxaWItTnFsVFEybUhRTkE4WV9lanJjdXRFRVExVUtORHQ3NlZidjJBUTZKdW9FczFGUFBaVlZULXVNOVNBNkcxRHcwQmNCSkxtUk8yLWJzb3ZPY3hLS0t3YTVWX0lRMU5WdFBlMTZycWJDalcyalVzM2tIa0ljb1pydjJHb3o2MjJqZTB3SElUZ2F3dVlrVDR1WldxNXJ0MTY4N0FTZ0ZRZ2VkUk1oMHJaR1k0dC15TTJsQ2ZkWnhOb0k?oc=5','8f7f847fcf356f24e816d2188b16d4a29849cee6','La Nación destacó un desarrollo con inteligencia artificial realizado en General Villegas','La Nación destacó un desarrollo con inteligencia artificial realizado en General Villegas  diarioactualidad.com',NULL,'Google News/diarioactualidad.com',0.7,'es',NULL,'2026-09-16T05:27:35+00:00','2026-09-16T19:40:45+00:00',197,40.7,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(198,'tech','https://news.google.com/rss/articles/CBMi0gFBVV95cUxPbnVqcW5SY2YxQjRaSm5oenZqdWNPM2xvQkgtT3NMTWl1N05CdWp4MDFmSzl5VHo2cTlITTQxNkJfcjh3QTk2bGwxcjBTQU0zUUs4NmdDSWx5eVdJcVN5TGU0SENWUVJHazlBNk5JcWlLbk1UbFVtVzFDN01sM2FJSTR1S2xkWU95VW13ZXIwRjh6QmNhUzhUMVpxUUdFcEViR1NxSkVWLVBpX09vdFlyZUpEWmxXMWNMMTZGRTh0d3FKQkpXdFJwRDV4U0dtQjBxdXc?oc=5','c73c164595f83541bb39dff58754ab24f4a8b244','Ariel Garbarz en Urbana BA: "La veracidad de las elecciones está en riesgo por la Inteligencia Artificial"','Ariel Garbarz en Urbana BA: "La veracidad de las elecciones está en riesgo por la Inteligencia Artificial"  lanoticiaweb.com.ar',NULL,'Google News/lanoticiaweb.com.ar',0.7,'es',NULL,'2026-09-16T16:34:57+00:00','2026-09-16T19:40:45+00:00',198,46.3,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(199,'tech','https://news.google.com/rss/articles/CBMi3AFBVV95cUxOM1V0aUlHc0RIUFRucnExeVJFWmlqMUNuaTktdWc5ZVlWaXdIaUcydjRsVzl1N1QwVmt5bzA0bnVJNXYwbER1UWZOSThLUXN4MlZyRG13TFV0OEFwRWhydmVCc2NkbFQzTDFaWGNDOW1UUXBDYXM3RmVZRmZtamhBOGFtTnc4dHVpOGhscjl6NEtvOGVuTXlaeG4ydjhscURDWjg4YnBhZnVQeU45WEMtcjRSa2ZsR05ZM0gzY3VkVldtbDRMZHloRldyVlhtOWVib2hHXzVLa0JDMW9X0gHgAUFVX3lxTE9SMnNaeXh1OG52WFh4X29VOUlhajZXOE5nVE9UX2dOanhuMHgwWloyalBIODNXQTBMVXpnLXlQMHRzZldzWHQ2MjE2Z2RXcVJtX2Q3SnlSaDdNRnV5TjRUSFJUT2pTb1Y0cUJNQ3gtZHlibUM4Q051dlpMUWlOTEdFYU1vcUMzNHNnRW52SUN5Q0ZSbWNWNjNmc28tcUJTOWRoRFNLWXljMkRBeGZTYmFuTVFReXJ0eWZDZmEyU013Wm9GSS1Bd1o2eGpjNzFFc2xEb3RhZS1nN2lSM3ZkUDhT?oc=5','179ad5b0b1383dfaf513bcdc6c9eff5aede4a68c','El Papa León XIV respaldará seis proyectos en América sobre inteligencia artificial y crisis social','El Papa León XIV respaldará seis proyectos en América sobre inteligencia artificial y crisis social  SudOeste BA',NULL,'Google News/SudOeste BA',0.7,'es',NULL,'2026-09-16T14:32:00+00:00','2026-09-16T19:40:45+00:00',199,45.3,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(200,'tech','https://news.google.com/rss/articles/CBMisAFBVV95cUxPRGNucTBheE14bjh1LVFVNHkyMVRrc0ptSW1DQmhqbklVbzZiazR2VlVxQkVlRnNLLUFYQnJYWkJvcVJDUG5yX1RLMXdma3dmTnFDQ3o3dGNwd0hrdm1zbl9pSTByTFZ3Zi1iX01BVHZWc0hWN01sNVU5U2NZaktGbkoxUVBVdWU1MTBIMS1ER3Y0VkhQZ0gzV0FzekR5T1NsRUZSY3QxeTJaOGxuMmlsOdIBywFBVV95cUxQYnc1a3JsYU9NUHMySG1OWEgydHFrOGVhdHN6SWp1ejVicUl1MUtjNXpuMUdVRUhjMGs5Tk11SEJncUhqdG5CWE9WNVZDRHBpRDJhZHhWRVoyTmhRUE1UQnlJSnh2UUlFMF91ZjNVdm1pSG1jQ0U1UU1JYjhkY2NmWXpYM3RvV0ZQeUpZQlIwRUtXcDdKcTcxM3pTN19aa1c4bWhIbm1hb0lGSXNlcGpTa3RBNUFfU3BScGV3SmRJQzNFazE5dl9VenJINA?oc=5','cda378656dc405c68de28f3c96a4a276fcecc2ac','¿Puede la Inteligencia Artificial terminar con el mundo? Y si sí, ¿cómo?','¿Puede la Inteligencia Artificial terminar con el mundo? Y si sí, ¿cómo?  Infobae',NULL,'Google News/Infobae',0.7,'es',NULL,'2026-09-11T16:32:00+00:00','2026-09-16T19:40:45+00:00',200,28.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(201,'tech','https://news.google.com/rss/articles/CBMizwFBVV95cUxOY0YtQmJrdnp3N0RuTDRSeWVqcEYtOHRXV1h3WTRuUnNBbFcwUjRmTHZ2dTA5SGJLU0hwNFoyQUN3bTJzdWRnRzF4SDJfbDg3WGF1ZEZ3ZmVyYjJhMFhqa0paUnF5WnAwTk1STkNUSXRjX3ZhQVJldWJySXh5Z1BUOUlrQU5URzNiaU1tMloxMWROWGNtTGsweklqdUVhTVg5c050Nm5KZkk1NktLQVVmMVU4SmtOT3gzcVFTRVRWdWctTFdXWWtRUEE0ODNuclU?oc=5','884613148bef0b671c87d06e2738fa61facdba03','Gustavo Béliz disertará en La Plata sobre los desafíos de la Inteligencia Artificial','Gustavo Béliz disertará en La Plata sobre los desafíos de la Inteligencia Artificial  Info Blanco Sobre Negro',NULL,'Google News/Info Blanco Sobre Negro',0.7,'es',NULL,'2026-09-16T12:56:31+00:00','2026-09-16T19:40:45+00:00',201,44.5,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(202,'tech','https://news.google.com/rss/articles/CBMiwAFBVV95cUxQUGs2NlZqbVUyY29Ld1luRHI4WUNwWVY1djJwQkZBNWxUbnFsZlp3QWh2YXB1ME44ZGlyem1UMTRONzR0andyb0NKMUN4NnN2MXFzTk5Cb1prdkhybUV4MDVvOUpVRVdta1diLWs4WkRoM3owSjc3OHR6V0dyLUpuUGhLd0dyZTJRdDYwOVdBV0lxaE1XNFhwel90cnA0b1ZOdkg5NU9CQkVCVEg1a0xReTZVN013R0pndjVkUHhSMUfSAcABQVVfeXFMTjRoTjdGN0E2ai1jOEpoWHljaWVDLWFwM2NPVVRTTURZaFZFeE9lN3dNN1Rtamd4ZTJMMmI2SlAtZTRyVG44R0NXTFVPQmVLZ0ZWeEtzaENUZUw3MTdKWVlHUlJ6R2tzbWlFcVhJa0NaT0E5RXBnRWVHbm5DZnVldUlMNFlQVjdPclRxNnNFcTAyY0x5bGlRNGNTZW1vRkVEYXFReU1qZnpiM3FkaVN2WjBvZnRFSGUtQzlYUGxEVzFh?oc=5','97bf6d5081ab07802b05921630ff0b732e904409','"Soltamos a la bestia": ¿quién puede frenar ahora la IA?','"Soltamos a la bestia": ¿quién puede frenar ahora la IA?  DW.com',NULL,'Google News/DW.com',0.7,'es',NULL,'2026-09-16T17:46:15+00:00','2026-09-16T19:40:45+00:00',202,46.9,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(203,'tech','https://news.google.com/rss/articles/CBMi4gFBVV95cUxPS3N2TFJFSFFGQ3Z5Tk5MMnNJdV8yUElHWU0xZDVISkExNE9DcW1yX0tSUkRZaC02bkJSc3RaNFAtbGtRSF9RYjFfdnJsc0VNWFNtMGNGSHFTQndZS0F5RkpDYkQ0QXBaM0g2WTB2UDhaSFZYOTZrekJ0RTZPOV9CREFfNzlVeXdpS3p1M0FqSFlaNUFVSlZqdGZnSGt0RDVNaVFodHpKVllJV0R3V24yUjR1UUctbHVOZnVRbV9HaE85MWQtV0F6NUkwQzdmandBSXA1VzdvbXd2TGhsUmlPZFRB0gH8AUFVX3lxTE55cHNMdEZHM2JWVDlkV0dOcFRUTk9sWEJfeThOc1ZldTY4TXpfdVQ2ZWpYdm5wODRRWE15c21NaUhYSlpaM0pOR1E5eDJzNlNHWEJJdzBMNklVSFlSUks0QjJrWU1kSGMyejlDdE5RTGc4dmFXa014OWJTZjRCVkM2QUpxdk9iUl9PVlNTbmZ0czdHa1NiSTUwdHgtU3VxcnM5Wl9EbEh4REJjTVc2SnZwX294M1ZUSUlNaGlCVEJ3bC1zQ0VCTFhMR1hPeVZ2cTN4TkdXa09hazU4YTc4VjNMRnNkS0dDQWl4b0V4RHU1YjBmLXRrNWFqVXhVQg?oc=5','c4548cec5e0cd4c850c312263fcb5eb0c7d10194','La inteligencia artificial y las ''stablecoins'' centran el Mastercard Innovation Forum España 2026','La inteligencia artificial y las ''stablecoins'' centran el Mastercard Innovation Forum España 2026  Infobae',NULL,'Google News/Infobae',0.7,'es',NULL,'2026-09-16T06:45:14+00:00','2026-09-16T19:40:45+00:00',203,41.4,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(204,'tech','https://news.google.com/rss/articles/CBMi6wFBVV95cUxQWldZQWxNbEtGZlg4dWZROE9WV2NLZEl3VWNWaEtSSVhMcGRzdE8yWlFfaGZ6TUdteEZkeFFoUUVCR1RoN0NMUWxUR2lYenJxMVlWaWVtTFRUbndfQ21odWV3VUZjNnBVUy1XdXBGWmRtTUpQbzVrYmpJUGZ3enpvc2pWdnhfRk9kdGRBT2hmNms5QjkzRVFWU2FPM3pISVF1ajNhbU1pVXZDeW43THkzZnZ0YkdoRFQ0eHd6SG9YM0lLdElBcUtUQS1MOTFVNnY3STlMX3g4MGltbThwUUlIVjZEb1pBMlVucHNB0gHwAUFVX3lxTE9OSzg5Q1EwS2wwVHpfbGxrTzlGY2lfcVRESDA2clZZZWhVVGY2NzVVQ0VyanN6VE9mb0xEZFVLT0pnUHpXZDVVUGlKR09Gbk5vREFTR0s0UUhqdEdXcURlX1l5eDQzVUlhNWZtcVlBZVlyM1dXeV8xVHYySEp3b1JrWXlBOTJ6QVN2bVJPckdlVEJYdlg0S1p3b0VzNmV0OWYydGNOUkVyRWV4S0lFWTczVVJsWGpVMGNNc0Vxa04xNGd4RzB0N01RQWxrdk43blAyalNNMDFqNzFnR1AzRWREYUk5dzdlNnhlVFE4N3hTbw?oc=5','6ab199560332cc54edd7242783ad9fe867f3705c','¿La IA puede matarnos? Por qué la Inteligencia Artificial Generativa es una necesidad del capital y no de la','¿La IA puede matarnos? Por qué la Inteligencia Artificial Generativa es una necesidad del capital y no de la  tiempoar.com.ar',NULL,'Google News/tiempoar.com.ar',0.7,'es',NULL,'2026-09-16T18:03:53+00:00','2026-09-16T19:40:45+00:00',204,47.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(205,'tech','https://news.google.com/rss/articles/CBMi5wFBVV95cUxNY0N3aEZMZ25qXy1wcjRDTDN6eDM4RUtNQkc1SjlIcXVYRE9fb011UlVXaWp5Z2ZGRVhrT1Y1OExHY2dFV2U4ZjBOMVpoTUhmNjNRRmYzbDlRVFVjTE9UZXl6dVotb3oyUGtMMlFISGtNZ2VFeWtZaEgtaEdfcW9WaG5vendfV21INFM1alNoUTBQYWJHZ0ZPQ1ZvOXlUakxPaFRFUVpaZDhKaXFEZmJ5dGVfTjRiTkNYQllRbFdZN2JMNjhLTjN2M19yYnFzd09uZVJRM3puRXpUV2tidXFWaE96a1hPTXfSAfsBQVVfeXFMUHlEZUdsYmtfOC1ZVS1reWhvWE8zQ0ZGcFhQS2FNb1VyYUkwVWhNUFNYeEQwa2lhMGszNjFDNGdFbkdvbkVxYVl1Y0N0SFNBeXZBY1RMN2pwXzJydU84dDdwVGU0NC1lUXhIMm9uTERzV2tvMm5SY3hBa2I4ZzNjY0NJZnQyVlZHTEJJaDZNRFNhSlo0Ti05bHVnUmhubVVITXMzcHFUWW5CclRnQ3pHSld4THRtUXN0a3RxaGZCWU9UNHVQRHQ2dERYbzB2RWY1R1B6ODNveXRGZkt3cWVob2ZLMTBsWlNWWVJDNEZJT3JfdW5QYzhTeDNLNlE?oc=5','eddeaab6c20ae6ab7b2f4ac40c29ef71cfe50a23','Un investigador renunció a Google y repitió las advertencias de Jacob Coxon: “La IA acabará con la humanidad”','Un investigador renunció a Google y repitió las advertencias de Jacob Coxon: “La IA acabará con la humanidad”  TN',NULL,'Google News/TN',0.7,'es',NULL,'2026-09-16T12:06:45+00:00','2026-09-16T19:40:45+00:00',205,44.1,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(206,'tech','https://news.google.com/rss/articles/CBMi8gFBVV95cUxOQlExVnZqVEZyNU43SEdjNzhsS3F4eHV2THdKMjJtVzh5R1A2QTJaRi1qRDVEMlhIcVcyWnRoV1E1ZmVERVIyUnVvUjR0Mk5HRk0wUU5nVngwU2tQU3dPcDQzMEljOWZLQXc5NnlpZl9uU191YUkzdHdXV0x5ODk1RHZJc3hjeTNUNjA3SXdSem8yQ2gxSV9fWWMzZW13ajhtcDlTV18zd2pWNU0xQjhfdmRvSGZCdy14aHBWVjhFVEMzZlhpcVVOR1FyOVFuTzJfY2E1TTllbzNQMG1tZXZCMzlUY3JCUnBwNUV4em5KNmVOdw?oc=5','5efd753ebb883fbf3b8e2d7b01bd4f3e607aac8b','El papa León XIV apoyará a 6 proyectos que buscan enfrentar la inteligencia artificial y la crisis social en América','El papa León XIV apoyará a 6 proyectos que buscan enfrentar la inteligencia artificial y la crisis social en América  Radio Mitre',NULL,'Google News/Radio Mitre',0.7,'es',NULL,'2026-09-16T12:33:40+00:00','2026-09-16T19:40:45+00:00',206,44.3,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(207,'tech','https://news.google.com/rss/articles/CBMizAFBVV95cUxQdDBnRU8xVV9CZVRlNzlsVm1ORXBVM0ZWMVI0dUp1bXhMZi1iN25GQnhzcVhHMVRuaHdDUW1WLTRHdjhDVTNET0E1Z3pwNnZhVXpmRFhjWHR2aHpSUHdpcW5FQ3RuaUlPNXdBQUU1RENITWxXT2JPWE1HREdYWVpaSWFsT0ZoejcxOHR3bXBJX3BZQzh3eVp4aVExQUpDdG9kV2E4TkZfZDJ2YkllQm01bVJnNXBLbUVDdUxCTFVWZnRfb0d6enpiMllUa0c?oc=5','ee82c8c5b7e6904a5f16aac55f0362d0746fa6c0','Entre Ríos lanzó una plataforma gratuita para capacitarse en inteligencia artificial','Entre Ríos lanzó una plataforma gratuita para capacitarse en inteligencia artificial  Diario El Debate Pregón',NULL,'Google News/Diario El Debate Pregón',0.7,'es',NULL,'2026-09-16T10:38:26+00:00','2026-09-16T19:40:45+00:00',207,43.3,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(208,'tech','https://news.google.com/rss/articles/CBMimgFBVV95cUxPVUpSVU1xeDFZUkgweWlnWnhHTkZ0VTBMVnZBM3o5N1c1Qzl4bnRMVWFJUHhlamdLZUFmelQzZllKNjRJTjFLUl9pcVlmcnFJc29QcHpVclNQUDlmb29wRzFGTUZFNjJVeDR2czhHZEs0RldYZHZZeDk5ZXJMS1ZJa1lrczFhMTZwWGw2NThiSGFJak5xUWFKdmpB0gGfAUFVX3lxTE9oaE1UTG5SYTd6Tk9vX1VCR0dQdTktNE4zcVdXWnd5TDB5a1N5SWRzNjRJZ1hoSGcydlBkbGI3RFQwUkJZOHF6WXVUcnE5WHRkTFVYT2lWZzFOSy1rQUl6dU5xRGs2RlVBanNjdWVWM3YyaGxtY3J0TkNiMVRJSkpVUG9ZRHVDRWNsaGY3TlNlZnpTVXpGOE4wa3FfSzRPZw?oc=5','234d47f884a6a4b48c4e4dcda7df0f42074aec41','Todo vibra al compás del petróleo y de la Inteligencia Artificial','Todo vibra al compás del petróleo y de la Inteligencia Artificial  eleconomista.com.ar',NULL,'Google News/eleconomista.com.ar',0.7,'es',NULL,'2026-09-14T23:21:00+00:00','2026-09-16T19:40:45+00:00',208,28.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(209,'tech','https://news.google.com/rss/articles/CBMizgFBVV95cUxQeDZwUG1uWFY1dnZ4NFVyNDFVODVLZi1FMi01dGJqRGl2WF9faVhwNnZxT2kzNUEwWWdJNllJRFR0c0wzZ2x6RFZRZ1YyX2VYdm10eEdlNkMxSEdlZGs4bmdFS1J4SC1PdU1TZGp2WW1WcThHV1BTY2ZfdVN1eE5iQzZ2UGVHcjhfaTZCQWlEdU1QTTlSX0pZY2hXdWRhcEJnY2pHZ05BOXZSYUJNcGtDSlJwZnZDMEVmTk9ScktxbG9IWGVQMGQtUUVaeFM0UQ?oc=5','fbb220aa95050d51896b997fe0b591eaef1b090b','Exingeniero de Google advierte sobre los peligros de la IA','Exingeniero de Google advierte sobre los peligros de la IA  lu17.com',NULL,'Google News/lu17.com',0.7,'es',NULL,'2026-09-16T16:28:00+00:00','2026-09-16T19:40:45+00:00',209,46.2,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(210,'tech','https://news.google.com/rss/articles/CBMiwwFBVV95cUxNc1J3LUlTQnVUNkNtVE5Nc0E2X2kyYmNESmgyNC1Tak1BZzNJSUZSTVFUend0VWN4XzNoT2pFY3I5RmI2S2drbEVJem5VWXRnZktYZGVtYkMyci1FRzZMeHNDaFZ6czNsOTdQbkhaUGNjZC1UWFI3a2dFV01fTUF2YkdMWW9PMmxzZlJhXzhtcnp5c1RCZlVBU2RLSWFBc0lMOEpPcGt1WGp5M3kycmYwRGFmdXc4WVE5aG1NUk5adGpqdmc?oc=5','d3c32d573f896a81cf4cd16d77f4c8b0691f6692','STMicroelectronics: impulso estratégico en infraestructura de inteligencia artificial','STMicroelectronics: impulso estratégico en infraestructura de inteligencia artificial  Yahoo',NULL,'Google News/Yahoo',0.7,'es',NULL,'2026-09-16T05:30:00+00:00','2026-09-16T19:40:45+00:00',210,40.8,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(211,'tech','https://news.google.com/rss/articles/CBMi1wFBVV95cUxNeUM3RDF2dkJjd2Z4d2x0Wk5GUWZYYVU0ZHplWklubmM0blNIaDB6Uy1rYlVzTnUyM2JDQy0teUplMGU2MmtTWUYxVEFIQ0V4Vy1qelFuYkVxX3p5MXJmVFVjYUk3aFZQdlA5ZHJTMUZSeVRaTmJ2TmlVSW05VHo4YUxEOVhfU0JfYTI4QmEwNzhRc3ZhakttbGFUNUpvR0gzVFFHLXdxakpRTmJvV01oUzcya3FpRTcyc2JIZWhCYW8yTFZVRXUtQUw3WWl2SG1DOU9ucTc2b9IB8gFBVV95cUxQYmhuZXYxaDZ0TkhYM1hjMDZFQk5zNVRLMGJpMmpabUJycndBazZQbHF5dzYwUU1wTjkzWm5LbmVEV2tmX3NxbTdIejVkeUo5UklwdllYWFg4SlJOY0FWNDlsaUt0OEZ0SUZHa3FfaW1VOGJJNGRuRkdmVFgxemk0bHFMamdtcElaTnhIS3Nrb09MN2JKWWlhNW9WNWZfVU5yQVl5VTZSX28tdWQtaTRRZ29zd1F1ejh5SzdkUUhORWFNR0M4NVhTaExtNmFnM2JRRmxRbC10RW54YWJIRGJranVzWDQ1dE9sUnBuZkRuQVMyQQ?oc=5','16c255ccc7c8bd416ea3fecc4b33c696edb53213','Jensen Huang, CEO de Nvidia, defiende el avance de la IA: “No necesitamos nuevas leyes ni regulaciones”','Jensen Huang, CEO de Nvidia, defiende el avance de la IA: “No necesitamos nuevas leyes ni regulaciones”  Infobae',NULL,'Google News/Infobae',0.7,'es',NULL,'2026-09-16T14:00:00+00:00','2026-09-16T19:40:45+00:00',211,45.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(212,'tech','https://news.google.com/rss/articles/CBMisgFBVV95cUxNaHBwRmxWSWhCQkhKWHFTeDBNSmlmUnBRQ3cxWmRwUllUTVZUSV9hNzI2WEZJUUVRdWZiUkJqMnk1OHd6a3cyNzRDYmhvUklfMC1OcWczNGNzbV9uRW9Dd0FnR0tGeGRHdzdLOEF3bnpOM1FYQ2lvSXAtLWw5cEpRS1N3S1ZOQnotQUZ1YW9vVXFKN1NvSEp2YlN6TGhteU5BcVdQRVlLUkVLY1laSnJiREFn0gGyAUFVX3lxTE1ocHBGbFZJaEJCSEpYcVN4ME1KaWZScFFDdzFaZHBSWVRNVlRJX2E3MjZYRklRRVF1ZmJSQmoyeTU4d3prdzI3NENiaG9SSV8wLU5xZzM0Y3NtX25Fb0N3QWdHS0Z4ZEd3N0s4QXduek4zUVhDaW9JcC0tbDlwSlFLU3dLVk5Cei1BRnVhb29VcUo3U29ISnZiU3pMaG15TkFxV1BFWUtSRUtjWVpKcmJEQWc?oc=5','e8b88deb7229e5466040ead5c0f43d4b59af1904','Dime en qué mes naciste y la inteligencia artificial te dirá qué tipo de padre eres','Dime en qué mes naciste y la inteligencia artificial te dirá qué tipo de padre eres  Minutouno',NULL,'Google News/Minutouno',0.7,'es',NULL,'2026-09-16T10:10:00+00:00','2026-09-16T19:40:45+00:00',212,43.1,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(213,'tech','https://news.google.com/rss/articles/CBMi0AFBVV95cUxQVzduVGV1QnNwMENHUWNDVlFmUGNxc1ZZY29BaXFFVHprZlVJdElHalQxRlRyMFFnTG9FYjZWNGtaYmNwVkQ3Y014TjQwNnpib2pudFRQLUt5SjBWaFY4Y01tZWxfcEQ3bExBUlBKdzliSWFCMW5Kb1dxZ0F3VlVIQkM0VHJZTTFfS0tZQzNtb0RURTlrQUgyZVFfMGlNQmJtam52NjVDSVdHX3RmbjJMal9qTlBvWExwSHZQTVBKczY0SXNNVlBHLTlEOXVRUmZI?oc=5','06ec35ed2eb45176f51c82f1c7961fafa582daf3','Mark Zuckerberg rechaza los llamados a frenar el desarrollo en todo el sector de la inteligencia artificial','Mark Zuckerberg rechaza los llamados a frenar el desarrollo en todo el sector de la inteligencia artificial  itongadol.com',NULL,'Google News/itongadol.com',0.7,'es',NULL,'2026-09-16T12:39:05+00:00','2026-09-16T19:40:45+00:00',213,44.3,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(214,'tech','https://news.google.com/rss/articles/CBMi0gFBVV95cUxORUlVRGZNWFFpQzVSaXVPWTd4aUNYTXBiUGlNb0JERk1aaUgzaFNpaS10elFSSDlCR2xlRjlVZlRHYWg2b05YN1IyVkRQenBGRHVrUGV3aWNnWXRkZ3JoRVBvYjd5RS1qM0lQRnVEN2xCR3VWM0NKOVVtZDNxMDJNZm1GYlF4TmlENlBrLWx5djlRYTVTTV9OcXp3RS16SlNZdlhqaEF4U3JOQUVkbFprSGJKOWtzazhvYUpZVGVJazdpVWRUeHZyZERBY3dNVXNFQ0E?oc=5','156b0ebc7abe450b1f5b3dd8f60044474c14996c','Los abogados de Mendoza ya tienen una nueva herramienta para buscar fallos con Inteligencia Artificial','Los abogados de Mendoza ya tienen una nueva herramienta para buscar fallos con Inteligencia Artificial  Diario El Sol Mendoza',NULL,'Google News/Diario El Sol Mendoza',0.7,'es',NULL,'2026-09-16T11:54:18+00:00','2026-09-16T19:40:45+00:00',214,44.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(215,'tech','https://news.google.com/rss/articles/CBMivgFBVV95cUxNRzZCQ2oza3RqS3pRTVFucjB0X2ZRQVFBRWdUZTBfOWoxcGNjcE00TGRpLVdKa2hpU3hLaWZHU3dBRHR0X1hubjFacnJ0cXF3TTRuTGhuTjY3ZUVVU3dtYUtJa000VWVCNUdCdnpGZU1YNFJGWmV0SUxBTXktdy1sdmNnYzNldmo5bzlxS09ZMDcwaXdmT1E3OVN1UVhETWw4MVk5d2IyNlFlenZkRGRzYzd0enI4UFdlTm1HMnhR0gHDAUFVX3lxTE4wT1RBNmhEN2Y2Ri1Yb19NVG1nQzQyemQwd1dHTVRHNXZwem44NWlJSGN2VmI4N1J6WkNlTWJXZk1yODgxa3JqVTNzUG5GVkRyZi1fRFo1SjJuS3NIekYzQ3lxbUotX0hZOTh5LThDU3dEYnNVZktQUXBsbmo2NTMtc1dEYWgzUFJ5LXh2ZXM4eENCbWtsUnUwOFo0TjFNU1YycThXZXpYRGd0d0R5RzFZaGFJcDdIVkFuOXgyWXRYcklZOA?oc=5','e8cee53a6deec30e3d0d160a70525aaab4004b1a','El BIS advierte sobre riesgos para el sistema financiero por el boom de la IA','El BIS advierte sobre riesgos para el sistema financiero por el boom de la IA  iProUP',NULL,'Google News/iProUP',0.7,'es',NULL,'2026-09-16T11:37:39+00:00','2026-09-16T19:40:45+00:00',215,43.8,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(216,'tech','https://news.google.com/rss/articles/CBMizwFBVV95cUxNUGh6YUROUi1GQ3JDRVNzRlg4c29mWnZ5N093YVZoVU9ha2xvVUMzbGs3REVxMTZUZVNORzV6THpPUXFZaWRwQzBKQ01xX1FJcWUxLUUxdEFlUUdHamhOU2lYVEZkMHlIZzBwcXBoQVE4R3RsS1hHRWVKcU5XaDFTdnV2clRFMV9MSXhoazZJaXRvSDZ0eXFud3cyc0dvRGhZM05nRGxFaE9NbGU0V24wbEphSzN1aHBlOTg5akFwY1dOUU5fSmZlMWE5ZXFBUUU?oc=5','366202252a01cec6c13ead71c9e948afec903b3f','OpenAI, Anthropic y Google trabajan en la creación de un organismo regulador de la IA','OpenAI, Anthropic y Google trabajan en la creación de un organismo regulador de la IA  RFI',NULL,'Google News/RFI',0.7,'es',NULL,'2026-09-16T11:56:35+00:00','2026-09-16T19:40:45+00:00',216,44.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(217,'tech','https://news.google.com/rss/articles/CBMi2gFBVV95cUxPeDhVOHB1SVFydlBlQmtpdUFMcVNXel9ZQlhXbXNSblVoVFFLSFlmdFJIcTA3dkxDa3hDcUFOOW5YdEtzaGJ5dVJHSE9rUWlDQVJ4SWczaHpaaTdsd3hPN2loT1h3MWxfWTk5S3Z4NWZpcnZoMTZsQjBmVnlTVW96RHZIaFphSEkyOTg5THMxXzRTVUJ6UUg0SkxObkpUQm45ZjV4ZkNiNDFUcVp0RHpiZ0VZYk1wejFneHdlcUJpZjVGTUxOZVBKVE5zZGRFRENidjlGN211djY4QQ?oc=5','476c2f67fe98fc9ee5910488b7067364d297d433','Dictarán un curso gratuito sobre inteligencia artificial y herramientas para acceder al empleo','Dictarán un curso gratuito sobre inteligencia artificial y herramientas para acceder al empleo  Gobierno de la Provincia de Salta, Argentina',NULL,'Google News/Gobierno de la Provincia de Salta, Argentina',0.7,'es',NULL,'2026-09-11T07:00:00+00:00','2026-09-16T19:40:45+00:00',217,28.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(218,'tech','https://news.google.com/rss/articles/CBMizAFBVV95cUxOQUNYOXBCS2lpSFBYRVdGME9fSFV3NmhCRHdFV0k3aEFzdW1XUUNVU2wxV19BVmVRdGN4WHFVeGs0RmFYaTFRbWl1TDQ0M25DVW9PMVdBUW1aZ3hBZmlsa3VNTEZmb25ySDZUMkU0TURmaHVDSl9FWjRidFJiZ0FPVGxjUVdnRjFtY3hsTVpPN1lraXZHX1Q4UG9IWWc0UWhpMEZjSFpieEF2SjZXZHNBdGlXcjJUaHB5M2w2TjlrOEFicFZzS3VOMmZEcnk?oc=5','178679c5ca3f220f8f16072b0a0b84ccd371bd5e','Un grupo de legisladores está pidiendo que se regule la IA de manera urgente','Un grupo de legisladores está pidiendo que se regule la IA de manera urgente  Spectrum Noticias',NULL,'Google News/Spectrum Noticias',0.7,'es',NULL,'2026-09-16T16:44:00+00:00','2026-09-16T19:40:45+00:00',218,46.4,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(219,'tech','https://news.google.com/rss/articles/CBMi9wFBVV95cUxQWkRJd0tTdnRxTHNXQ0JadWtrUnRxOFBib3VXUXhTQjZlMHVwX2dvSllTZmJNYjJ2NVFjZG5tdGZjb1VSV3FZdDZQZ0psVGxnLTFOUTU5aDRnRGk2V011YldIdGhiY3pUbmpXeFJMaWdCZHJxV3YzLXBvVnBkZnVLQl84akFsTlg3azhXa2hFaVdYOVVuWEtzV3Y1aUgxV1BjdWkybWg3Uk5GdmpzU1o1WE04ZzNTc3NyYy1Xc0VWdW9JMkFGZTFXZWxOVVJMUHNnbEppeWR3VklzejhUd2FKbVN2X0VNYTh2OXZFTnN5eWQ2OC1URm5r0gGGAkFVX3lxTE5vcTA5SEtoMkY5Q3hrb3FybTJDT1Z5eWJuVHZIUFlaYU1QUFlXQWxVd2xwZEw0eTI3dDBrQ0dvYlZjYTJBWGlEOHVGUVF4UzVucjJPRXlJUzNvdVhjbnlYZ1RWbDN4Wkd3cjJPSFhzc3ZaNGFLUHlEOFNsbFIwa2ljWk1lZ21zMUdQMXJlU2lCcDB6Ry1JSHg2XzM3emQyZWx1SGd0TEQ3d0hKR2tOWkRyWjBoZm16UE53V3pfcUlDUmdjUE1aVV9nSFhMeFd3bTdFUkdMUjZTdzdhSkM4SVZvcndzWVdXU2xIN041eDlnRmQ5ZVRFTGFDSEZoRDJmaFo1WWJjN1E?oc=5','6d0e23b3fc926d00f02076c71173bae0d446861c','El jefe de IA de Microsoft cuestionó a Anthropic y advirtió sobre riesgos para la humanidad','El jefe de IA de Microsoft cuestionó a Anthropic y advirtió sobre riesgos para la humanidad  Agencia Noticias Argentinas',NULL,'Google News/Agencia Noticias Argentinas',0.7,'es',NULL,'2026-09-16T18:27:28+00:00','2026-09-16T19:40:45+00:00',219,47.2,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(220,'tech','https://news.google.com/rss/articles/CBMivAFBVV95cUxNRG9HWTVZb0t2MXYwSm5YaDczQW16c1poaGpURVljVmR6dDV4UUFVdHB6LXZhekZhXzJrdnpyMjRfemswVDR6ZS1OSGtqaV9PNFI2aVktVmNPa00yQmdHVmNfSzd4dHV0aFBGanVTeDM5VFNHTE1QenhYY20zbHhyMkg4SDVHM1N3M2dsQmR6cVdhZzB4NUVtY3lYZnBJMjdIc1lIaUhPN01ZLUVxNHhScFpRS2dXci1LcXEweA?oc=5','c5a23424614ef52c52f62eece616f894a6e23034','Inteligencia artificial sin control: los riesgos que ya preocupan a sus investigadores','Inteligencia artificial sin control: los riesgos que ya preocupan a sus investigadores  GN Noticias',NULL,'Google News/GN Noticias',0.7,'es',NULL,'2026-09-16T13:04:00+00:00','2026-09-16T19:40:45+00:00',220,44.5,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(221,'tech','https://news.google.com/rss/articles/CBMi9wFBVV95cUxNMmZGcHFYUG81Vk42Q21aZlFKS1V2SzQ2eENGd1liMUc4TFdpTFlTREJVT2lXX1lMX3BVYlBqaGN5MWdiTTNHYk4tQWhNaWRlSS1UMVRWZElnR09pbDhndEc2TVdRYWpKNUlIeFYwMW5WeXF3emowQkRRMElWZmNpVmp4SzQ1S0Z2T1lPakRqTFJJVElYSWJsa05CRmVIdG9nRmJ2a19TaHN4T1RQRVJqcGhFNHZjbUVObnE1MWNWV0lab2F4TlFtV29HbHFsOElQNmc2cy1OdVM5OGY2WlY2aDVXNEE5V0pJNDJBUEppTmlLamhHb293?oc=5','2945646447d95dce93326ca9973f6f3723b579ac','Obispos colombianos exploran cómo la inteligencia artificial puede transformar la misión sin deshumanizarla pastoralmente','Obispos colombianos exploran cómo la inteligencia artificial puede transformar la misión sin deshumanizarla pastoralmente  ADN Celam',NULL,'Google News/ADN Celam',0.7,'es',NULL,'2026-09-16T15:39:36+00:00','2026-09-16T19:40:45+00:00',221,45.8,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(222,'tech','https://news.google.com/rss/articles/CBMinAFBVV95cUxPQXg5QWZHQkhMRkdLNl9fWTBMV3JGSWZ5UWhYR09VWlBJR25taXRNSnRfUW5wb0tPTUs5c0xmbWJWbFhNQnJhQkYtRzF6TDBWS2lzSEpFRE8wd3JMaHpyS2p1b2paSUxSdUFaRmN3eXVZdFJBbUhPaW1qNVRHWmhZZVg1X21OUHlsUGI0dU1SeFdsOFRxYXc4MFQyd3E?oc=5','4e85fd09dcc29e1a165d51004805281505d256c5','Inteligencia Artificial en Estaciones de Servicio: el dato por sí solo no alcanza para mejorar la rentabilidad','Inteligencia Artificial en Estaciones de Servicio: el dato por sí solo no alcanza para mejorar la rentabilidad  Surtidores LATAM',NULL,'Google News/Surtidores LATAM',0.7,'es',NULL,'2026-09-16T11:34:44+00:00','2026-09-16T19:40:45+00:00',222,43.8,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(223,'tech','https://news.google.com/rss/articles/CBMi1wFBVV95cUxNX3lFcEs2ajY2VUN1SzVxNm5JMUVLQV8tVUY2T09XVTZwZlRXbDRIRWh6V29xZWlFRkJ2X0ExX1ZZYkhMNENSV1BGbUlIZnhyOWstVXVmc084T2VLeVhOYWxqZnlyZzVOVnlha3NyaWVzWF9GX2hocEN5VHZzb1h3ZTY0T2Nwek1nS2h0Nm95OTNKSDZ2WGJyYVNvUlVNdmNaNXpibHFpZXdLWXF0UzliVWlmaHpOeDNzRVd4Sk5ibHhPWm1KUUxTLTYzTjZWblhoSGtrRE5QY9IB3AFBVV95cUxObjJDYmJRSkRxQXg0N1N1UlBsX0JES29ydnVUcmRhQTF3TXo0anpKQWNud1dWMFpqYVE1azhKMUR4enVNVXQ4RWJiRlUwVHYzWjRkZ1F0Mk5hRHJ0ODBvaFVINjFrME1KTXN1QXpaNkRhVTRzY19WbC1sSEljTnZRRGd1WnMxc1pOTVRKMW9LMHZCQURNeXZzR1pxSnU4RjFEdnd6RGZ2YVlmc012aE1qRkk1Q05lcmEtZG1VNm1wZTBxOWd4Tms5SmJKUkEzcHROUnB1NTdsb0xlOUlT?oc=5','e9837eba8d245cc4d1f83b061faa6c7d74172433','La Inteligencia Artificial ya puede clonar tu voz en segundos con sólo un audio','La Inteligencia Artificial ya puede clonar tu voz en segundos con sólo un audio  Diario El Cordillerano',NULL,'Google News/Diario El Cordillerano',0.7,'es',NULL,'2026-09-16T15:58:28+00:00','2026-09-16T19:40:45+00:00',223,46.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(224,'tech','https://techcrunch.com/2026/09/16/x-will-now-let-u-s-users-trade-via-cashtags/','841cb7a57ec0140034445ab4d0a5a8daf86e8b32','X will now let U.S. users trade via cashtags','The move closes the gap between the market discussions taking place on the timeline, and the market itself.',NULL,'TechCrunch',0.9,'en',NULL,'2026-09-16T19:57:22+00:00','2026-09-16T19:58:44+00:00',224,56.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(225,'tech','https://news.google.com/rss/articles/CBMi-AFBVV95cUxNWmk5REMwUXZBWjZaaFNBWW1ReVZHc1NxRGdaSlJySG5qbjlIc0dQWGVSQVUyQTdOUnZrQzZQWTZsaFozYUJGU1h0WTQwdzNsQUc0T04ySktvYkFHN1NVTlN2X0pWWE51eXdTX3pEZHhyR3daZEhwbjYzZ2I4ZEdkWVNacUw2bEZGay1veC1iSEVjYV90emN5dXBlcEpONi1UUTdlOHNfTUo5bTlyeDJuTVBDVDhBSkRscGotSmlYdTg0VXVQU1J4ZmU5WjlfWEhHUmRUNVlYRW1iUGVKMGNPb0czUTBEMFZoZlJBS19jeDVwUWNFNjJzTNIBkwJBVV95cUxOWTM4dGlaSEpKSDItS1NuZWw3elhiUDFFOUpicjlmbk82eGVOcEEtS1RTY0I5QnFtbWctRm1pc3dseTNKb2VaeU4zdVAyZXNGdVpBem8ycEZpLTNUZWFFZk9oYmVCMjkxbEpMVU1heWdFUERoalRrMmMtWGw3YnhXaDZIR1RtREYwc2hOQnNCc3pTUFR2WkV4YlRFTjBudEM4dkRSWWlseEc3MDZ6Mld1SmRJcVJQNGxKQXRhVElidHVYUkgxakN4Rmh0UDBtakFRUEk4WWJvSlF4d1BHQ0pXZ3ZlTjk0Rlo0b3h3dU10b3IxSWI3d1RZZDE5R2hjSl9YSkRibEN2SWp3aGNuZG9jRHhWZw?oc=5','892d1dd91eca70e60fe2c5e0ab130267951b9db6','Cómo fue el encuentro que propuso usar IA para anticipar crecidas, detectar incendios y mejorar el transporte en el Delta','Cómo fue el encuentro que propuso usar IA para anticipar crecidas, detectar incendios y mejorar el transporte en el Delta  Infobae',NULL,'Google News/Infobae',0.7,'es',NULL,'2026-09-16T19:41:20+00:00','2026-09-16T19:58:50+00:00',225,47.9,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(226,'tech','https://news.google.com/rss/articles/CBMi3gFBVV95cUxNZU5mdnJjQjNzVUpsQUFYa0Zpd2VkZjFaLXRrSnBPaVpzUXNWckRPZzcwMGhVUWQ3eHhYQlVTSHJHMFdaSnNYbVBtZVUzaE8ya091a0hlZjBJR0k2dkpCTW5JRW1JeDNqalRaM2hGMVdlTzdIS3FXY1RVZTE3d1Bqd2dQdlZOaFM5LV9wX2NwbG1LLWYyNE1hbFFta1hobjhGYmg5UEdrajdFancwUElfdTFqOHFPVUJZTThPSjNGcHhjZUl6ejliNFA1RzlmUWdqMmxfcDlLVHdkM1B3THc?oc=5','5831b7376efe7bbb0e6c79256dcdf4b797df8e51','Mark Zuckerberg rechaza los llamados a frenar el desarrollo en todo el sector de la inteligencia artificial -','Mark Zuckerberg rechaza los llamados a frenar el desarrollo en todo el sector de la inteligencia artificial  - AJN Agencia de Noticias',NULL,'Google News/AJN Agencia de Noticias',0.7,'es',NULL,'2026-09-16T16:21:35+00:00','2026-09-16T19:58:50+00:00',213,NULL,NULL);
INSERT INTO "stories" VALUES(227,'tech','https://news.google.com/rss/articles/CBMiW0FVX3lxTFBCaHJhSFAySWluMl9mdF9fdzZsQ3NibjNVVTlSdnhCZk1qVjE2Q1EtTnoweXc3bDJoZFVGNkNTckVtMVF3bUhHLUFSNlc5YW5SQ3RKTU5tTnNIYWvSAWBBVV95cUxOcmY3Q1R2aGYxSXMtUkh6S25idEx3R1FWYThCLUdicEJJSE0yMGM0NDdralplWS1oOFh2S2VpY1NiMy1pZjRwTWJyQnplbWJ3azE0RVdBUHJRZVNqbVQ3TUU?oc=5','b22c72b9e09607ccb714589188d3a797aff0fcd9','El alarmante llamado de Dario Amodei, el director de Anthropic, para ralentizar el desarrollo de la inteligencia artificial','El alarmante llamado de Dario Amodei, el director de Anthropic, para ralentizar el desarrollo de la inteligencia artificial  BBC',NULL,'Google News/BBC',0.7,'es',NULL,'2026-09-13T08:21:04+00:00','2026-09-16T19:58:50+00:00',227,28.0,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(228,'tech','https://news.google.com/rss/articles/CBMihAFBVV95cUxOQWVyaTFqeWlzT0pIUEo5TGF4bkYyRDNUX3k2a21hRk1EQ1JsZmNUc2pPZFcyWFRMSU5memtseGNMRDR1Q0VCU3Z3ZlAyS3MwTkIwaE83b3c1RHJQUlFhaEhOMXNtMkxNRnA5Y1hzUjNpNE80VHBQSUtqa0lSckdYcmhzbmbSAZgBQVVfeXFMTnJCbG1tVG9hZ2lwdHdlVElOdG9oX0R2RXN0MUlQZUdPOE9IRTJnUGJ6Y0lJVjVKTG14UDBuVmlpbGYyVkVYQV9QdHdJb1ZqZlJ3TkkyWWRnSVdZZnRwZVRoQzBEMk44YUFUSEpLZk5RWGg3UlhzcE1ZaFRHN3V0aTl6TjhLYnBNbDNzZHZrME0tdDlsMUhNZHg?oc=5','9aa72deb8f9461d45c5a22b2747bd4303299c2b8','La IA por el camino del cambio climático','La IA por el camino del cambio climático  eldoce',NULL,'Google News/eldoce',0.7,'es',NULL,'2026-09-16T19:33:45+00:00','2026-09-16T19:58:50+00:00',228,47.8,'{"fallback": true, "risk": 20}');
INSERT INTO "stories" VALUES(229,'tech','https://news.google.com/rss/articles/CBMikwFBVV95cUxOdGJkRUFQWDNjQnZ6TWEwdmlmT0hFWk1YeVlBTVZ6TWI4RUt5Y0d0Y0NtRDBKSVFLRk4zZzhjMzg0TTd1dkdyT0pObmNjZEtHcElseFRJVDRKNzZVQzM3QUdlb0NnaHRlZ1dsZ3VaYlZkLXpLX1pyS2FoVEhzb2plWVVEek9tMnhtUGczR0RFQUtwMFk?oc=5','36225de30ba050cd5593a613715b79a59b99f90c','"Estamos perdiendo el control" de la IA, dice a la AFP el pionero Yoshua Bengio','"Estamos perdiendo el control" de la IA, dice a la AFP el pionero Yoshua Bengio  Yahoo Finanzas',NULL,'Google News/Yahoo Finanzas',0.7,'es',NULL,'2026-09-16T18:33:32+00:00','2026-09-16T19:58:50+00:00',229,47.3,'{"fallback": true, "risk": 20}');
CREATE INDEX ix_stories_recent  ON stories (vertical, fetched_at);
CREATE INDEX ix_stories_cluster ON stories (vertical, cluster_id);
CREATE INDEX ix_outputs_day ON outputs (vertical, date, qa_status);
CREATE INDEX ix_publish_day ON publish_log (vertical, date, status);
COMMIT;
