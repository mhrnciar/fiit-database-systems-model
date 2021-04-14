-- -----------------------------------------------------
-- Schema game
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS game CASCADE;
CREATE SCHEMA IF NOT EXISTS game;
CREATE EXTENSION IF NOT EXISTS ltree;

-- -----------------------------------------------------
-- Table game.users
-- -----------------------------------------------------
DROP TABLE IF EXISTS game.users CASCADE;

CREATE TABLE IF NOT EXISTS game.users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(45) UNIQUE NOT NULL,
    password VARCHAR(45) NOT NULL CHECK (length(users.password) >= 8),
    last_login TIMESTAMP NOT NULL,
    facebook_token VARCHAR(100) CHECK (users.google_token IS NULL),
    google_token VARCHAR(100) CHECK (users.facebook_token IS NULL),
    is_online BOOLEAN NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP
);


-- -----------------------------------------------------
-- Table game.roles
-- -----------------------------------------------------
DROP TABLE IF EXISTS game.roles CASCADE;

CREATE TABLE IF NOT EXISTS game.roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(45) UNIQUE NOT NULL,
    hp_base INT NOT NULL CHECK (roles.hp_base > 0),
    mp_base INT NOT NULL CHECK (roles.mp_base > 0),
    speed_base INT NOT NULL CHECK (roles.speed_base > 0),
    armor_base INT NOT NULL CHECK (roles.armor_base > 0),
    attack_base INT NOT NULL CHECK (roles.attack_base > 0),
    hp_modifier INT CHECK (roles.hp_modifier > 0),
    mp_modifier INT CHECK (roles.mp_modifier > 0),
    speed_modifier INT CHECK (roles.speed_modifier > 0),
    armor_modifier INT CHECK (roles.armor_modifier > 0),
    attack_modifier INT CHECK (roles.attack_modifier > 0),
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
    hp_modifier INT CHECK (items.hp_modifier > 0),
    mp_modifier INT CHECK (items.mp_modifier > 0),
    speed_modifier INT CHECK (items.speed_modifier > 0),
    armor_modifier INT CHECK (items.armor_modifier > 0),
    attack_modifier INT CHECK (items.attack_modifier > 0),
    level_min INT DEFAULT 1 CHECK (items.level_min > 0),
    location_id INT,
    location_x INT CHECK (items.location_id IS NOT NULL),
    location_y INT CHECK (items.location_id IS NOT NULL),
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP
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
    npc_id INT CHECK (quests.location_id IS NULL),
    location_id INT CHECK (quests.npc_id IS NULL),
    location_x INT CHECK (quests.location_id IS NOT NULL),
    location_y INT CHECK (quests.location_id IS NOT NULL),
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP
);


-- -----------------------------------------------------
-- Table game.history_log
-- -----------------------------------------------------
DROP TABLE IF EXISTS game.history_log CASCADE;

CREATE TABLE IF NOT EXISTS game.history_log (
    id SERIAL PRIMARY KEY,
    character_id INT NOT NULL,
    quest_id INT CHECK (history_log.item_id IS NULL),
    item_id INT CHECK (history_log.quest_id IS NULL),
    location_id INT NOT NULL,
    location_x INT NOT NULL,
    location_y INT NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP
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
    mp INT NOT NULL CHECK (monster_types.mp > 0),
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
    exp_needed INT NOT NULL CHECK (levels.exp_needed > 0),
    hp_modifier INT NOT NULL CHECK (levels.hp_modifier > 0),
    mp_modifier INT NOT NULL CHECK (levels.mp_modifier > 0),
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
    enemy_character_id INT CHECK (combat_log.enemy_npc_id IS NULL AND combat_log.team_id IS NULL AND combat_log.monster_id IS NULL),
    enemy_npc_id INT CHECK (combat_log.enemy_character_id IS NULL AND combat_log.team_id IS NULL AND combat_log.monster_id IS NULL),
    team_id INT CHECK (combat_log.enemy_npc_id IS NULL AND combat_log.enemy_character_id IS NULL AND combat_log.monster_id IS NULL),
    monster_id INT CHECK (combat_log.enemy_npc_id IS NULL AND combat_log.team_id IS NULL AND combat_log.enemy_character_id IS NULL),
    log JSONB NOT NULL,
    location_id INT NOT NULL,
    location_x INT NOT NULL,
    location_y INT NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP
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
    hp INT NOT NULL CHECK (characters.hp >= 0),
    mp INT NOT NULL CHECK (characters.mp >= 0),
    speed INT NOT NULL CHECK (characters.speed >= 0),
    armor INT NOT NULL CHECK (characters.armor >= 0),
    attack INT NOT NULL CHECK (characters.attack >= 0),
    level INT NOT NULL DEFAULT 1 CHECK (characters.level >= 1),
    exp INT NOT NULL DEFAULT 0 CHECK (characters.exp >= 0),
    balance INT NOT NULL DEFAULT 0 CHECK (characters.balance >= 0),
    location_id INT NOT NULL,
    location_x INT NOT NULL,
    location_y INT NOT NULL,
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
    requirement_id ltree,
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
    friend BOOLEAN NOT NULL DEFAULT false CHECK (ignored IS NOT true),
    ignored BOOLEAN NOT NULL DEFAULT false CHECK (friend IS NOT true),
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP
);


-- -----------------------------------------------------
-- Table game.chat
-- -----------------------------------------------------
DROP TABLE IF EXISTS game.chat CASCADE;

CREATE TABLE IF NOT EXISTS game.chat (
    id SERIAL PRIMARY KEY,
    team_id INT CHECK (chat.relationship_id IS NULL),
    relationship_id INT CHECK (chat.team_id IS NULL),
    log JSONB NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP
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

ALTER TABLE game.monster_types ADD CONSTRAINT fk_reqmonster FOREIGN KEY (requirement_monster) REFERENCES game.combat_log (id) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE game.monster_types ADD CONSTRAINT fk_reqhistory FOREIGN KEY (requirement_quest) REFERENCES game.history_log (id) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE game.monster_types ADD CONSTRAINT fk_level FOREIGN KEY (level) REFERENCES game.levels (id) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE game.monster_types ADD CONSTRAINT fk_itemid FOREIGN KEY (item_id) REFERENCES game.items (id) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE game.teams ADD CONSTRAINT fk_character FOREIGN KEY (character_id) REFERENCES game.characters (id) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE game.teams ADD CONSTRAINT fk_name FOREIGN KEY (team_id) REFERENCES game.teams_info (id) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE game.teams ADD CONSTRAINT fk_role FOREIGN KEY (character_role) REFERENCES game.teams_roles (id) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE game.monsters ADD CONSTRAINT fk_locationid FOREIGN KEY (location_id) REFERENCES game.map (id) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE game.monsters ADD CONSTRAINT fk_typeid FOREIGN KEY (type_id) REFERENCES game.monster_types (id) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE game.map ADD CONSTRAINT fk_monsterid FOREIGN KEY (requirement_monster) REFERENCES game.combat_log (id) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE game.map ADD CONSTRAINT fk_questid FOREIGN KEY (requirement_quest) REFERENCES game.history_log (id) ON DELETE NO ACTION ON UPDATE NO ACTION;

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

