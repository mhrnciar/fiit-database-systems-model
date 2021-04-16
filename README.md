# zadanie4-po14-balazia-z4-hrnciar-vidiecan
zadanie4-po14-balazia-z4-hrnciar-vidiecan created by GitHub Classroom

# SQL Model

**users:**

```sql
id serial PRIMARY KEY,
username VARCHAR(45) UNIQUE NOT NULL,
password VARCHAR(45) NOT NULL CHECK (length(users.password) >= 8),
email_address VARCHAR(200) UNIQUE NOT NULL,
last_login TIMESTAMP NOT NULL,
facebook_token VARCHAR(45) UNIQUE,
google_token VARCHAR(45) UNIQUE,
is_online BOOLEAN NOT NULL,
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
deleted_at TIMESTAMP,
CONSTRAINT token_check CHECK ((users.facebook_token IS NOT NULL AND users.google_token IS NULL)
                                      OR (users.google_token IS NOT NULL AND users.facebook_token IS NULL)
                                      OR (users.google_token IS NULL AND users.facebook_token IS NULL))
```
Používateľ sa môže zaregistrovať pomocou emailovej adresy a hesla (minimálne 8 znakov) alebo využiť možnosť prihlásenia pomocou Facebookového alebo Google účtu, ktorý prostredníctvom ich prihlasovacieho API vráti autentifikačný token používateľa, z ktorého sa dajú získať údaje o používateľovi. Používateľ sa nemôže naraz prihlasovať cez Facebook aj Google, čo ošetruje check constraint. is_online informuje ostatných hráčov, či je alebo nie je daný používateľ v hre a last_login ukladá timestamp posledného prihlásenia.

**characters**

```sql
id SERIAL PRIMARY KEY,
name VARCHAR(45) NOT NULL,
role_id INT NOT NULL FOREIGN KEY (roles),
user_id INT NOT NULL FOREIGN KEY (users),
hp INT NOT NULL CHECK (characters.hp > 0),
mp INT NOT NULL CHECK (characters.mp >= 0),
speed INT NOT NULL CHECK (characters.speed > 0),
armor INT NOT NULL CHECK (characters.armor > 0),
attack INT NOT NULL CHECK (characters.attack > 0),
level INT NOT NULL DEFAULT 1 FOREIGN KEY (levels) CHECK (characters.level >= 1),
exp INT NOT NULL DEFAULT 0 CHECK (characters.exp >= 0),
balance INT NOT NULL DEFAULT 0 CHECK (characters.balance >= 0),
location_id INT NOT NULL FOREIGN KEY (map),
location_x INT NOT NULL,
location_y INT NOT NULL,
abilities JSONB NOT NULL,
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
deleted_at TIMESTAMP
```

Jeden záznam v tabuľke **characters** predstavuje jednu postavu používateľa. Používateľ môže vlastniť viacero postáv a komu patrí sa identifikuje pomocou user_id. Každá postava má nejakú rolu z tabuľky **roles**, ktorá ovplyvňuje počiatočné atribúty postavy a jej schopnosti a ich zmeny pri získaní nového levelu. Postava sa nachádza na mape (location_id), pričom sa nachádza na určitých koordinátoch (location_x, location_y). Poloha postavy sa neupdatuje stále, pretože by to príliš zaťažovalo databázu, namiesto toho by sa poloha ukladala do cache a v pravidelných intervaloch tabuľku updatovala. Balance predstavuje obnos peňazí, ktoré postava vlastní. Exp predstavuje získané body skúseností, ktoré sú potrebné na dosiahnutie ďalších levelov a vždy po dosiahnutí nového levelu sa body skúseností vynulujú, resp. odčíta sa počet potrebný na postup do ďalšieho levelu.

**items**

```sql
id serial PRIMARY KEY,
name VARCHAR(45) NOT NULL,
description TEXT(500) NOT NULL,
value INT NOT NULL CHECK (items.value > 0),
hp_modifier INT (items.hp_modifier >= 0),
mp_modifier INT (items.mp_modifier >= 0),
speed_modifier INT (items.speed_modifier >= 0),
armor_modifier INT (items.armor_modifier >= 0),
attack_modifier INT (items.attack_modifier >= 0),
level_min INT NOT NULL (items.level_min > 0),
location_x INT NOT NULL,
location_y INT NOT NULL,
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
deleted_at TIMESTAMP,
CONSTRAINT location_check CHECK ((items.location_id IS NOT NULL AND items.location_x IS NOT NULL AND items.location_y IS NOT NULL)
                                      OR (items.location_id IS NULL AND items.location_x IS NULL AND items.location_y IS NULL))
```

V tabuľke **items** sa nachádzajú predmety, ktoré môžu byť využiteľné v hre. Každý predmet má svoju cenu a taktiež sa môže nachádzať na mape na určitých koordinátoch. Niektoré predmety, ako meče, štíty, brnenie a pod. môžu zvyšovať jeden alebo aj všetky atribúty hráčovi, ktorý daný predmet využíva. Taktiež na to, aby hráč mohol predmet využívať, musí mať dostatočný level postavy. Check kontroluje, že ak sa predmet nachádza na mape, musí mať určené presné miesto kde, ináč sa nedá vložiť. Taktiež ak je zadaná poloha, ale nie konkrétna mapa, vkladanie zlyhá.

**inventory**

```sql
id serial PRIMARY KEY,
character_id INT NOT NULL FOREIGN KEY (characters),
item_id INT NOT NULL FOREIGN KEY (items),
count INT NOT NULL CHECK (inventory.count > 0),
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
deleted_at TIMESTAMP
```

Tabuľka **inventory** obsahuje záznamy o všetkých predmetoch, ktoré hráč vlastní a taktiež aj počte konkrétneho predmetu. Ak hráč nejaký predmet vlastní, nemôže byť počet tých predmetov 0.


**roles**

```sql
id serial PRIMARY KEY,
name VARCHAR(45) UNIQUE NOT NULL,
hp_base INT NOT NULL CHECK (roles.hp_base > 0),
mp_base INT NOT NULL CHECK (roles.mp_base >= 0),
speed_base INT NOT NULL CHECK (roles.speed_base > 0),
armor_base INT NOT NULL CHECK (roles.armor_base > 0),
attack_base INT NOT NULL CHECK (roles.attack_base > 0),
hp_modifier INT CHECK (roles.hp_modifier >= 0),
mp_modifier INT CHECK (roles.mp_modifier >= 0),
speed_modifier INT CHECK (roles.speed_modifier >= 0),
armor_modifier INT CHECK (roles.armor_modifier >= 0),
attack_modifier INT CHECK (roles.attack_modifier >= 0),
created_at TIMESTAMP,
updated_at TIMESTAMP,
deleted_at TIMESTAMP
```

Tabuľka **roles** predstavuje herné roly, ktoré si môže používateľ vybrať pre svoju postavu. Base atribúty predstavujú základné atribúty postáv s danou rolou a modifier atribúty určujú, o koľko sa zvýši atribút pri dosiahnutí ďalšieho levelu, pričom pri niektorých rolách sa konkrétne atribúty nemusia meniť vôbec (bojovník nepotrebuje mágiu, takže sa mu nebude zvyšovať mp).


**role_abilities**

```sql
id serial PRIMARY KEY,
role_id INT NOT NULL FOREIGN KEY (roles),
requirement_id LTREE NOT NULL,
name VARCHAR(45) UNIQUE NOT NULL,
description TEXT(500) NOT NULL,
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
deleted_at TIMESTAMP
```

Schopnosti pre role môžu tvoriť stromovú štruktúru, ktorú je možné dosiahnúť pomocou LTREE.
Do requirement_id sa vloží buď 'root' ak ide o prvú schopnosť v strome alebo 'root[.id]*' podľa toho, ako hlboko v strome sa daná schopnosť nachádza.
Query je možné spraviť ako `SELECT * FROM role_abilities WHERE requirement_id <@ 'root.1’;` ak chcem vypísať potomkov schopnosti s id = 1.
Predtým je potrebné vytvoriť extension pomocou `CREATE EXTENSION ltree` a vytvoriť index pomocou `CREATE INDEX role_abilities_index ON role_abilities USING GIST (requirement_id);`


**relationships**

```sql
id serial PRIMARY KEY,
userA_id INT NOT NULL FOREIGN KEY (users) CHECK (relationships.userA_id != relationships.userB_id),
userB_id INT NOT NULL FOREIGN KEY (users) CHECK (relationships.userB_id != relationships.userA_id),
friend BOOLEAN,
ignored BOOLEAN,
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
deleted_at TIMESTAMP,
CONSTRAINT friend_ignored_check CHECK ((friend IS true AND ignored IS false)
                                              OR (ignored IS true AND friend IS false))
```

Tabuľka **relationships** predstavuje vzťahy medzi používateľmi a definuje stav, či sú priatelia alebo či si používateľ A pridal používateľa B do ignore listu. Vo vzťahu nemôže byť nastavené friend aj ignore na true naraz a zároveň používateľ nemôže vytvoriť vzťah so samým sebou. Ak sú používatelia priatelia, tak si môžu vidieť meno, rolu a level, ktoré je možné získať pomocou nasledovného view:

```sql
CREATE VIEW friend_data AS
SELECT p.charname, p.rolename, p.level, f.user_id
FROM (SELECT c.id, c.name charname, r.name rolename, c.level
FROM characters c JOIN roles r on c.role_id = r.id) p
JOIN friends f ON p.id = f.friend_id;
```

**teams_info**

```sql
id serial PRIMARY KEY,
name VARCHAR(45) UNIQUE NOT NULL,
description TEXT(500),
max_members INT NOT NULL DEFAULT 20 CHECK (teams_info.max_members >= 1),
team_balance BIGINT NOT NULL DEFAULT 0 CHECK (teams_info.team_balance >= 0),
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
deleted_at TIMESTAMP
```

**teams_roles**

```sql
id serial PRIMARY KEY,
name VARCHAR(45) UNIQUE NOT NULL,
description TEXT(500),
modify_members BOOLEAN DEFAULT false,
modify_info BOOLEAN DEFAULT false,
use_balance BOOLEAN DEFAULT false,
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
deleted_at TIMESTAMP
```

**teams**

```sql
id serial PRIMARY KEY,
team_id INT NOT NULL FOREIGN KEY (teams_info),
character_id INT NOT NULL FOREIGN KEY (users),
character_role INT NOT NULL FOREIGN KEY (teams_roles),
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
deleted_at TIMESTAMP
```

Tabuľka **teams** predstavuje príslušnosť používateľa do konkrétneho tímu. V rámci tímu môže mať používateľ rolu z tabuľky teams_roles, ktorá definuje právomoci v tíme: _modify_members_ definuje či môže modifikovať ostatných členov tímu, pridať nových hráčov alebo ich vyhodiť z tímu a zmeniť ich rolu, _modify_info_ definuje či môže meniť meno alebo popis tímu a _use_balance_ určuje či môže hráč manipulovať so zdieľanými financiami tímu. V tabuľke **teams_info** sú uložené informácie o konkrétnom tíme, jeho meno, popis, spoločné financie a maximálny počet hráčov v tíme.


**map**

```sql
id serial PRIMARY KEY,
name VARCHAR(45) UNIQUE NOT NULL,
description TEXT(500) NOT NULL,
min_level INT NOT NULL DEFAULT 1 CHECK (map.min_level >= 1),
requirement_moster INT FOREIGN KEY (monster_types),
requirement_moster INT FOREIGN KEY (quests),
location INT[][] NOT NULL,
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
deleted_at TIMESTAMP
```

Každý záznam tabuľky predstavuje dvojrozmernú maticu mapy, jej názov a popis spolu s minimálnym levelom, ktorý musí postava mať, aby mohla danú mapu navštíviť. Taktiež sa môže dopytovať, či bola splnená podmienka vstupu na ďalšiu mapu: či bola zabitá konkrétna príšera alebo bola splnená úloha. Každé políčko v matici predstavuje id terénu, ktorý je uložený v tabuľke **terrain**, či ide o trávu, strom, budovu a pod. ale keďže pole nemôže referencovať jednotlivé id, nemôže sa vytvoriť prepojenie s cudzím kľúčom.

**terrain**

```sql
id serial PRIMARY KEY,
name VARCHAR(45) UNIQUE NOT NULL,
description TEXT(500),
img BYTEA NOT NULL,
properties JSONB NOT NULL,
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
deleted_at TIMESTAMP
```

**terrain** predstavuje úložisko pre všetky terény a nehybné objekty, ktoré sa môžu v hre vyskytnúť. Každý terén má svoje vlastnosti, napríklad rýchlosť pohybu (cez močiar sa postava pohybuje pomalšie ako po ceste) zapísané vo formáte JSON a obrázok terénu je uložený ako veľký binárny objekt (BYTEA).

**npcs**

```sql
id serial PRIMARY KEY,
name VARCHAR(45) UNIQUE NOT NULL,
location_id INT NOT NULL FOREIGN KEY (map),
location_x INT NOT NULL,
location_y INT NOT NULL,
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
deleted_at TIMESTAMP
```

Tabuľka **npcs** predstavuje počítačom ovládanú entitu, ktorá môže hráčom prideľovať úlohy a za ne odmeny. Jednotlivé npcs sa nadzádzajú na mape (location_id) a na určitých koordinátoch mapy.

**monsters**

```sql
id serial PRIMARY KEY,
type_id INT NOT NULL FOREIGN KEY (monster_type),
location_id INT NOT NULL FOREIGN KEY (map),
location_x INT NOT NULL,
location_y INT NOT NULL,
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
deleted_at TIMESTAMP
```

Tabuľka **monsters** predstavuje nepriateľské entity, s ktorými musí hráč bojovať. Každé monštrum má svoj typ a nachádza sa na mape (location_id) s konkrétnymi koordinátmi.

**monster_types**

```sql
id serial PRIMARY KEY,
name VARCHAR(45) UNIQUE NOT NULL,
description TEXT(500) NOT NULL,
hp INT NOT NULL CHECK (monster_types.hp > 0),
mp INT NOT NULL CHECK (monster_types.mp >= 0),
speed INT NOT NULL CHECK (monster_types.speed > 0),
armor INT NOT NULL CHECK (monster_types.armor > 0),
attack INT NOT NULL CHECK (monster_types.attack > 0),
level INT NOT NULL DEFAULT 1 FOREIGN KEY (levels) CHECK (monster_types.level > 0),
exp INT NOT NULL CHECK (monster_types.exp > 0),
balance INT NOT NULL CHECK (monster_types.balance >= 0),
requirement_monster INT FOREIGN KEY (monster_types),
requirement_quest INT FOREIGN KEY (quests),
item_id INT FOREIGN KEY (items),
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
deleted_at TIMESTAMP
```

Tabuľka **monster_types** definuje rôzne typy monštier, ktoré sa môžu v hre nachádzať. Každý typ monštra má svoje vlastné atribúty (život, mágia, rýchlosť, brnenie, útok) a level, pomocou ktorého je možné určiť či daná príšera spadá do rozmedzia levelov, ktoré môže postava poraziť a podľa toho sa buď objaví alebo nie. Ak hráč zabije monštrum, dostane ako odmenu body skúseností a peniaze. Každá príšera okrem bodov skúseností a peňazí môže dať postave ďalšiu odmenu v podobe jedného predmetu. Niektoré príšery sa objavia iba ak bola zabitá predošlá príšera alebo ak bola splnená nejaká úloha.


**levels**

```sql
id serial PRIMARY KEY,
exp_needed INT NOT NULL CHECK (levels.exp_needed >= 0),
hp_modifier INT CHECK (levels.hp_modifier > 0),
mp_modifier INT CHECK (levels.mp_modifier >= 0),
speed_modifier INT CHECK (levels.speed_modifier > 0),
armor_modifier INT CHECK (levels.armor_modifier > 0),
attack_modifier INT CHECK (levels.attack_modifier > 0),
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
deleted_at TIMESTAMP
```

Id tabuľky **levels** predstavuje číslo levelu spolu s počtom bodov skúseností, ktoré musí hráč získať aby daný level dosiahol. Modifikátory určujú ktoré a o koľko sa zvýšia atribúty postavy. Tieto modifikátory predstavujú základ pre každú postavu v hre a modifikátory v tabuľke **roles** zas určujú ktoré atribúty sa navyše zvýšia pre postavu danej role.

**quests**

```sql
id serial PRIMARY KEY,
name VARCHAR(45) NOT NULL,
description TEXT(500) NOT NULL,
min_level INT DEFAULT 1 CHECK (quests.min_level > 0),
exp INT NOT NULL CHECK (quests.exp > 0),
balance INT NOT NULL CHECK (quests.balance >= 0),
reward_id INT NOT NULL FOREIGN KEY (items),
npc_id INT FOREIGN KEY (npcs),
location_id INT NOT NULL FOREIGN KEY (map),
location_x INT NOT NULL,
location_y INT NOT NULL,
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
deleted_at TIMESTAMP,
CONSTRAINT location_check CHECK ((quests.npc_id IS NULL AND quests.location_id IS NOT NULL AND quests.location_x IS NOT NULL AND quests.location_y IS NOT NULL)
                                      OR (quests.npc_id IS NOT NULL AND quests.location_id IS NULL AND quests.location_x IS NULL AND quests.location_y IS NULL))
```

V tabuľke **quests** sú zapísané všetky úlohy, na ktoré môže postava naraziť. Za dokončenie úlohy postava dostane body skúseností, peniaze a nejaký predmet. Úlohy sa môžu vyskytovať voľne vo svete alebo ich môže dať nejaké NPC, na čo slúži aj check, ktorý kontroluje či sa úloha viaže na miesto vo svete (vtedy musí byť npc_id null) alebo na npc (vtedy sú location_id a koordináty nastavené na null).

**chat**

```sql
id serial PRIMARY KEY,
team_id INT FOREIGN KEY (teams),
relationship_id INT NOT NULL FOREIGN KEY (relationships),
log JSONB NOT NULL,
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
deleted_at TIMESTAMP,
CONSTRAINT chat_check CHECK ((chat.relationship_id IS NOT NULL AND chat.team_id IS NULL)
                                             OR (chat.team_id IS NOT NULL AND chat.relationship_id IS NULL))
```

Chat medzi dvoma hráčmi alebo v rámci tímu sa ukladá v tabuľke **chat**, pričom ak medzi danými hráčmi je záznam v **relationships** nastavený na ignored, nie je možné si písať, čo sa však rieši až na aplikačnej úrovni. Log komunikácie predstavuje JSON súbor, v ktorom sú uložené aj informácie o účastníkoch komunikácie v nasledovnom tvare:

```json
{
	"users": [
		{
			"id": 108383,
			"name": "playerA"
		},
		{
			"id": 145389,
			"name": "playerB"
		},
	],
	"log": [
		{
			"timestamp": "2021-04-07 22:28:11+00",
			"from": "playerA",
			"content": "Hey man! How you doing?"
		},
		{
			"timestamp": "2021-04-07 22:28:17+00",
			"from": "playerB",
			"content": "I'm good! How about u?"
		},
	]
}
```

Do JSON súboru je možné pridávať správy pomocou nasledovnej query:

```sql
UPDATE game.chat SET log = jsonb_set(
  log::jsonb,
  array['log'],
  (log->'log')::jsonb || '{"timestamp": "2021-04-07 23:06:21+00", 
  "from": "playerA", 
  "content": "New message"}'::jsonb)
WHERE id = <id chatu>;
```

**character_achievements**

```sql
id serial PRIMARY KEY,
character_id INT NOT NULL FOREIGN KEY (characters),
achievement_id INT NOT NULL FOREIGN KEY (achievements),
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
deleted_at TIMESTAMP
```

**achievements**

```sql
id serial PRIMARY KEY,
name VARCHAR(45) UNIQUE NOT NULL,
description TEXT(500) NOT NULL,
item_id INT FOREIGN KEY (items),
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
deleted_at TIMESTAMP
```

Tabuľka **achievements** popisuje všetky možné úspechy, ktoré môže postava získať. Niektoré úspechy môžu postave dať ako odmenu nejaký predmet. Všetky úspechy, ktoré postava získala sú zapísané v tabuľke **character_achievements**


**history_log**

```sql
id serial PRIMARY KEY,
character_id INT FOREIGN KEY(characters),
quest_id INT FOREIGN KEY(quests),
location_id FOREIGN KEY(map),
item_id INT FOREIGN KEY (items) CHECK (history_log.quest_id IS NULL),
location_x INT,
location_y INT,
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
deleted_at TIMESTAMP,
CONSTRAINT historylog_check CHECK ((history_log.quest_id IS NOT NULL AND history_log.item_id IS NULL)
                                           OR (history_log.item_id IS NOT NULL AND history_log.quest_id IS NULL))
```

Tabuľka **history_log** prezentuje záznamy, čo sa v hre udialo. Záznam sa viaže na postavu v hre a hovorí o splnení nejakej úlohy alebo o získaní predmetu. Záznam taktiež môže upresniť, v akej mape a na akých koordinátoch sa udalosť stala. Zo záznamov tejto tabuľky je možné vypočítavať počty vykonaných úloh alebo zozbieraných predmetov hráča, ktoré je možné použiť na získanie úspechu, rovnako aj zistiť či bola splnená úloha podmieňujúca postup na ďalšiu mapu alebo zobrazenie konkrétnej príšery.

**combat_log**

```sql
id serial PRIMARY KEY,
character_id INT FOREIGN KEY(characters),
enemy_character_id INT FOREIGN KEY(characters),
enemy_npc_id INT FOREIGN KEY(npcs),
team_id INT FOREIGN KEY(teams),
monster_id INT FOREIGN KEY(monsters),
log JSONB NOT NULL,
location_id FOREIGN KEY(map),
item_id INT FOREIGN KEY (items),
location_x INT,
location_y INT,
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
deleted_at TIMESTAMP,
CONSTRAINT combatlog_check CHECK ((combat_log.enemy_character_id IS NOT NULL AND combat_log.enemy_npc_id IS NULL AND combat_log.team_id IS NULL AND combat_log.monster_id IS NULL)
                                          OR (combat_log.enemy_character_id IS NULL AND combat_log.enemy_npc_id IS NOT NULL AND combat_log.team_id IS NULL AND combat_log.monster_id IS NULL)
                                          OR (combat_log.enemy_character_id IS NULL AND combat_log.enemy_npc_id IS NULL AND combat_log.team_id IS NOT NULL AND combat_log.monster_id IS NULL)
                                          OR (combat_log.enemy_character_id IS NULL AND combat_log.enemy_npc_id IS NULL AND combat_log.team_id IS NULL AND combat_log.monster_id IS NOT NULL))
```

Tabuľka **combat_log** obsahuje záznamy, ktoré sa viažu na každý boj v hre. Záznamy hovoria o tom, s akou entitou hry sa súboj vykonáva. Súboj sa môže vykonávať s ďalšou nepriateľkou postavou v hre alebo s nepriateľským npc, iným tímom alebo príšerou. Čo sa v súboji udialo, napr.(A zaútočil na B a znížil hp o 10, B zaútočil na A a znížil hp o 12 + jeho predmet poskytuje zníženie pohybu A o 10%), sa updatuje v stĺci log rovnakým spôsobom ako sa appenduje do chatu. Taktiež je prítomný záznam o tom, v akej časti mapy súboj nastal. Zo záznamov tejto tabuľky je možné vypočítavať počty vykonaných úloh alebo zozbieraných predmetov hráča, ktoré je možné použiť na získanie úspechu, rovnako aj zistiť či bola splnená úloha podmieňujúca postup na ďalšiu mapu alebo zobrazenie konkrétnej príšery.
