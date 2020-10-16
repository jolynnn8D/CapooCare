DROP TABLE IF EXISTS Bid CASCADE;
DROP TABLE IF EXISTS Category CASCADE;
DROP TABLE IF EXISTS Owned_Pet_Belongs CASCADE;
DROP TABLE IF EXISTS PetOwner CASCADE;

CREATE OR REPLACE PROCEDURE
    add_petOwner(accId INTEGER, oName VARCHAR(50), pType VARCHAR(20), pName VARCHAR(20),
        pAge INTEGER, req VARCHAR(50)) AS
        $$
        DECLARE ctx NUMERIC;
        BEGIN
            SELECT COUNT(*) INTO ctx FROM PetOwner
                WHERE PetOwner.accountId = accId;
            IF ctx = 0 THEN
                INSERT INTO PetOwner VALUES (accId, oName);
            END IF;
            INSERT INTO Owned_Pet_Belongs VALUES (accId, pType, pName, pAge, req);
        END;
        $$
    LANGUAGE plpgsql;

CREATE TABLE Bid (
    startDate VARCHAR(50) NOT NULL,
    endDate VARCHAR(50) NOT NULL
);

CREATE TABLE PetOwner (
    accountId INTEGER PRIMARY KEY,
    ownerName VARCHAR(50) NOT NULL
);

CREATE TABLE Category (
    petType VARCHAR(20) UNIQUE NOT NULL
);

CREATE TABLE Owned_Pet_Belongs (
    accountId INTEGER NOT NULL REFERENCES PetOwner(accountId) ON DELETE CASCADE,
    petType VARCHAR(20) NOT NULL REFERENCES Category(petType),
    petName VARCHAR(20) NOT NULL,
    petAge INTEGER NOT NULL,
    requirements VARCHAR(50),
    PRIMARY KEY (accountId, petName, petType)
);

INSERT INTO Category VALUES ('dog');
INSERT INTO Category VALUES ('cat');

CALL add_petOwner(1, 'John', 'dog', 'Fido', 10, NULL);
CALL add_petOwner(2, 'Mary', 'dog', 'Fido', 10, NULL);

INSERT INTO Owned_Pet_Belongs VALUES (2, 'dog', 'Champ', 10, NULL);
INSERT INTO Owned_Pet_Belongs VALUES (2, 'cat', 'Fido', 10, NULL);
INSERT INTO Owned_Pet_Belongs VALUES (2, 'cat', 'Meow', 20, NULL);
