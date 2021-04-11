# zadanie4-po14-balazia-z4-hrnciar-vidiecan
zadanie4-po14-balazia-z4-hrnciar-vidiecan created by GitHub Classroom

# SQL Model

**users:**

```sql
id serial PRIMARY KEY,
username VARCHAR(45) NOT NULL,
password VARCHAR(45) NOT NULL,
email_address VARCHAR(200) NOT NULL,
last_login TIMESTAMP NOT NULL,
facebook_token VARCHAR(45),
google_token VARCHAR(45),
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
level INT NOT NULL,
exp INT NOT NULL,
balance INT NOT NULL,
location_x INT NOT NULL,
location_y INT NOT NULL,
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
deleted_at TIMESTAMP
```

Jeden záznam v tabuľke **characters** predstavuje jednu postavu používateľa. Používateľ môže vlastniť viacero postáv a komu patrí sa identifikuje pomocou user_id. Každá postava má nejakú rolu z tabuľky **roles**, ktorá ovplyvňuje počiatočné atribúty postavy a jej schopnosti, taktiež aj ich zmenu pri získaní nového levelu. Postava sa nachádza na mape, pričom sa nachádza na určitých koordinátoch (location_x, location_y, location_z). Poloha postavy sa neupdatuje stále, pretože by to príliš zaťažovalo databázu, namiesto toho by sa poloha ukladala do cache a v pravidelných intervaloch tabuľku updatovala. Balance predstavuje obnos peňazí, ktoré postava vlastní. Exp predstavuje získané body skúseností, ktoré sú potrebné na dosiahnutie ďalších levelov. 


**roles**

```sql
id serial PRIMARY KEY,
name VARCHAR(45) NOT NULL,
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
role_id INT NOT NULL FOREIGN KEY(roles),
requirement_id LTREE NOT NULL FOREIGN KEY(role_abilities),
name VARCHAR(45) NOT NULL,
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
userA_id INT NOT NULL FOREIGN KEY(users),
userB_id INT NOT NULL FOREIGN KEY(users),
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
name VARCHAR(45) NOT NULL,
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
name VARCHAR(45) NOT NULL,
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
team_id INT FOREIGN KEY(teams_info) NOT NULL,
character_id INT FOREIGN KEY(users) NOT NULL,
character_role INT FOREIGN KEY(teams_roles) NOT NULL,
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
deleted_at TIMESTAMP
```

Tabuľka **teams** predstavuje príslušnosť používateľa do konkrétneho tímu. V rámci tímu môže mať používateľ rolu z tabuľky teams_roles, ktorá definuje právomoci v tíme. V tabuľke **teams_info** sú uložené informácie o konkrétnom tíme, ako sú jeho meno, spoločné financie a maximálny počet hráčov v tíme.


**map**

```sql
id serial PRIMARY KEY,
name VARCHAR(45) NOT NULL,
description TEXT(500) NOT NULL,
min_level INT NOT NULL,
requirement_moster INT FOREIGN KEY(combat_log),
requirement_moster INT FOREIGN KEY(history_log),
location INT[][] NOT NULL FOREIGN KEY(terrain),
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
deleted_at TIMESTAMP
```

Každý záznam tabuľky predstavuje dvojrozmernú maticu mapy, jej názov a popis spolu s minimálnym levelom, ktorý musí postava mať, aby mohla danú mapu navštíviť. Taktiež sa môže dopytovať combat_logu a history_logu, či bola splnená podmienka vstupu na ďalšiu mapu: či bola zabitá konkrétna príšera alebo bola splnená úloha. Každé políčko v matici predstavuje id terénu, ktorý je uložený v tabuľke **terrain**, či ide o trávu, strom, budovu a pod.


**chat:**

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

```sql
UPDATE chat SET log = jsonb_set(
  log::jsonb,
  array['log'],
  (log->'log')::jsonb || '{"timestamp": "2021-04-07 23:06:21+00.00", 
  "from": "playerA", 
  "content": "New message"}'::jsonb)
WHERE id = 1;
```

