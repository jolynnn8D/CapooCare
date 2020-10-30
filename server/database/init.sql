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
    is_win BOOLEAN DEFAULT NULL,
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


CREATE OR REPLACE FUNCTION mark_bid()
RETURNS TRIGGER AS
$$
DECLARE ctx NUMERIC;
DECLARE pet NUMERIC;
DECLARE matchtype NUMERIC;
DECLARE care NUMERIC;
DECLARE rate NUMERIC;
    BEGIN
        SELECT COUNT(*) INTO pet
            FROM Bid
            WHERE NEW.pouname = Bid.pouname AND NEW.petname = Bid.petname AND Bid.is_win = True AND (NEW.s_time, NEW.e_time) OVERLAPS (Bid.s_time, Bid.e_time);
        SELECT COUNT(*) INTO matchtype
            FROM Cares
            WHERE NEW.ctuname = Cares.ctuname AND NEW.pettype = Cares.pettype;

        IF pet > 0 THEN -- If a winning bid has already been made for the same Pet which overlaps this new Bid
            RAISE EXCEPTION 'This Pet will be taken care of by another caretaker during that period.';
        ELSIF matchtype = 0 THEN -- Else if the caretaker is incapable of taking care of this Pet type
            RAISE EXCEPTION 'This caretaker is unable to take care of that Pet type.';
        END IF;

        SELECT COUNT(*) INTO ctx
            FROM FullTimer F
            WHERE NEW.ctuname = F.username;
        SELECT COUNT(*) INTO care
            FROM Bid
            WHERE NEW.ctuname = Bid.ctuname AND Bid.is_win = True AND (NEW.s_time, NEW.e_time) OVERLAPS (Bid.s_time, Bid.e_time);

        IF ctx > 0 THEN -- If CT is a fulltimer
            IF care >= 5 AND NEW.is_win = True THEN -- If marking this Bid would exceed the capacity of the caretaker, abort
                RAISE EXCEPTION 'This caretaker has exceeded their capacity.';
            ELSE -- Otherwise, continue as-per normal
                RETURN NEW;
            END IF;
        ELSE -- If CT is a parttimer
            SELECT AVG(rating) INTO rate
                FROM Caretaker AS C
                WHERE NEW.ctuname = C.username;
            IF rate IS NULL OR rate < 4 THEN
                IF care >= 2 AND NEW.is_win = True THEN
                    RAISE EXCEPTION 'This caretaker has exceeded their capacity.';
                ELSE
                    RETURN NEW;
                END IF;
            ELSE
                IF care >= 5 AND NEW.is_win = True THEN
                    RAISE EXCEPTION 'This caretaker has exceeded their capacity.';
                ELSE
                    RETURN NEW;
                END IF;
            END IF;
        END IF;
    END; $$
LANGUAGE plpgsql;

CREATE TRIGGER validate_bid_marking
BEFORE INSERT OR UPDATE ON Bid
FOR EACH ROW
EXECUTE PROCEDURE mark_bid();


CREATE OR REPLACE FUNCTION mark_other_bids()
RETURNS TRIGGER AS
$$
DECLARE ctx NUMERIC;
DECLARE care NUMERIC;
DECLARE rate NUMERIC;
    BEGIN
        SELECT COUNT(*) INTO ctx
            FROM FullTimer F
            WHERE NEW.ctuname = F.username;
        SELECT COUNT(*) INTO care
            FROM Bid
            WHERE NEW.ctuname = Bid.ctuname AND Bid.is_win = True AND (NEW.s_time, NEW.e_time) OVERLAPS (Bid.s_time, Bid.e_time);

        IF ctx > 0 THEN -- If CT is a fulltimer
            IF care >= 5 THEN -- If marking this Bid would exceed the capacity of the caretaker, automatically cancel all remaining Bids for this Availability
                UPDATE Bid SET is_win = False WHERE NEW.ctuname = Bid.ctuname AND Bid.is_win IS NULL AND NEW.s_time = Bid.s_time AND NEW.e_time = Bid.e_time;
            END IF;
            RETURN NULL;
        ELSE -- If CT is a parttimer
            SELECT AVG(rating) INTO rate
                FROM Caretaker AS C
                WHERE NEW.ctuname = C.username;
            IF rate IS NULL OR rate < 4 THEN
                IF care >= 2 THEN
                    UPDATE Bid SET is_win = False WHERE NEW.ctuname = Bid.ctuname AND Bid.is_win IS NULL AND NEW.s_time = Bid.s_time AND NEW.e_time = Bid.e_time;
                END IF;
                RETURN NULL;
            ELSE
                IF care >= 5 THEN
                    UPDATE Bid SET is_win = False WHERE NEW.ctuname = Bid.ctuname AND Bid.is_win IS NULL AND NEW.s_time = Bid.s_time AND NEW.e_time = Bid.e_time;
                END IF;
                RETURN NULL;
            END IF;
        END IF;
    END; $$
LANGUAGE plpgsql;

CREATE TRIGGER mark_other_bids_false
AFTER INSERT OR UPDATE ON Bid
FOR EACH ROW
EXECUTE PROCEDURE mark_other_bids();


--CREATE OR REPLACE PROCEDURE add_bid(
--    pouname VARCHAR(50),
--    petname VARCHAR(20),
--    pettype VARCHAR(20),
--    ctuname VARCHAR(50),
--    s_time DATE,
--    e_time DATE
--    ) AS
--        $$
--        DECLARE ctx NUMERIC;
--        BEGIN
--            SELECT COUNT(*) INTO ctx FROM Cares
--                WHERE Cares.ctuname = ctuname;
--              TODO: Must ensure that a Bid cannot be created for the same Petowner and Pet with overlapping time periods.
----            RAISE EXCEPTION 'test';
--            IF ctx = 0 THEN
--                RAISE EXCEPTION 'Caretaker is unable to care for this pet type.';
--            END IF;
--            INSERT INTO Bid(pouname, petName, petType, ctuname, s_time, e_time)
--                VALUES (pouname, petname, pettype, ctuname, s_time, e_time)
--                RETURNING *;
--        END;
--        $$
--    LANGUAGE plpgsql;


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
CALL add_petOwner('thomasthetank', 'Tom', 15, 'cat', 'Claw', 10, NULL);

INSERT INTO Owned_Pet_Belongs VALUES ('marythemess', 'big dogs', 'Champ', 10, NULL);
INSERT INTO Owned_Pet_Belongs VALUES ('marythemess', 'cat', 'Meow', 10, NULL);

INSERT INTO Cares VALUES ('yellowchicken', 'rabbit', 40);
INSERT INTO Cares VALUES ('yellowchicken', 'dog', 40);
INSERT INTO Cares VALUES ('yellowchicken', 'big dogs', 70);
INSERT INTO Cares VALUES ('redduck', 'big dogs', 80);
INSERT INTO Cares VALUES ('yellowbird', 'dog', 50);
/* Remove the following line to encounter pet type error */
INSERT INTO Cares VALUES ('yellowbird', 'big dogs', 90);

INSERT INTO Has_Availability VALUES ('yellowchicken', to_timestamp('1000000'), to_timestamp('2000000'));
INSERT INTO Has_Availability VALUES ('yellowbird', to_timestamp('1000000'), to_timestamp('4000000'));
INSERT INTO Has_Availability VALUES ('yellowbird', to_timestamp('2000000'), to_timestamp('4000000'));
INSERT INTO Has_Availability VALUES ('yellowbird', to_timestamp('3000000'), to_timestamp('4000000'));

INSERT INTO Bid VALUES ('johnthebest', 'Fido', 'dog', 'yellowchicken', to_timestamp('1000000'), to_timestamp('2000000'));

/* Expected outcome: 'marythemess' wins both bids at timestamp 1-4 and 2-4. This causes 'johnthebest' to lose the 2-4
    bid. The 1-4 bid by 'johnthebest' that is inserted afterwards immediately loses as well, since 'yellowbird' has
    reached their maximum capacity already.*/
INSERT INTO Bid VALUES ('marythemess', 'Fido', 'dog', 'yellowbird', to_timestamp('1000000'), to_timestamp('4000000'));
INSERT INTO Bid VALUES ('marythemess', 'Champ', 'big dogs', 'yellowbird', to_timestamp('2000000'), to_timestamp('4000000'));
INSERT INTO Bid VALUES ('johnthebest', 'Fido', 'dog', 'yellowbird', to_timestamp('2000000'), to_timestamp('4000000'));
INSERT INTO Bid VALUES ('marythemess', 'Meow', 'cat', 'yellowbird', to_timestamp('3000000'), to_timestamp('4000000'));
UPDATE Bid SET is_win = True WHERE ctuname = 'yellowbird' AND pouname = 'marythemess' AND petname = 'Fido' AND pettype = 'dog' AND s_time = to_timestamp('1000000') AND e_time = to_timestamp('4000000');
UPDATE Bid SET is_win = True WHERE ctuname = 'yellowbird' AND pouname = 'marythemess' AND petname = 'Champ' AND pettype = 'big dogs' AND s_time = to_timestamp('2000000') AND e_time = to_timestamp('4000000');
INSERT INTO Bid VALUES ('johnthebest', 'Fido', 'dog', 'yellowbird', to_timestamp('1000000'), to_timestamp('4000000'));
