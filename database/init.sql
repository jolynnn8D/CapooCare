DROP TABLE IF EXISTS PCSAdmin CASCADE;
DROP TABLE IF EXISTS PetOwner CASCADE;
DROP TABLE IF EXISTS CareTaker CASCADE;
DROP TABLE IF EXISTS FullTimer CASCADE;
DROP TABLE IF EXISTS PartTimer CASCADE;
DROP TABLE IF EXISTS Category CASCADE;
DROP TABLE IF EXISTS Has_Availability CASCADE;
DROP TABLE IF EXISTS Cares CASCADE;
DROP TABLE IF EXISTS Owned_Pet_Belongs CASCADE;
DROP TABLE IF EXISTS Bid CASCADE;
DROP VIEW IF EXISTS Users CASCADE;
DROP VIEW IF EXISTS Accounts CASCADE;

--DROP TRIGGERS
DROP TRIGGER IF EXISTS check_fulltimer ON CareTaker CASCADE;
DROP TRIGGER IF EXISTS check_parttimer ON PartTimer CASCADE;
DROP TRIGGER IF EXISTS check_fulltimer ON FullTimer CASCADE;
DROP TRIGGER IF EXISTS check_ft_cares_price ON Cares CASCADE;
DROP TRIGGER IF EXISTS check_update_base_price ON Category CASCADE;
DROP TRIGGER IF EXISTS fulltimer_automatic_mark_upon_insert ON Bid CASCADE;
DROP TRIGGER IF EXISTS validate_bid_marking ON Bid CASCADE;
DROP TRIGGER IF EXISTS mark_other_bids_false ON Bid CASCADE;
DROP TRIGGER IF EXISTS check_rating_update ON Bid CASCADE;

/*                                      **IMPORTANT**


    The code block below drops all functions, aggregates, and procedures from the database.
    This is required because PostgreSQL can't handle overloaded functions and procedures. */
DO
$do$
DECLARE
   _sql text;
BEGIN
   SELECT INTO _sql
          string_agg(format('DROP %s %s;'
                          , CASE prokind
                              WHEN 'f' THEN 'FUNCTION'
                              WHEN 'a' THEN 'AGGREGATE'
                              WHEN 'p' THEN 'PROCEDURE'
                              WHEN 'w' THEN 'FUNCTION'  -- window function (rarely applicable)
                              -- ELSE NULL              -- not possible in pg 11
                            END
                          , oid::regprocedure)
                   , E'\n')
   FROM   pg_proc
   WHERE  pronamespace = 'public'::regnamespace  -- schema name here!
   -- AND    prokind = ANY ('{f,a,p,w}')         -- optionally filter kinds
   ;

   IF _sql IS NOT NULL THEN
       RAISE NOTICE '%', _sql;  -- debug / check first
       EXECUTE _sql;         -- uncomment payload once you are sure
   ELSE
       RAISE NOTICE 'No fuctions found in schema %', quote_ident(_schema);
   END IF;
END
$do$;


CREATE TABLE PCSAdmin (
    username VARCHAR(50) PRIMARY KEY,
    adminName VARCHAR(50) NOT NULL,
    age   INTEGER DEFAULT NULL
);

CREATE TABLE PetOwner (
    username VARCHAR(50) PRIMARY KEY,
    ownerName VARCHAR(50) NOT NULL,
    age   INTEGER DEFAULT NULL
);

CREATE TABLE CareTaker (
    username VARCHAR(50) PRIMARY KEY,
    carerName VARCHAR(50) NOT NULL,
    age   INTEGER DEFAULT NULL
);

CREATE TABLE FullTimer (
    username VARCHAR(50) PRIMARY KEY REFERENCES CareTaker(username)
);

CREATE TABLE PartTimer (
    username VARCHAR(50) PRIMARY KEY REFERENCES CareTaker(username)
);

CREATE TABLE Category (
    pettype VARCHAR(20) PRIMARY KEY,
    base_price INTEGER NOT NULL
);

CREATE TABLE Has_Availability (
    ctuname VARCHAR(50) REFERENCES CareTaker(username) ON DELETE CASCADE,
    s_time DATE NOT NULL,
    e_time DATE NOT NULL,
    CHECK (e_time > s_time),
    PRIMARY KEY(ctuname, s_time, e_time)
);

CREATE TABLE Cares (
    ctuname VARCHAR(50) REFERENCES CareTaker(username),
    pettype VARCHAR(20) REFERENCES Category(pettype),
    price INTEGER NOT NULL,
    PRIMARY KEY (ctuname, pettype)
);

CREATE TABLE Owned_Pet_Belongs (
    pouname VARCHAR(50) NOT NULL REFERENCES PetOwner(username) ON DELETE CASCADE,
    pettype VARCHAR(20) NOT NULL REFERENCES Category(pettype),
    petname VARCHAR(20) NOT NULL,
    petage INTEGER NOT NULL,
    requirements VARCHAR(50) DEFAULT NULL,
    PRIMARY KEY (pouname, petname, pettype)
);

CREATE TABLE Bid (
    pouname VARCHAR(50),
    petname VARCHAR(20), 
    pettype VARCHAR(20),
    ctuname VARCHAR(50) NOT NULL,
    s_time DATE NOT NULL,
    e_time DATE NOT NULL,
    cost INTEGER,
    is_win BOOLEAN DEFAULT NULL,
    rating INTEGER CHECK((rating IS NULL) OR (rating >= 0 AND rating <= 5)),
    review VARCHAR(200),
    pay_type VARCHAR(20) CHECK((pay_type IS NULL) OR (pay_type = 'credit card') OR (pay_type = 'cash')),
    pay_status BOOLEAN DEFAULT FALSE,
    pet_pickup VARCHAR(20) CHECK((pet_pickup IS NULL) OR pet_pickup = 'poDeliver' OR pet_pickup = 'ctPickup' OR pet_pickup = 'transfer'),
    FOREIGN KEY (pouname, petname, pettype) REFERENCES Owned_Pet_Belongs(pouname, petname, pettype),
    PRIMARY KEY (pouname, petname, pettype, ctuname, s_time, e_time),
    CHECK (pouname <> ctuname)
);

/* Views */
CREATE OR REPLACE VIEW Users AS (
   SELECT CASE WHEN C.username IS NULL THEN P.username 
            ELSE C.username END AS username, 
        CASE WHEN C.carername IS NULL THEN P.ownername 
            ELSE C.carername END AS firstname, 
        CASE WHEN C.age IS NULL THEN P.age 
            ELSE C.age END AS age,
        CASE WHEN P.username IS NULL THEN false  
            ELSE true END AS is_petowner, 
        CASE WHEN C.username IS NULL THEN false 
            ELSE true END AS is_carer,
        CASE WHEN C.username IN (
            SELECT username
            FROM fulltimer
        ) THEN true ELSE false END AS is_fulltimer,
        CASE WHEN C.username IN (
            SELECT username
            FROM parttimer
        ) THEN true ELSE false END AS is_parttimer
    FROM petowner P FULL OUTER JOIN caretaker C ON P.username = C.username
);

CREATE OR REPLACE VIEW Accounts AS (
   SELECT username, adminName, age, false AS is_carer, true AS is_admin FROM PCSAdmin
   UNION ALL
   SELECT username, carerName, age, true AS is_carer, false AS is_admin FROM CareTaker
   UNION ALL
   SELECT username, ownerName, age, false AS is_carer, false AS is_admin FROM PetOwner
);








