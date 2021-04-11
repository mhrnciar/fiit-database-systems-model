# zadanie4-po14-balazia-z4-hrnciar-vidiecan
zadanie4-po14-balazia-z4-hrnciar-vidiecan created by GitHub Classroom

# SQL Model

**users:**

```sql
id serial PRIMARY KEY,
username VARCHAR(45) UNIQUE NOT NULL,
password VARCHAR(45) NOT NULL,
email_address VARCHAR(200) UNIQUE NOT NULL,
last_login TIMESTAMP NOT NULL,
facebook_token VARCHAR(45) UNIQUE,
google_token VARCHAR(45) UNIQUE,
is_online BOOLEAN NOT NULL,
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
deleted_at TIMESTAMP
```
Používateľ sa môže zaregistrovať pomocou emailovej adresy a hesla alebo využiť možnosť prihlásenia pomocou Facebookového alebo Google účtu, ktorý prostredníctvom ich prihlasovacieho API vráti autentifikačný token používateľa, z ktorého sa dajú získať údaje o používateľovi. is_online informuje ostatných hráčov, či je alebo nie je daný používateľ v hre.

**characters**

```sql
id serial PRIMARY KEY,
name VARCHAR(45) NOT NULL,
role_id INT NOT NULL FOREIGN KEY (roles),
user_id INT NOT NULL FOREIGN KEY (users),
location_id INT NOT NULL FOREIGN KEY (map),
hp INT NOT NULL,
mp INT NOT NULL,
speed INT NOT NULL,
armor INT NOT NULL,
attack INT NOT NULL,
level INT NOT NULL FOREIGN KEY (levels),
exp INT NOT NULL,
balance INT NOT NULL,
location_x INT NOT NULL,
location_y INT NOT NULL,
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
deleted_at TIMESTAMP
```

Jeden záznam v tabuľke **characters** predstavuje jednu postavu používateľa. Používateľ môže vlastniť viacero postáv a komu patrí sa identifikuje pomocou user_id. Každá postava má nejakú rolu z tabuľky **roles**, ktorá ovplyvňuje počiatočné atribúty postavy a jej schopnosti, taktiež aj ich zmenu pri získaní nového levelu. Postava sa nachádza na mape, pričom sa nachádza na určitých koordinátoch (location_x, location_y, location_z). Poloha postavy sa neupdatuje stále, pretože by to príliš zaťažovalo databázu, namiesto toho by sa poloha ukladala do cache a v pravidelných intervaloch tabuľku updatovala. Balance predstavuje obnos peňazí, ktoré postava vlastní. Exp predstavuje získané body skúseností, ktoré sú potrebné na dosiahnutie ďalších levelov. 

**items**

```sql
id serial PRIMARY KEY,
name VARCHAR(45) NOT NULL,
description TEXT(500) NOT NULL,
value INT NOT NULL,
hp_modifier INT,
mp_modifier INT,
speed_modifier INT,
armor_modifier INT,
attack_modifier INT,
level_min INT NOT NULL,
location_x INT NOT NULL,
location_y INT NOT NULL,
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
deleted_at TIMESTAMP
```

V tabuľke **items** sa nachádzajú predmety, ktoré môžu byť využiteľné v hre. Každý predmet má svoju cenu a taktiež sa môže nachádzať na mape na určitých koorinátoch. Každý predmet pridáva alebo odoberá atribúty hráčovi, ktorý predmet využíva a tieto hodnoty sú tvorené náhodne. Taktiež na to, aby hráč mohol predmet využívať, musí mať dostatočný level postavy.

**inventory**

```sql
id serial PRIMARY KEY,
character_id INT NOT NULL FOREIGN KEY (characters),
item_id INT NOT NULL FOREIGN KEY (items),
count INT NOT NULL,
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
deleted_at TIMESTAMP
```

Tabuľka **inventory** obsahuje záznamy o všetkých predmetoch, ktoré hráč vlastní a taktiež aj počte konkrétneho predmetu.


**roles**

```sql
id serial PRIMARY KEY,
name VARCHAR(45) UNIQUE NOT NULL,
hp_base INT NOT NULL,
mp_base INT NOT NULL,
speed_base INT NOT NULL,
armor_base INT NOT NULL,
attack_base INT NOT NULL,
hp_modifier INT,
mp_modifier INT,
speed_modifier INT,
armor_modifier INT,
attack_modifier INT,
created_at TIMESTAMP,
updated_at TIMESTAMP,
deleted_at TIMESTAMP
```

Tabuľka **roles** predstavuje herné roly, ktoré si môže používateľ vybrať pre svoju postavu. Base atribúty predstavujú základné atribúty postáv s danou rolou a modifier atribúty určujú, o koľko sa zvýši atribút pri dosiahnutí ďalšieho levelu, pričom pri niektorých rolách sa konkrétne atribúty nemusia meniť vôbec.


**role_abilities**

```sql
id serial PRIMARY KEY,
role_id INT NOT NULL FOREIGN KEY (roles),
requirement_id LTREE NOT NULL FOREIGN KEY (role_abilities),
name VARCHAR(45) UNIQUE NOT NULL,
description TEXT(500) NOT NULL,
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
deleted_at TIMESTAMP
```

Pomocou LTREE vznikne stromová štruktúra schopností danej role.
Do requirement_id sa vloží buď 'root' alebo 'root[.id]*' podľa toho, ako hlboko v strome sa daná schopnosť nachádza.
Query je možné spraviť ako `SELECT * FROM role_abilities WHERE requirement_id <@ 'root.1’;` ak chcem vypísať potomkov schopnosti s id = 1.
Predtým je potrebné vytvoriť extension pomocou `CREATE EXTENSION ltree` a vytvoriť index pomocou `CREATE INDEX role_abilities_index ON role_abilities USING GIST (requirement_id);`


**relationships**

```sql
id serial PRIMARY KEY,
userA_id INT NOT NULL FOREIGN KEY (users),
userB_id INT NOT NULL FOREIGN KEY (users),
friend BOOLEAN,
ignored BOOLEAN,
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
deleted_at TIMESTAMP
```

Tabuľka **relationships** predstavuje vzťahy medzi používateľmi, taktiež definuje stav, či sú priatelia alebo či si používateľ A pridal používateľa B do ignore listu. Vo vzťahu nemôže byť nastavené friend aj ignore na true naraz. Ak sú používatelia priatelia, tak si môžu vidieť meno, rolu a level, ktorý vidia pomocou nasledovného view:

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
max_members INT NOT NULL,
team_balance BIGINT NOT NULL,
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
deleted_at TIMESTAMP
```

**teams_roles**

```sql
id serial PRIMARY KEY,
name VARCHAR(45) UNIQUE NOT NULL,
description TEXT(500),
modify_members BOOLEAN,
modify_info BOOLEAN,
use_balance BOOLEAN,
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

Tabuľka **teams** predstavuje príslušnosť používateľa do konkrétneho tímu. V rámci tímu môže mať používateľ rolu z tabuľky teams_roles, ktorá definuje právomoci v tíme: modify_members definuje či môže modifikovať ostatných členov tímu, pridať nových hráčov alebo ich vyhodiť z tímu a zmeniť ich rolu, modify_info definuje čimôže meniť meno alebo popis tímu a use_balance určuje či môže hráč manipulovať so zdieľanými financiami tímu. V tabuľke **teams_info** sú uložené informácie o konkrétnom tíme, ako sú jeho meno, spoločné financie a maximálny počet hráčov v tíme.


**map**

```sql
id serial PRIMARY KEY,
name VARCHAR(45) UNIQUE NOT NULL,
description TEXT(500) NOT NULL,
min_level INT NOT NULL,
requirement_moster INT FOREIGN KEY (combat_log),
requirement_moster INT FOREIGN KEY (history_log),
location INT[][] NOT NULL FOREIGN KEY (terrain),
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
deleted_at TIMESTAMP
```

Každý záznam tabuľky predstavuje dvojrozmernú maticu mapy, jej názov a popis spolu s minimálnym levelom, ktorý musí postava mať, aby mohla danú mapu navštíviť. Taktiež sa môže dopytovať combat_logu a history_logu, či bola splnená podmienka vstupu na ďalšiu mapu: či bola zabitá konkrétna príšera alebo bola splnená úloha. Každé políčko v matici predstavuje id terénu, ktorý je uložený v tabuľke **terrain**, či ide o trávu, strom, budovu a pod.

**terrain**

```sql
id serial PRIMARY KEY,
name VARCHAR(45) UNIQUE NOT NULL,
description TEXT(500),
img BLOB NOT NULL,
properties JSON NOT NULL,
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
deleted_at TIMESTAMP
```

**terrain** predstavuje úložisko pre všetky terény a nehybné objekty, ktoré sa môžu v hre vyskytnúť. Každý terén má svoje vlastnosti, napríklad rýchlosť pohybu (cez močiar sa postava pohybuje pomalšie ako po ceste) zapísané vo formáte JSON a obrázok terénu je uložený ako veľký binárny objekt (BLOB).

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

Tabuľka **npcs** predstavuje počítačom ovládanú entitu, ktorá bude hráčom prideľovať questy a za ne itemy. Jednotlivé npcs sa nadzádzajú na mape (location_id) a na určitých koordinátoch mapy.

**monsters**

```sql
id serial PRIMARY KEY,
type_id INT NOT NULL FOREIGN KEY (monster_type),
hp INT NOT NULL,
mp INT NOT NULL,
speed INT NOT NULL,
armor INT NOT NULL,
attack INT NOT NULL,
level INT NOT NULL FOREIGN KEY (levels),
exp INT NOT NULL,
balance INT NOT NULL,
location_id INT NOT NULL FOREIGN KEY (map),
location_x INT NOT NULL,
location_y INT NOT NULL,
requirement_monster INT FOREIGN KEY (combat_log),
requirement_quest INT FOREIGN KEY (history_log),
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
deleted_at TIMESTAMP
```

Tabuľka **monsters** predstavuje nepriateľské entity, s ktorými musí hráč bojovať. Každé monštrum má svoje vlastné atribúty (život, mágia, rýchlosť, brnenie, útok) a level, pomocou ktorého je možné určiť či daná príšera spadá do rozmedzia levelov, ktoré môže postava poraziť a podľa toho sa buď objaví alebo nie. Ak hráč zabije monštrum, dostane ako odmenu body skúseností a peniaze. Každé monštrum sa nachádza na mape (location_id) a má svoje koordináty. Niektoré postavy sa objavia iba ak bola zabitá predošlá príšera alebo bol ukončený nejaký quest, čo sa dá zistiť z combat alebo history logu.

**monster_types**

```sql
id serial PRIMARY KEY,
name VARCHAR(45) UNIQUE NOT NULL,
description TEXT(500) NOT NULL,
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
deleted_at TIMESTAMP
```

Tabuľka **monster_types** definuje rôzne typy monštier, ktoré sa môžu v hre nachádzať.

**loot**

```sql
id serial PRIMARY KEY,
item_id INT NOT NULL FOREIGN KEY (items),
monster_id INT NOT NULL FOREIGN KEY (monsters),
count INT NOT NULL,
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
deleted_at TIMESTAMP
```

Každá postava okrem bodov skúseností a peňazí môže dať postave ďalšiu odmenu v podobe jedného alebo viacerých predmetov. Tieto odmeny sú zapísané v tabuľke **loot**.

**levels**

```sql
id serial PRIMARY KEY,
exp_needed INT NOT NULL,
hp_modifier INT,
mp_modifier INT,
speed_modifier INT,
armor_modifier INT,
attack_modifier INT,
created_at TIMESTAMP,
updated_at TIMESTAMP,
deleted_at TIMESTAMP
```

Id tabuľky **levels** predstavuje číslo levelu spolu s počtom bodov skúseností, ktoré musí hráč získať aby daný level dosiahol. Modifikátory určujú ktoré a o koľko sa zvýšia atribúty postavy. Tieto modifikátory predstavujú základ pre každú postavu v hre a modifikátory v tabuľke **roles** zas určujú ktoré atribúty sa navyše zvýšia pre posatvu danej roly.

**quests**

```sql
id serial PRIMARY KEY,
name VARCHAR(45) NOT NULL,
description TEXT(500) NOT NULL,
min_level INT,
exp INT NOT NULL,
balance INT NOT NULL,
reward_id INT NOT NULL FOREIGN KEY (items),
npc_id INT FOREIGN KEY (npcs),
location_id INT NOT NULL FOREIGN KEY (map),
location_x INT,
location_y INT,
created_at TIMESTAMP,
updated_at TIMESTAMP,
deleted_at TIMESTAMP
```

V tabuľke **quests** sú zapísané všetky úlohy, na ktoré môže postava naraziť. Za dokončenie úlohy postava dostane body skúseností, peniaze a nejaký predmet. Úlohy sa môžu vyskytovať voľne vo svete alebo ich môže dať nejaké NPC.

**chat**

```sql
id serial PRIMARY KEY,
team_id INT FOREIGN KEY (teams),
relationship_id INT NOT NULL FOREIGN KEY (relationships),
log JSON NOT NULL,
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
deleted_at TIMESTAMP
```

Chat medzi dvoma hráčmi alebo v rámci tímu sa ukladá v tabuľke **chat**, pričom ak medzi danými hráčmi je záznam v **relationships** nastavený na ignored, nie je možné si písať. Log komunikácie predstavuje JSON súbor, v ktorom sú uložené aj informácie o účastníkoch komunikácie v nasledovnom tvare:

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
			"timestamp": "2021-04-07 22:28:11+00:00",
			"from": "playerA",
			"content": "Hey man! How you doing?"
		},
		{
			"timestamp": "2021-04-07 22:28:17+00:00",
			"from": "playerB",
			"content": "I'm good! How about u?"
		},
	]
}
```

Do JSON súboru je možné pridávať správy pomocou nasledovnej query:

```sql
UPDATE chat SET log = jsonb_set(
  log::jsonb,
  array['log'],
  (log->'log')::jsonb || '{"timestamp": "2021-04-07 23:06:21+00.00", 
  "from": "playerA", 
  "content": "New message"}'::jsonb)
WHERE id = 1;
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
