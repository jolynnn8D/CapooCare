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
    adminName VARCHAR(50) PRIMARY KEY,
    aname VARCHAR(50) NOT NULL,
    age   INTEGER NOT NULL
);

CREATE TABLE PetOwner (
    username VARCHAR(50) PRIMARY KEY,
    aname VARCHAR(50) NOT NULL,
    age   INTEGER NOT NULL
);

CREATE TABLE CareTaker (
    username VARCHAR(50) PRIMARY KEY,
    aname VARCHAR(50) NOT NULL,
    age   INTEGER NOT NULL,
    atype  TEXT[],
    rating INTEGER,
    salary INTEGER
);

CREATE TABLE FullTimer (
    username VARCHAR(50) PRIMARY KEY REFERENCES CareTaker(username),
    period1  VARCHAR(50),
    period2  VARCHAR(50)
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
    requirements VARCHAR(50),
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
    rating VARCHAR(5),
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


/* SEED */
INSERT INTO PCSAdmin VALUES ('Red', 'red', 20);

INSERT INTO CareTaker(username, aname, age) VALUES ('yellowchicken', 'chick', 22);
INSERT INTO CareTaker(username, aname, age) VALUES ('redduck', 'ducklings', 21);
INSERT INTO CareTaker(username, aname, age, atype) VALUES ('purpledog', 'purple', '25', '{"dog", "cat"}');

CALL add_petOwner('johnthebest', 'John', 50, 'dog', 'Fido', 10, NULL);
CALL add_petOwner('marythemess', 'Mary', 25, 'dog', 'Fido', 10, NULL);

INSERT INTO Owned_Pet VALUES ('marythemess', 'dog', 'Champ', 10, NULL);
INSERT INTO Owned_Pet VALUES ('marythemess', 'cat', 'Meow', 10, NULL);

INSERT INTO Job VALUES ('marythemess', 'yellowchicken', 'Fido', '101010', '101011', 100, NULL);

INSERT INTO Transaction VALUES ('marythemess', 'yellowchicken', 'Fido', '101010', '101011', 'Credit', '101010T2359');


----/* Views */
--CREATE OR REPLACE VIEW Users AS (
--    SELECT username, aname, age FROM CareTaker
--    UNION
--    SELECT username, aname, age FROM PetOwner
--);
--
--CREATE OR REPLACE VIEW Account AS (
--    SELECT adminName, aname, age FROM PCSAdmin
--    UNION
--    SELECT username, aname, age FROM CareTaker
--    UNION
--    SELECT username, aname, age FROM PetOwner
--);
