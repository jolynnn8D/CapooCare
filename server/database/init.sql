DROP TABLE IF EXISTS Bid CASCADE;
DROP TABLE IF EXISTS Category CASCADE;
DROP TABLE IF EXISTS Owned_Pet_Belongs CASCADE;
DROP TABLE IF EXISTS PetOwner CASCADE;
DROP TABLE IF EXISTS CareTaker CASCADE;
DROP TABLE IF EXISTS Job CASCADE;
DROP TABLE IF EXISTS Transaction CASCADE;
DROP TABLE IF EXISTS PCSAdmin CASCADE;

CREATE TABLE PetOwner (
    username VARCHAR(50) PRIMARY KEY,
    aname VARCHAR(50) NOT NULL,
    age   integer NOT NULL
);

-- CREATE OR REPLACE VIEW CareTaker
--     SELECT username, aname, age, rating, salary, atype FROM FullTimer
--     UNION
--     SELECT username, aname, age, rating, salary, atype FROM PartTimer;

CREATE TABLE CareTaker (
    username VARCHAR(50) PRIMARY KEY,
    aname VARCHAR(50) NOT NULL,
    age   integer NOT NULL,
    atype  Text[],
    rating INTEGER,
    salary INTEGER
);

CREATE OR REPLACE VIEW Users AS (
    SELECT (username, aname, age) FROM CareTaker
    UNION
    SELECT (username, aname, age) FROM PetOwner
);

CREATE TABLE PCSAdmin (
    adminName VARCHAR(50) PRIMARY KEY,
    aname VARCHAR(50) NOT NULL,
    age   integer NOT NULL
);

CREATE OR REPLACE VIEW Account AS (
    SELECT (adminName, aname, age) FROM PCSAdmin
    UNION
    SELECT (username, aname, age) FROM Users
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


CREATE OR REPLACE PROCEDURE
    add_petOwner(uName INTEGER, oName VARCHAR(50), pType VARCHAR(20), pName VARCHAR(20),
        pAge INTEGER, req VARCHAR(50)) AS
        $$
        DECLARE ctx NUMERIC;
        BEGIN
            SELECT COUNT(*) INTO ctx FROM PetOwner
                WHERE PetOwner.username = uName;
            IF ctx = 0 THEN
                INSERT INTO PetOwner VALUES (uName, oName);
            END IF;
            INSERT INTO Owned_Pet_Belongs VALUES (uName, pType, pName, pAge, req);
        END;
        $$
    LANGUAGE plpgsql;

CREATE TABLE Bid (
--    caretakerid SERIAL REFERENCES CareTaker(accountId),
--    petownerid  SERIAL,
    carerUsername VARCHAR(50) REFERENCES CareTaker(username),
    ownerUsername VARCHAR(50) REFERENCES PetOwner(username),
    petname   VARCHAR(20),
    startDate VARCHAR(50) NOT NULL,
    endDate VARCHAR(50) NOT NULL,
    FOREIGN KEY (ownerUsername, petname) REFERENCES Owned_Pet_Belongs(username, petname),
    PRIMARY KEY (carerUsername, ownerUsername, petname)
);


CREATE TABLE Category (
    petType VARCHAR(20) UNIQUE NOT NULL
);

CREATE TABLE Owned_Pet_Belongs (
    username INTEGER NOT NULL REFERENCES PetOwner(username) ON DELETE CASCADE,
    petType VARCHAR(20) NOT NULL REFERENCES Category(petType),
    petName VARCHAR(20) NOT NULL,
    petAge INTEGER NOT NULL,
    requirements VARCHAR(50),
    PRIMARY KEY (username, petName)
);

CREATE TABLE Job (
    ownerUsername INTEGER,
    carerUsername INTEGER REFERENCES CareTaker(username),
    petName VARCHAR(20),
    startDate VARCHAR(20) NOT NULL,
    endDate VARCHAR(20) NOT NULL,
    transferAmount INTEGER NOT NULL,
    rating VARCHAR(5),
    FOREIGN KEY (ownerUsername, petName) REFERENCES Owned_Pet_Belongs(username, petName),
    PRIMARY KEY (ownerUsername, carerUsername, petName, startDate, endDate)
);

CREATE TABLE Transaction (
    ownerUsername INTEGER,
    carerUsername INTEGER,
    petName VARCHAR(20),
    startDate VARCHAR(20),
    endDate VARCHAR(20),
    paymentMethod VARCHAR(20) NOT NULL,
    datetime VARCHAR(30) NOT NULL,
    status VARCHAR(20) DEFAULT 'incomplete',
    FOREIGN KEY (ownerUsername, carerUsername, petName, startDate, endDate)
        REFERENCES Job(ownerUsername, carerUsername, petName, startDate, endDate)
        ON DELETE CASCADE,
    PRIMARY KEY (ownerUsername, carerUsername, petName, startDate, endDate, datetime)
);


--/* SEED */
INSERT INTO PCSAdmin VALUES ('Red', 'red', 20);

INSERT INTO CareTaker(username, aname, age) VALUES ('yellowchicken', 'chick', 22);
INSERT INTO CareTaker(username, aname, age) VALUES ('redduck', 'ducklings', 21);
INSERT INTO CareTaker(username, aname, age, atype) VALUES ('purpledog', 'purple', '25', '{"dog", "cat"}');

INSERT INTO Category VALUES ('dog');
INSERT INTO Category VALUES ('cat');

CALL add_petOwner(1, 'John', 'dog', 'Fido', 10, NULL);
CALL add_petOwner(2, 'Mary', 'dog', 'Fido', 10, NULL);

INSERT INTO CareTaker VALUES (1, 'Luke');

INSERT INTO Owned_Pet_Belongs VALUES (2, 'dog', 'Champ', 10, NULL);
INSERT INTO Owned_Pet_Belongs VALUES (2, 'cat', 'Meow', 10, NULL);

INSERT INTO Job VALUES (2, 1, 'Fido', '101010', '101011', 100, NULL);

INSERT INTO Transaction VALUES (2, 1, 'Fido', '101010', '101011', 'Credit', '101010T2359')
