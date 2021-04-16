-- -----------------------------------------------------
-- Schema game
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS game CASCADE;
CREATE SCHEMA IF NOT EXISTS game;
CREATE EXTENSION IF NOT EXISTS ltree SCHEMA game;

-- -----------------------------------------------------
-- Table game.users
-- -----------------------------------------------------
DROP TABLE IF EXISTS game.users CASCADE;

CREATE TABLE IF NOT EXISTS game.users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(45) UNIQUE NOT NULL,
    password VARCHAR(45) NOT NULL CHECK (length(users.password) >= 8),
    last_login TIMESTAMP NOT NULL,
    facebook_token VARCHAR(100),
    google_token VARCHAR(100),
    is_online BOOLEAN NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP,
    CONSTRAINT token_check CHECK ((users.facebook_token IS NOT NULL AND users.google_token IS NULL)
                                      OR (users.google_token IS NOT NULL AND users.facebook_token IS NULL)
                                      OR (users.google_token IS NULL AND users.facebook_token IS NULL))
);


-- -----------------------------------------------------
-- Table game.roles
-- -----------------------------------------------------
DROP TABLE IF EXISTS game.roles CASCADE;

CREATE TABLE IF NOT EXISTS game.roles (
    id SERIAL PRIMARY KEY,
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
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP
);


-- -----------------------------------------------------
-- Table game.items
-- -----------------------------------------------------
DROP TABLE IF EXISTS game.items CASCADE;

CREATE TABLE IF NOT EXISTS game.items (
    id SERIAL PRIMARY KEY,
    name VARCHAR(45) UNIQUE NOT NULL,
    description TEXT NOT NULL,
    value INT NOT NULL CHECK (items.value > 0),
    hp_modifier INT CHECK (items.hp_modifier >= 0),
    mp_modifier INT CHECK (items.mp_modifier >= 0),
    speed_modifier INT CHECK (items.speed_modifier >= 0),
    armor_modifier INT CHECK (items.armor_modifier >= 0),
    attack_modifier INT CHECK (items.attack_modifier >= 0),
    level_min INT DEFAULT 1 CHECK (items.level_min > 0),
    location_id INT,
    location_x INT,
    location_y INT,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP,
    CONSTRAINT location_check CHECK ((items.location_id IS NOT NULL AND items.location_x IS NOT NULL AND items.location_y IS NOT NULL)
                                      OR (items.location_id IS NULL AND items.location_x IS NULL AND items.location_y IS NULL))
);


-- -----------------------------------------------------
-- Table game.npcs
-- -----------------------------------------------------
DROP TABLE IF EXISTS game.npcs CASCADE;

CREATE TABLE IF NOT EXISTS game.npcs (
    id SERIAL PRIMARY KEY,
    name VARCHAR(45) UNIQUE NOT NULL,
    location_id INT NOT NULL,
    location_x INT NOT NULL,
    location_y INT NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP
);


-- -----------------------------------------------------
-- Table game.quests
-- -----------------------------------------------------
DROP TABLE IF EXISTS game.quests CASCADE;

CREATE TABLE IF NOT EXISTS game.quests (
    id SERIAL PRIMARY KEY,
    name VARCHAR(250) UNIQUE NOT NULL,
    description TEXT NOT NULL,
    min_level INT DEFAULT 1 CHECK (quests.min_level > 0),
    exp INT NOT NULL CHECK (quests.exp > 0),
    balance INT NOT NULL CHECK (quests.balance >= 0),
    reward_id INT NOT NULL,
    npc_id INT,
    location_id INT,
    location_x INT,
    location_y INT,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP,
    CONSTRAINT location_check CHECK ((quests.npc_id IS NULL AND quests.location_id IS NOT NULL AND quests.location_x IS NOT NULL AND quests.location_y IS NOT NULL)
                                      OR (quests.npc_id IS NOT NULL AND quests.location_id IS NULL AND quests.location_x IS NULL AND quests.location_y IS NULL))
);


-- -----------------------------------------------------
-- Table game.history_log
-- -----------------------------------------------------
DROP TABLE IF EXISTS game.history_log CASCADE;

CREATE TABLE IF NOT EXISTS game.history_log (
    id SERIAL PRIMARY KEY,
    character_id INT NOT NULL,
    quest_id INT,
    item_id INT CHECK (history_log.quest_id IS NULL),
    location_id INT NOT NULL,
    location_x INT NOT NULL,
    location_y INT NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP,
    CONSTRAINT historylog_check CHECK ((history_log.quest_id IS NOT NULL AND history_log.item_id IS NULL)
                                           OR (history_log.item_id IS NOT NULL AND history_log.quest_id IS NULL))
);


-- -----------------------------------------------------
-- Table game.monster_types
-- -----------------------------------------------------
DROP TABLE IF EXISTS game.monster_types CASCADE;

CREATE TABLE IF NOT EXISTS game.monster_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(45) UNIQUE NOT NULL,
    description TEXT NOT NULL,
    hp INT NOT NULL CHECK (monster_types.hp > 0),
    mp INT NOT NULL CHECK (monster_types.mp >= 0),
    speed INT NOT NULL CHECK (monster_types.speed > 0),
    armor INT NOT NULL CHECK (monster_types.armor > 0),
    attack INT NOT NULL CHECK (monster_types.attack > 0),
    level INT NOT NULL DEFAULT 1 CHECK (monster_types.level > 0),
    exp INT NOT NULL CHECK (monster_types.exp > 0),
    balance INT CHECK (monster_types.balance >= 0),
    item_id INT,
    requirement_monster INT,
    requirement_quest INT,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP
);


-- -----------------------------------------------------
-- Table game.levels
-- -----------------------------------------------------
DROP TABLE IF EXISTS game.levels CASCADE;

CREATE TABLE IF NOT EXISTS game.levels (
    id SERIAL PRIMARY KEY,
    exp_needed INT NOT NULL CHECK (levels.exp_needed >= 0),
    hp_modifier INT NOT NULL CHECK (levels.hp_modifier > 0),
    mp_modifier INT NOT NULL CHECK (levels.mp_modifier >= 0),
    speed_modifier INT NOT NULL CHECK (levels.speed_modifier > 0),
    attack_modifier INT NOT NULL CHECK (levels.attack_modifier > 0),
    armor_modifier INT NOT NULL CHECK (levels.armor_modifier > 0),
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP
);


-- -----------------------------------------------------
-- Table game.monsters
-- -----------------------------------------------------
DROP TABLE IF EXISTS game.monsters CASCADE;

CREATE TABLE IF NOT EXISTS game.monsters (
    id SERIAL PRIMARY KEY,
    type_id INT NOT NULL,
    location_id INT NOT NULL,
    location_x INT NOT NULL,
    location_y INT NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP
);


-- -----------------------------------------------------
-- Table game.teams_info
-- -----------------------------------------------------
DROP TABLE IF EXISTS game.teams_info CASCADE;

CREATE TABLE IF NOT EXISTS game.teams_info (
    id SERIAL PRIMARY KEY,
    name VARCHAR(45) UNIQUE NOT NULL,
    description TEXT,
    max_members INT NOT NULL DEFAULT 20 CHECK (teams_info.max_members >= 1),
    team_balance INT NOT NULL DEFAULT 0 CHECK (teams_info.team_balance >= 0),
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP
);


-- -----------------------------------------------------
-- Table game.teams_roles
-- -----------------------------------------------------
DROP TABLE IF EXISTS game.teams_roles CASCADE;

CREATE TABLE IF NOT EXISTS game.teams_roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(45) UNIQUE NOT NULL,
    description TEXT,
    modify_members BOOLEAN NOT NULL DEFAULT false,
    modify_info BOOLEAN NOT NULL DEFAULT false,
    use_balance BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP
);


-- -----------------------------------------------------
-- Table game.teams
-- -----------------------------------------------------
DROP TABLE IF EXISTS game.teams CASCADE;

CREATE TABLE IF NOT EXISTS game.teams (
    id SERIAL PRIMARY KEY,
    team_id INT NOT NULL,
    character_id INT NOT NULL,
    character_role INT NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP
);


-- -----------------------------------------------------
-- Table game.combat_log
-- -----------------------------------------------------
DROP TABLE IF EXISTS game.combat_log CASCADE;

CREATE TABLE IF NOT EXISTS game.combat_log (
    id SERIAL PRIMARY KEY,
    character_id INT NOT NULL,
    enemy_character_id INT,
    enemy_npc_id INT,
    team_id INT,
    monster_id INT,
    log JSONB NOT NULL,
    location_id INT NOT NULL,
    location_x INT NOT NULL,
    location_y INT NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP,
    CONSTRAINT combatlog_check CHECK ((combat_log.enemy_character_id IS NOT NULL AND combat_log.enemy_npc_id IS NULL AND combat_log.team_id IS NULL AND combat_log.monster_id IS NULL)
                                          OR (combat_log.enemy_character_id IS NULL AND combat_log.enemy_npc_id IS NOT NULL AND combat_log.team_id IS NULL AND combat_log.monster_id IS NULL)
                                          OR (combat_log.enemy_character_id IS NULL AND combat_log.enemy_npc_id IS NULL AND combat_log.team_id IS NOT NULL AND combat_log.monster_id IS NULL)
                                          OR (combat_log.enemy_character_id IS NULL AND combat_log.enemy_npc_id IS NULL AND combat_log.team_id IS NULL AND combat_log.monster_id IS NOT NULL))
);


-- -----------------------------------------------------
-- Table game.map
-- -----------------------------------------------------
DROP TABLE IF EXISTS game.map CASCADE;

CREATE TABLE IF NOT EXISTS game.map (
    id SERIAL PRIMARY KEY,
    name VARCHAR(45) UNIQUE NOT NULL,
    description TEXT NOT NULL,
    min_level INT NOT NULL DEFAULT 1 CHECK (map.min_level >= 1),
    requirement_monster INT,
    requirement_quest INT,
    location INT[][] NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP
);


-- -----------------------------------------------------
-- Table game.characters
-- -----------------------------------------------------
DROP TABLE IF EXISTS game.characters CASCADE;

CREATE TABLE IF NOT EXISTS game.characters (
    id SERIAL PRIMARY KEY,
    name VARCHAR(45) NOT NULL,
    role_id INT NOT NULL,
    user_id INT NOT NULL,
    hp INT NOT NULL CHECK (characters.hp > 0),
    mp INT NOT NULL CHECK (characters.mp >= 0),
    speed INT NOT NULL CHECK (characters.speed > 0),
    armor INT NOT NULL CHECK (characters.armor > 0),
    attack INT NOT NULL CHECK (characters.attack > 0),
    level INT NOT NULL DEFAULT 1 CHECK (characters.level >= 1),
    exp INT NOT NULL DEFAULT 0 CHECK (characters.exp >= 0),
    balance INT NOT NULL DEFAULT 0 CHECK (characters.balance >= 0),
    location_id INT NOT NULL,
    location_x INT NOT NULL,
    location_y INT NOT NULL,
    abilities JSONB NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP
);


-- -----------------------------------------------------
-- Table game.role_abilities
-- -----------------------------------------------------
DROP TABLE IF EXISTS game.role_abilities CASCADE;

CREATE TABLE IF NOT EXISTS game.role_abilities (
    id SERIAL PRIMARY KEY,
    name VARCHAR(45) UNIQUE NOT NULL,
    description TEXT NOT NULL,
    role_id INT NOT NULL,
    requirement_id game.ltree NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP
);

CREATE INDEX role_abilities_index ON game.role_abilities USING GIST (requirement_id);


-- -----------------------------------------------------
-- Table game.inventory
-- -----------------------------------------------------
DROP TABLE IF EXISTS game.inventory CASCADE;

CREATE TABLE IF NOT EXISTS game.inventory (
    id SERIAL PRIMARY KEY,
    character_id INT NOT NULL,
    item_id INT NOT NULL,
    count INT NOT NULL CHECK (inventory.count > 0),
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP
);


-- -----------------------------------------------------
-- Table game.relationships
-- -----------------------------------------------------
DROP TABLE IF EXISTS game.relationships CASCADE;

CREATE TABLE IF NOT EXISTS game.relationships (
    id SERIAL PRIMARY KEY,
    userA_id INT NOT NULL CHECK (relationships.userA_id != relationships.userB_id),
    userB_id INT NOT NULL CHECK (relationships.userB_id != relationships.userA_id),
    friend BOOLEAN NOT NULL DEFAULT false,
    ignored BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP,
    CONSTRAINT friend_ignored_check CHECK ((friend IS true AND ignored IS false)
                                              OR (ignored IS true AND friend IS false))
);


-- -----------------------------------------------------
-- Table game.chat
-- -----------------------------------------------------
DROP TABLE IF EXISTS game.chat CASCADE;

CREATE TABLE IF NOT EXISTS game.chat (
    id SERIAL PRIMARY KEY,
    team_id INT,
    relationship_id INT,
    log JSONB NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP,
    CONSTRAINT chat_check CHECK ((chat.relationship_id IS NOT NULL AND chat.team_id IS NULL)
                                             OR (chat.team_id IS NOT NULL AND chat.relationship_id IS NULL))
);


-- -----------------------------------------------------
-- Table game.achievements
-- -----------------------------------------------------
DROP TABLE IF EXISTS game.achievements CASCADE;

CREATE TABLE IF NOT EXISTS game.achievements (
    id SERIAL PRIMARY KEY,
    name VARCHAR(45) UNIQUE NOT NULL,
    description TEXT NOT NULL,
    item_id INT,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP
);


-- -----------------------------------------------------
-- Table game.characters_achievements
-- -----------------------------------------------------
DROP TABLE IF EXISTS game.characters_achievements CASCADE;

CREATE TABLE IF NOT EXISTS game.characters_achievements (
    id SERIAL PRIMARY KEY,
    character_id INT NOT NULL,
    achievement_id INT NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP
);


-- -----------------------------------------------------
-- Table game.terrain
-- -----------------------------------------------------
DROP TABLE IF EXISTS game.terrain CASCADE;

CREATE TABLE IF NOT EXISTS game.terrain (
  id SERIAL PRIMARY KEY,
  name VARCHAR(45) UNIQUE NOT NULL,
  description TEXT,
  img BYTEA NOT NULL,
  properties JSONB NOT NULL,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL,
  deleted_at TIMESTAMP
);


-- -----------------------------------------------------
-- Indexes
-- -----------------------------------------------------
ALTER TABLE game.items ADD CONSTRAINT fk_locationid FOREIGN KEY (location_id) REFERENCES game.map (id) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE game.npcs ADD CONSTRAINT fk_locationid FOREIGN KEY (location_id) REFERENCES game.map (id) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE game.quests ADD CONSTRAINT fk_rewardid FOREIGN KEY (reward_id) REFERENCES game.items (id) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE game.quests ADD CONSTRAINT fk_npcid FOREIGN KEY (npc_id) REFERENCES game.npcs (id) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE game.quests ADD CONSTRAINT fk_locationid FOREIGN KEY (location_id) REFERENCES game.map (id) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE game.history_log ADD CONSTRAINT fk_charaterid FOREIGN KEY (character_id) REFERENCES game.characters (id) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE game.history_log ADD CONSTRAINT fk_questid FOREIGN KEY (quest_id) REFERENCES game.quests (id) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE game.history_log ADD CONSTRAINT fk_itemid FOREIGN KEY (item_id) REFERENCES game.items (id) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE game.history_log ADD CONSTRAINT fk_locationid FOREIGN KEY (location_id) REFERENCES game.map (id) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE game.combat_log ADD CONSTRAINT fk_characterid FOREIGN KEY (character_id) REFERENCES game.characters (id) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE game.combat_log ADD CONSTRAINT fk_monsterid FOREIGN KEY (monster_id) REFERENCES game.monsters (id) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE game.combat_log ADD CONSTRAINT fk_enemycharacterid FOREIGN KEY (enemy_character_id) REFERENCES game.characters (id) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE game.combat_log ADD CONSTRAINT fk_teamid FOREIGN KEY (team_id) REFERENCES game.teams (id) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE game.combat_log ADD CONSTRAINT fk_enemynpcid FOREIGN KEY (enemy_npc_id) REFERENCES game.npcs (id) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE game.combat_log ADD CONSTRAINT fk_locationid FOREIGN KEY (location_id) REFERENCES game.map (id) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE game.monster_types ADD CONSTRAINT fk_reqmonster FOREIGN KEY (requirement_monster) REFERENCES game.monster_types (id) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE game.monster_types ADD CONSTRAINT fk_reqhistory FOREIGN KEY (requirement_quest) REFERENCES game.quests (id) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE game.monster_types ADD CONSTRAINT fk_level FOREIGN KEY (level) REFERENCES game.levels (id) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE game.monster_types ADD CONSTRAINT fk_itemid FOREIGN KEY (item_id) REFERENCES game.items (id) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE game.teams ADD CONSTRAINT fk_character FOREIGN KEY (character_id) REFERENCES game.characters (id) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE game.teams ADD CONSTRAINT fk_name FOREIGN KEY (team_id) REFERENCES game.teams_info (id) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE game.teams ADD CONSTRAINT fk_role FOREIGN KEY (character_role) REFERENCES game.teams_roles (id) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE game.monsters ADD CONSTRAINT fk_locationid FOREIGN KEY (location_id) REFERENCES game.map (id) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE game.monsters ADD CONSTRAINT fk_typeid FOREIGN KEY (type_id) REFERENCES game.monster_types (id) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE game.map ADD CONSTRAINT fk_monsterid FOREIGN KEY (requirement_monster) REFERENCES game.monster_types (id) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE game.map ADD CONSTRAINT fk_questid FOREIGN KEY (requirement_quest) REFERENCES game.quests (id) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE game.characters ADD CONSTRAINT fk_roleid FOREIGN KEY (role_id) REFERENCES game.roles (id) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE game.characters ADD CONSTRAINT fk_userid FOREIGN KEY (user_id) REFERENCES game.users (id) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE game.characters ADD CONSTRAINT fk_locationid FOREIGN KEY (location_id) REFERENCES game.map (id) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE game.characters ADD CONSTRAINT fk_level FOREIGN KEY (level) REFERENCES game.levels (id) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE game.role_abilities ADD CONSTRAINT fk_roleid FOREIGN KEY (role_id) REFERENCES game.roles (id) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE game.inventory ADD CONSTRAINT fk_characterid FOREIGN KEY (character_id) REFERENCES game.characters (id) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE game.inventory ADD CONSTRAINT fk_itemid FOREIGN KEY (item_id) REFERENCES game.items (id) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE game.relationships ADD CONSTRAINT fk_userid FOREIGN KEY (userA_id) REFERENCES game.users (id) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE game.relationships ADD CONSTRAINT fk_friendid FOREIGN KEY (userB_id) REFERENCES game.users (id) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE game.chat ADD CONSTRAINT fk_teamid FOREIGN KEY (team_id) REFERENCES game.teams (id) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE game.chat ADD CONSTRAINT fk_relationshipid FOREIGN KEY (relationship_id) REFERENCES game.relationships (id) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE game.achievements ADD CONSTRAINT fk_itemid FOREIGN KEY (item_id) REFERENCES game.items (id) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE game.characters_achievements ADD CONSTRAINT fk_characterid FOREIGN KEY (character_id) REFERENCES game.characters (id) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE game.characters_achievements ADD CONSTRAINT fk_achievementid FOREIGN KEY (achievement_id) REFERENCES game.achievements (id) ON DELETE NO ACTION ON UPDATE NO ACTION;


-- -----------------------------------------------------
-- View game.friend_data
-- -----------------------------------------------------
CREATE OR REPLACE VIEW friend_data AS
SELECT p.charname, p.rolename, p.level, f.user_id
FROM (SELECT c.id, c.name charname, r.name rolename, c.level
FROM characters c JOIN roles r on c.role_id = r.id) p
JOIN friends f ON p.id = f.friend_id;


-- -----------------------------------------------------
-- Inserts
-- -----------------------------------------------------
INSERT INTO game.levels (exp_needed, hp_modifier, mp_modifier, speed_modifier, attack_modifier, armor_modifier, created_at, updated_at)
VALUES (0, 1, 1, 1, 1, 1, current_timestamp, current_timestamp), (500, 5, 7, 5, 12, 8, current_timestamp, current_timestamp),
       (1200, 10, 7, 4, 6, 7, current_timestamp, current_timestamp), (2400, 4, 4, 2, 5, 8, current_timestamp, current_timestamp);

INSERT INTO game.roles (name, hp_base, mp_base, speed_base, armor_base, attack_base, hp_modifier, mp_modifier, speed_modifier, armor_modifier, attack_modifier, created_at, updated_at)
VALUES ('Warrior', 40, 0, 10, 10, 8, 3, 0, 2, 4, 3, current_timestamp, current_timestamp),
       ('Mage', 30, 25, 12, 7, 7, 3, 4, 2, 2, 2, current_timestamp, current_timestamp),
       ('Rogue', 55, 0, 17, 5, 14, 4, 0, 4, 2, 5, current_timestamp, current_timestamp),
       ('Druid', 35, 20, 8, 7, 8, 4, 5, 1, 1, 3, current_timestamp, current_timestamp),
       ('Barbarian', 65, 0, 5, 15, 7, 5, 0, 1, 4, 2, current_timestamp, current_timestamp);

INSERT INTO game.role_abilities (name, description, role_id, requirement_id, created_at, updated_at)
VALUES ('charge', 'charge for a short while before unleashing a strong attack', 1, 'root', current_timestamp, current_timestamp),
       ('wind up', 'swing upright sending enemies flying', 1, 'root', current_timestamp, current_timestamp),
       ('whirlwind', 'hits all enemies in your area', 1, 'root.2', current_timestamp, current_timestamp),
       ('smashdown', 'smash a flying enemy to the ground dealing big damage', 1, 'root.2', current_timestamp, current_timestamp),
       ('raincutter', 'attack all enemies in your area 3 times', 1, 'root.1', current_timestamp, current_timestamp),
       ('shieldstrike', 'attack with shield', 1, 'root.1', current_timestamp, current_timestamp);

INSERT INTO game.items (name, description, value, hp_modifier, mp_modifier, speed_modifier, armor_modifier, attack_modifier, level_min, created_at, updated_at)
VALUES ('Wooden sword', 'A dull training sword made from wood. Its weak, but better than nothing', 5, 0, 0, 2, 0, 7, 1, current_timestamp, current_timestamp);
INSERT INTO game.items (name, description, value, hp_modifier, mp_modifier, speed_modifier, armor_modifier, attack_modifier, level_min, created_at, updated_at)
VALUES ('Wooden shield', 'An old wooden shield that has seen better days', 5, 0, 0, 0, 6, 0, 1, current_timestamp, current_timestamp);
INSERT INTO game.items (name, description, value, hp_modifier, mp_modifier, speed_modifier, armor_modifier, attack_modifier, level_min, created_at, updated_at)
VALUES ('Small bottle of slime', 'Left behind by Slimes', 2, 0, 0, 0, 0, 0, 1, current_timestamp, current_timestamp);
INSERT INTO game.items (name, description, value, hp_modifier, mp_modifier, speed_modifier, armor_modifier, attack_modifier, level_min, created_at, updated_at)
VALUES ('Razorfish scales', 'Left behind by Razorfish', 10, 0, 0, 0, 0, 0, 1, current_timestamp, current_timestamp);
INSERT INTO game.items (name, description, value, hp_modifier, mp_modifier, speed_modifier, armor_modifier, attack_modifier, level_min, created_at, updated_at)
VALUES ('Iron Sword', 'Sword commonly used by mercenaries', 50, 0, 0, 6, 0, 13, 2, current_timestamp, current_timestamp);
INSERT INTO game.items (name, description, value, hp_modifier, mp_modifier, speed_modifier, armor_modifier, attack_modifier, level_min, created_at, updated_at)
VALUES ('Iron Shield', 'You need more than a few swings to break this shield', 45, 0, 0, 3, 14, 0, 2, current_timestamp, current_timestamp);
INSERT INTO game.items (name, description, value, hp_modifier, mp_modifier, speed_modifier, armor_modifier, attack_modifier, level_min, created_at, updated_at)
VALUES ('Old shoes', 'These shoes were made for walking', 20, 0, 0, 10, 2, 0, 2, current_timestamp, current_timestamp);

INSERT INTO game.monster_types (name, description, hp, mp, speed, armor, attack, level, exp, balance, item_id, created_at, updated_at)
VALUES ('Slime', 'A small bunch of sentient slime... not sure how it moves', 25, 10, 4, 4, 6, 1, 10, 5, 3, current_timestamp, current_timestamp);
INSERT INTO game.monster_types (name, description, hp, mp, speed, armor, attack, level, exp, balance, created_at, updated_at)
VALUES ('Goblin', 'These nasty creatures like to hide in treetops and ambush unsuspecting prey', 40, 0, 7, 7, 10, 2, 25, 12, current_timestamp, current_timestamp);
INSERT INTO game.monster_types (name, description, hp, mp, speed, armor, attack, level, exp, balance, item_id, created_at, updated_at)
VALUES ('Razorfish', 'Small fish with scales sharp like razors. Only fool would swim among them', 20, 0, 18, 2, 16, 3, 40, 20, 4, current_timestamp, current_timestamp);
INSERT INTO game.monster_types (name, description, hp, mp, speed, armor, attack, level, exp, balance, created_at, updated_at)
VALUES ('Goblin Tribe Chief', 'Slightly larger than other goblins', 120, 0, 10, 20, 19, 3, 250, 120, current_timestamp, current_timestamp);

INSERT INTO game.users (username, password, last_login, is_online, created_at, updated_at)
VALUES ('admin', 'adminpass', current_timestamp, true, current_timestamp, current_timestamp);
INSERT INTO game.users (username, password, last_login, facebook_token, is_online, created_at, updated_at)
VALUES ('facebookuser', 'fbpassword', current_timestamp, 'AhfT5xRR0lP3nmTg7WHwsIP9BasC75', true, current_timestamp, current_timestamp);
INSERT INTO game.users (username, password, last_login, google_token, is_online, created_at, updated_at)
VALUES ('googleuser', 'gpassword', current_timestamp,'H5ndu6opdUD6QjD8kd7DsIFYDMgd', true, current_timestamp, current_timestamp);
INSERT INTO game.users (username, password, last_login, is_online, created_at, updated_at)
VALUES ('newuser', 'Fina11y_A_L0ng_S3cur3_Pa55w0rd', current_timestamp, true, current_timestamp, current_timestamp);
INSERT INTO game.users (username, password, last_login, is_online, created_at, updated_at)
VALUES ('playerOne', 'PoItBpItW', current_timestamp, true, current_timestamp, current_timestamp);

INSERT INTO game.map (name, description, min_level, location, created_at, updated_at)
VALUES ('Church Ruins', 'A small thicket with a church ruins in the middle. There isnt a lot of monsters here and they are not very strong',
        1, ARRAY[[1, 5, 2, 1, 5], [1, 2, 2, 2, 3], [5, 2, 4, 2, 3], [1, 2, 2, 2, 3], [1, 5, 1, 2, 3]], current_timestamp, current_timestamp);
INSERT INTO game.map (name, description, min_level, location, created_at, updated_at)
VALUES ('Dark Forest', 'The trees are huddled together with their treetops interwined so only a little sunlight gets through',
        2, ARRAY[[2, 5, 5, 5, 5], [2, 2, 5, 5, 5], [5, 2, 2, 5, 5], [5, 5, 2, 5, 5], [5, 5, 2, 5, 5]], current_timestamp, current_timestamp);
INSERT INTO game.map (name, description, min_level, location, requirement_monster, created_at, updated_at)
VALUES ('Riverside', 'River filled with Razorfish is flowing peacefully, glinting in sunlight',
        3, ARRAY[[6, 6, 6, 6, 6, 6, 6, 6, 6, 6], [6, 6, 6, 6, 6, 6, 6, 6, 6, 6], [1, 2, 2, 2, 2, 1, 5, 1, 5, 5],
            [2, 2, 1, 1, 2, 2, 2, 2, 2, 2], [5, 1, 1, 1, 5, 1, 5, 5, 1, 5]], 4, current_timestamp, current_timestamp);

INSERT INTO game.monsters (type_id, location_id, location_x, location_y, created_at, updated_at)
VALUES (1, 1, 0, 0, current_timestamp, current_timestamp), (1, 1, 2, 3, current_timestamp, current_timestamp),
       (1, 1, 4, 2, current_timestamp, current_timestamp), (1, 2, 4, 1, current_timestamp, current_timestamp),
       (1, 2, 0, 1, current_timestamp, current_timestamp), (1, 2, 2, 3, current_timestamp, current_timestamp),
       (1, 2, 3, 1, current_timestamp, current_timestamp), (1, 2, 4, 3, current_timestamp, current_timestamp),
       (1, 3, 0, 5, current_timestamp, current_timestamp), (1, 3, 1, 8, current_timestamp, current_timestamp),
       (4, 2, 0, 0, current_timestamp, current_timestamp);

INSERT INTO game.npcs (name, location_id, location_x, location_y, created_at, updated_at)
VALUES ('Woodsman', 2, 2, 4, current_timestamp, current_timestamp);
INSERT INTO game.npcs (name, location_id, location_x, location_y, created_at, updated_at)
VALUES ('Drowning child', 3, 7, 1, current_timestamp, current_timestamp);

INSERT INTO game.quests (name, description, min_level, exp, balance, reward_id, location_id, location_x, location_y, created_at, updated_at)
VALUES ('Save drowning child', 'You came across a drowning child in the river', 3, 100, 25, 1, 3, 9, 3, current_timestamp, current_timestamp);
INSERT INTO game.quests (name, description, min_level, exp, balance, reward_id, npc_id, created_at, updated_at)
VALUES ('Defeat Goblin Tribe Chief', 'Defeat a Goblin Chief to gain access to new map', 2, 220, 50, 4, 1, current_timestamp, current_timestamp);

INSERT INTO game.achievements (name, description, item_id, created_at, updated_at)
VALUES ('Slime Exterminator', 'Defeat 100 Slimes', 5, current_timestamp, current_timestamp),
       ('The Goblins Doom', 'Defeat 100 Goblins', 5, current_timestamp, current_timestamp),
       ('The Long Road', 'Walk 100 km', 6, current_timestamp, current_timestamp);

INSERT INTO game.characters (name, role_id, user_id, hp, mp, speed, armor, attack, level, exp, balance, location_id, location_x, location_y, abilities, created_at, updated_at)
VALUES ('Popolvar', 1, 1, 62, 0, 22, 29, 21, 4, 1254, 467, 3, 2, 2, '{"abilities": [2, 3, 1]}', current_timestamp, current_timestamp),
       ('Princ Krason', 1, 4, 47, 0, 15, 17, 14, 2, 265, 112, 1, 2, 0, '{"abilities": [1]}', current_timestamp, current_timestamp),
       ('Abracadabrus420', 2, 2, 44, 36, 22, 17, 19, 3, 622, 210, 2, 0, 0, '{"abilities": []}', current_timestamp, current_timestamp),
       ('Conan', 5, 3, 86, 0, 12, 34, 27, 4, 866, 374, 3, 6, 3, '{"abilities": []}', current_timestamp, current_timestamp),
       ('Panoramatix', 4, 2, 42, 30, 15, 17, 20, 3, 311, 136, 2, 2, 2, '{"abilities": []}', current_timestamp, current_timestamp),
       ('Nighwalker', 3, 5, 55, 0, 17, 5, 14, 1, 0, 0, 1, 2, 0, '{"abilities": []}', current_timestamp, current_timestamp);

-- Insert new ability to user with id = 2
UPDATE game.characters SET abilities = jsonb_set(
  abilities::jsonb,
  array['abilities'],
  (abilities->'abilities')::jsonb || '6'::jsonb)
WHERE id = 2;

INSERT INTO game.characters_achievements (character_id, achievement_id, created_at, updated_at)
VALUES (1, 1, current_timestamp, current_timestamp), (1, 2, current_timestamp, current_timestamp),
       (3, 1, current_timestamp, current_timestamp), (5, 1, current_timestamp, current_timestamp);

INSERT INTO game.relationships (usera_id, userb_id, friend, created_at, updated_at)
VALUES (1, 2, true, current_timestamp, current_timestamp),
       (3, 4, true, current_timestamp, current_timestamp),
       (1, 3, true, current_timestamp, current_timestamp),
       (2, 3, true, current_timestamp, current_timestamp);
INSERT INTO game.relationships (usera_id, userb_id, ignored, created_at, updated_at)
VALUES (2, 4, true, current_timestamp, current_timestamp),
       (4, 1, true, current_timestamp, current_timestamp),
       (4, 5, true, current_timestamp, current_timestamp);

INSERT INTO game.teams_info (name, description, max_members, team_balance, created_at, updated_at)
VALUES ('Black Hand', 'We are black hand! Welcome new members!', 100, 12364, current_timestamp, current_timestamp),
       ('Army of Light', 'Army of light shine on you', 55, 53840, current_timestamp, current_timestamp);

INSERT INTO game.teams_roles (name, modify_members, modify_info, use_balance, created_at, updated_at)
VALUES ('Owner', true, true, true, current_timestamp, current_timestamp),
       ('Admin', true, false, true, current_timestamp, current_timestamp),
       ('Banker', false, false, true, current_timestamp, current_timestamp),
       ('Member', false, false, false, current_timestamp, current_timestamp);

INSERT INTO game.teams (team_id, character_id, character_role, created_at, updated_at)
VALUES (1, 1, 1, current_timestamp, current_timestamp), (1, 3, 2, current_timestamp, current_timestamp),
       (1, 5, 4, current_timestamp, current_timestamp), (1, 4, 4, current_timestamp, current_timestamp),
       (2, 2, 1, current_timestamp, current_timestamp), (2, 4, 3, current_timestamp, current_timestamp);

INSERT INTO game.chat (relationship_id, log, created_at, updated_at) VALUES (2, '{"users": [{"id": 3, "name": "Abracadabrus420"},
{"id": 4, "name": "Conan"}], "log": []}', current_timestamp, current_timestamp);

-- Insert new message in chat with id = 1
UPDATE game.chat SET log = jsonb_set(
  log::jsonb,
  array['log'],
  (log->'log')::jsonb || '{"timestamp": "2021-04-07 23:12:54.61542", "from": "Conan", "content": "Hello!"}'::jsonb)
WHERE id = 1;
