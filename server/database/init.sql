DROP TABLE IF EXISTS Bid CASCADE;
DROP TABLE IF EXISTS Owned_Pet CASCADE;
DROP TABLE IF EXISTS PetOwner CASCADE;
DROP TABLE IF EXISTS CareTaker CASCADE;
DROP TABLE IF EXISTS Job CASCADE;
DROP TABLE IF EXISTS Transaction CASCADE;
DROP TABLE IF EXISTS PCSAdmin CASCADE;
DROP TABLE IF EXISTS FullTimer CASCADE;
DROP TABLE IF EXISTS PartTimer CASCADE;
DROP TABLE IF EXISTS Has_Availability CASCADE;

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
    petTypes  TEXT[] NOT NULL,
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

CREATE TABLE Has_Availability (
    username VARCHAR(50) REFERENCES CareTaker(username) ON DELETE CASCADE,
    s_date INTEGER,
    s_time INTEGER,
    e_time INTEGER,
    PRIMARY KEY (username, s_date, s_time, e_time)
);

CREATE TABLE Owned_Pet (
    username VARCHAR(50) NOT NULL REFERENCES PetOwner(username) ON DELETE CASCADE,
    petType VARCHAR(20) NOT NULL,
    petName VARCHAR(20) NOT NULL,
    petAge INTEGER NOT NULL,
    requirements VARCHAR(50) DEFAULT NULL,
    PRIMARY KEY (username, petName)
);

CREATE TABLE Bid (
    carerUsername VARCHAR(50) REFERENCES CareTaker(username),
    ownerUsername VARCHAR(50),
    petName   VARCHAR(20),
    startDate VARCHAR(50) NOT NULL,
    endDate VARCHAR(50) NOT NULL,
    FOREIGN KEY (ownerUsername, petName) REFERENCES Owned_Pet(username, petName),
    PRIMARY KEY (carerUsername, ownerUsername, petname)
);

CREATE TABLE Job (
    ownerUsername VARCHAR(50),
    carerUsername VARCHAR(50) REFERENCES CareTaker(username),
    petName VARCHAR(20),
    startDate VARCHAR(20) NOT NULL,
    endDate VARCHAR(20) NOT NULL,
    transferAmount INTEGER NOT NULL,
    rating VARCHAR(5) DEFAULT NULL,
    FOREIGN KEY (ownerUsername, petName) REFERENCES Owned_Pet(username, petName),
    PRIMARY KEY (ownerUsername, carerUsername, petName, startDate, endDate)
);

CREATE TABLE Transaction (
    ownerUsername VARCHAR(50),
    carerUsername VARCHAR(50),
    petName VARCHAR(20),
    startDate VARCHAR(20),
    endDate VARCHAR(20),
    paymentMethod VARCHAR(20) NOT NULL,
    dateTime VARCHAR(30) NOT NULL,
    status VARCHAR(20) DEFAULT 'incomplete',
    FOREIGN KEY (ownerUsername, carerUsername, petName, startDate, endDate)
        REFERENCES Job(ownerUsername, carerUsername, petName, startDate, endDate)
        ON DELETE CASCADE,
    PRIMARY KEY (ownerUsername, carerUsername, petName, startDate, endDate, dateTime)
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
            INSERT INTO Owned_Pet VALUES (uName, pType, pName, pAge, req);
        END;
        $$
    LANGUAGE plpgsql;

/* Insert into fulltimers, will add into caretakers table */
CREATE OR REPLACE PROCEDURE add_fulltimers(
    username VARCHAR(50),
    aname VARCHAR(50),
    age   INTEGER,
    atype  TEXT[] DEFAULT NULL,
    rating INTEGER DEFAULT NULL,
    salary INTEGER DEFAULT NULL,
    period1  VARCHAR(50) DEFAULT NULL, 
    period2  VARCHAR(50) DEFAULT NULL
    )  AS $$
    BEGIN
        INSERT INTO CareTaker VALUES (username, aname, age, atype,rating,salary);
        INSERT INTO FullTimer VALUES(username, period1, period2);
    END;$$
LANGUAGE plpgsql;

/* add parttime */
CREATE OR REPLACE PROCEDURE add_parttimers(
    username VARCHAR(50),
    aname VARCHAR(50),
    age   INTEGER,
    atype  TEXT[] DEFAULT NULL,
    rating INTEGER DEFAULT NULL,
    salary INTEGER DEFAULT NULL
    )  AS $$
    BEGIN
        INSERT INTO CareTaker VALUES (username, aname, age, atype,rating,salary);
        INSERT INTO PartTimer VALUES (username);
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
   SELECT username, carerName, age FROM CareTaker
   UNION
   SELECT username, ownerName, age FROM PetOwner
);

CREATE OR REPLACE VIEW Account AS (
   SELECT username, adminName, age FROM PCSAdmin
   UNION
   SELECT username, carerName, age FROM CareTaker
   UNION
   SELECT username, ownerName, age FROM PetOwner
);

/* SEED */
INSERT INTO PCSAdmin VALUES ('Red', 'red');

CALL add_fulltimers('yellowchicken', 'chick', 22, '{"dog", "cat"}');
CALL add_fulltimers('purpledog', 'purple', 25, '{"cat"}', 8);
CALL add_fulltimers('redduck', 'ducklings', 20, '{"rabbit", "cat"}', 6);

CALL add_fulltimers('purplefish', 'fish', 30, '{"cat"}', 8);
CALL add_fulltimers('yellowbird', 'ducklings', 20, '{"rabbit", "cat"}', 6);

CALL add_petOwner('johnthebest', 'John', 50, 'dog', 'Fido', 10, NULL);
CALL add_petOwner('marythemess', 'Mary', 25, 'dog', 'Fido', 10, NULL);

INSERT INTO Owned_Pet VALUES ('marythemess', 'dog', 'Champ', 10, NULL);
INSERT INTO Owned_Pet VALUES ('marythemess', 'cat', 'Meow', 10, NULL);

INSERT INTO Job VALUES ('marythemess', 'yellowchicken', 'Fido', '101010', '101011', 100, NULL);

INSERT INTO Transaction VALUES ('marythemess', 'yellowchicken', 'Fido', '101010', '101011', 'Credit', '101010T2359');