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
    age   INTEGER DEFAULT NULL,
    rating INTEGER DEFAULT NULL,
    salary INTEGER DEFAULT NULL
);

CREATE TABLE FullTimer (
    username VARCHAR(50) PRIMARY KEY REFERENCES CareTaker(username),
    period1  VARCHAR(50) DEFAULT NULL,
    period2  VARCHAR(50) DEFAULT NULL
);

CREATE TABLE PartTimer (
    username VARCHAR(50) PRIMARY KEY REFERENCES CareTaker(username)
);

CREATE TABLE Category (
     petType VARCHAR(20) PRIMARY KEY
);

CREATE TABLE Has_Availability (
    ctuname VARCHAR(50) REFERENCES CareTaker(username) ON DELETE CASCADE,
    s_time TIMESTAMP,
    e_time TIMESTAMP,
    PRIMARY KEY(ctuname, s_time, e_time)
);

CREATE TABLE Cares (
    ctuname VARCHAR(50) REFERENCES CareTaker(username),
    petType VARCHAR(20) REFERENCES Category(petType),
    price INTEGER NOT NULL,
    PRIMARY KEY (ctuname, petType)
);

CREATE TABLE Owned_Pet_Belongs (
    pouname VARCHAR(50) NOT NULL REFERENCES PetOwner(username) ON DELETE CASCADE,
    petType VARCHAR(20) NOT NULL REFERENCES Category(petType),
    petName VARCHAR(20) NOT NULL,
    petAge INTEGER NOT NULL,
    requirements VARCHAR(50) DEFAULT NULL,
    PRIMARY KEY (pouname, petName, petType)
);

/* TODO: reference has_availability */ 
CREATE TABLE Bid (
    pouname VARCHAR(50),
    petName VARCHAR(20), 
    petType VARCHAR(20),
    ctuname VARCHAR(50),
    s_time TIMESTAMP,
    e_time TIMESTAMP,
    is_win BOOLEAN DEFAULT FALSE,
    rating INTEGER CHECK((rating IS NULL) OR (rating >= 0 AND rating <= 5)),
    review VARCHAR(100),
    pay_type VARCHAR(50) CHECK((pay_type IS NULL) OR (pay_type = 'credit card') OR (pay_type = 'cash')),
    pay_status BOOLEAN DEFAULT FALSE,
    pet_pickup VARCHAR(50) CHECK(pet_pickup = 'poDeliver' OR pet_pickup = 'ctPickup' OR pet_pickup = 'transfer'),
    FOREIGN KEY (pouname, petName, petType) REFERENCES Owned_Pet_Belongs(pouname, petName, petType),
    FOREIGN KEY (ctuname, s_time, e_time) REFERENCES Has_Availability (ctuname, s_time, e_time),
    PRIMARY KEY (pouname, petName, petType, ctuname, s_time, e_time),
    CHECK (pouname <> ctuname)
);

/*TRIGGERS AND PROCEDURE*/
CREATE OR REPLACE PROCEDURE
    add_petOwner(uName VARCHAR(50), oName VARCHAR(50), oAge INTEGER, pType VARCHAR(20), pName VARCHAR(20),
        pAge INTEGER, req VARCHAR(50)) AS
        $$
        DECLARE ctx NUMERIC;
        BEGIN
            SELECT COUNT(*) INTO ctx FROM PetOwner
                WHERE PetOwner.username = uName;
            IF ctx = 0 THEN
                INSERT INTO PetOwner VALUES (uName, oName, oAge);
            END IF;
            INSERT INTO Owned_Pet_Belongs VALUES (uName, pType, pName, pAge, req);
        END;
        $$
    LANGUAGE plpgsql;

/* Insert into fulltimers, will add into caretakers table */
CREATE OR REPLACE PROCEDURE add_fulltimers(
    ctuname VARCHAR(50),
    aname VARCHAR(50),
    age   INTEGER,
    petType VARCHAR(20),
    price INTEGER,
    rating INTEGER DEFAULT NULL,
    salary INTEGER DEFAULT NULL,
    period1  VARCHAR(50) DEFAULT NULL, 
    period2  VARCHAR(50) DEFAULT NULL
    )  AS $$
    DECLARE ctx NUMERIC;
    BEGIN
            SELECT COUNT(*) INTO ctx FROM FullTimer
                WHERE FullTimer.username = ctuname;
            IF ctx = 0 THEN
                INSERT INTO CareTaker VALUES (ctuname, aname, age, rating, salary);
                INSERT INTO FullTimer VALUES (ctuname, period1, period2);
            END IF;
            INSERT INTO Cares VALUES (ctuname, petType, price);
    END;$$
LANGUAGE plpgsql;

/* add parttime */
CREATE OR REPLACE PROCEDURE add_parttimers(
    ctuname VARCHAR(50),
    aname VARCHAR(50),
    age   INTEGER,
    petType VARCHAR(20),
    price INTEGER,
    rating INTEGER DEFAULT NULL,
    salary INTEGER DEFAULT NULL
    )  AS $$
    DECLARE ctx NUMERIC;
    BEGIN
        SELECT COUNT(*) INTO ctx FROM PartTimer
                WHERE PartTimer.username = ctuname;
        IF ctx = 0 THEN
            INSERT INTO CareTaker VALUES (ctuname, aname, age, rating, salary);
            INSERT INTO PartTimer VALUES (ctuname);
        END IF;
        INSERT INTO Cares VALUES (ctuname, petType, price);
    END;$$
LANGUAGE plpgsql;

/* check if caretaker is not already part of PartTimer or FullTimer. To fulfill the no-overlap constraint */
CREATE OR REPLACE FUNCTION not_parttimer_or_fulltimer()
RETURNS TRIGGER AS
$$ DECLARE Pctx NUMERIC;
    DECLARE Fctx NUMERIC;
    BEGIN
        SELECT COUNT(*) INTO Pctx 
        FROM PartTimer P
        WHERE NEW.username = P.username;

        SELECT COUNT(*) INTO Fctx 
        FROM FullTimer F
        WHERE NEW.username = F.username;

        IF (Pctx > 0 OR Fctx > 0) THEN
            RETURN NULL;
        ELSE 
            RETURN NEW;
        END IF; END; $$
LANGUAGE plpgsql;

CREATE TRIGGER check_fulltimer
BEFORE INSERT OR UPDATE ON CareTaker
FOR EACH ROW EXECUTE PROCEDURE not_parttimer_or_fulltimer();

/* check if parttimer that is being added is not a fulltimer. To fulfill the no-overlap constraint */
CREATE OR REPLACE FUNCTION not_fulltimer()
RETURNS TRIGGER AS
$$ DECLARE ctx NUMERIC;
    BEGIN
        SELECT COUNT(*) INTO ctx 
        FROM FullTimer F
        WHERE NEW.username = F.username;

        IF ctx > 0 THEN
            RETURN NULL;
        ELSE 
            RETURN NEW;
        END IF; END; $$
LANGUAGE plpgsql;

CREATE TRIGGER check_parttimer
BEFORE INSERT OR UPDATE ON PartTimer
FOR EACH ROW EXECUTE PROCEDURE not_fulltimer();

/* check if fulltimer that is being added is not a parttimer. To fulfill the no-overlap constraint */
CREATE OR REPLACE FUNCTION not_parttimer()
RETURNS TRIGGER AS
$$ DECLARE ctx NUMERIC;
    BEGIN
        SELECT COUNT(*) INTO ctx 
        FROM PartTimer P
        WHERE NEW.username = P.username;

        IF ctx > 0 THEN
            RETURN NULL;
        ELSE 
            RETURN NEW;
        END IF; END; $$
LANGUAGE plpgsql;

CREATE TRIGGER check_fulltimer
BEFORE INSERT OR UPDATE ON FullTimer
FOR EACH ROW EXECUTE PROCEDURE not_parttimer();

/* Views */
CREATE OR REPLACE VIEW Users AS (
   SELECT username, carerName, age, rating, salary, true AS is_carer FROM CareTaker
   UNION ALL
   SELECT username, ownerName, age, NULL AS rating, NULL AS salary, false AS is_carer FROM PetOwner
);

CREATE OR REPLACE VIEW Accounts AS (
   SELECT username, adminName, age, NULL AS rating, NULL AS salary, false AS is_carer, true AS is_admin FROM PCSAdmin
   UNION ALL
   SELECT username, carerName, age, rating, salary, true AS is_carer, false AS is_admin FROM CareTaker
   UNION ALL
   SELECT username, ownerName, age, NULL AS rating, NULL AS salary, false AS is_carer, false AS is_admin FROM PetOwner
);

/* SEED */
INSERT INTO PCSAdmin(username, adminName) VALUES ('Red', 'red');

INSERT INTO Category VALUES ('dog'),('cat'),('rabbit'),('big dogs'),('lizard'),('bird');

CALL add_fulltimers('yellowchicken', 'chick', 22, 'bird', 50);
CALL add_fulltimers('purpledog', 'purple', 25, 'dog', 60);
CALL add_fulltimers('redduck', 'ducklings', 20, 'rabbit', 35);

CALL add_parttimers('yellowbird', 'bird', 35, 'cat', 60);
/*this seed is not meant to appear in the database*/
CALL add_fulltimers('yellowbird', 'ducklings', 20, 'lizard', 70);

CALL add_petOwner('johnthebest', 'John', 50, 'dog', 'Fido', 10, NULL);
CALL add_petOwner('marythemess', 'Mary', 25, 'dog', 'Fido', 10, NULL);

INSERT INTO Owned_Pet_Belongs VALUES ('marythemess', 'dog', 'Champ', 10, NULL);
INSERT INTO Owned_Pet_Belongs VALUES ('marythemess', 'cat', 'Meow', 10, NULL);

INSERT INTO Cares VALUES ('yellowchicken', 'rabbit', 40);
INSERT INTO Cares VALUES ('yellowchicken', 'big dogs', 70);
INSERT INTO Cares VALUES ('redduck', 'big dogs', 80);
INSERT INTO Cares VALUES ('yellowbird', 'dog', 50);