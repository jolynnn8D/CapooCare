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
    age   INTEGER DEFAULT NULL,
    salary INTEGER DEFAULT NULL
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
    s_time DATE,
    e_time DATE,
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

/*TRIGGERS AND PROCEDURE*/
------------------------------------------------ Pet Owner ------------------------------------------------------------
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

------------------------------------------------ CareTaker ------------------------------------------------------------

/* This procedure is used to add 
    - New fulltimers
    - Existing fulltimers' new availabilities (availabilities must be two periods of at least 150 days each within a year)
*/

CREATE OR REPLACE PROCEDURE add_fulltimer(
    ctuname VARCHAR(50),
    aname VARCHAR(50),
    age   INTEGER,
    pettype VARCHAR(20),
    price INTEGER,
    period1_s DATE, 
    period1_e DATE, 
    period2_s DATE,
    period2_e DATE
    )  AS $$
    DECLARE ctx NUMERIC;
    DECLARE period1 NUMERIC;
    DECLARE period2 NUMERIC;
    DECLARE t_period NUMERIC;
    BEGIN
        -- check if both periods overlap
        IF (period1_s, period1_e) OVERLAPS (period2_s, period2_e) THEN
            RAISE EXCEPTION 'Invalid periods: Periods are overlapping.';
        ELSE
            SELECT (period1_e - period1_s + 1) AS DAYS INTO period1;
            SELECT (period2_e - period2_s + 1) AS DAYS INTO period2;
            IF (period1 < 150 OR period2 < 150) THEN
                RAISE EXCEPTION 'Invalid periods: Less than 150 days.';
            END IF;
            SELECT (period2_e - period1_s + 1) AS DAYS INTO t_period;
            IF (t_period > 365) THEN
                RAISE EXCEPTION 'Invalid periods: Periods are not within a year.';
            ELSE
                SELECT COUNT(*) INTO ctx FROM FullTimer WHERE FullTimer.username = ctuname;
                IF ctx = 0 THEN
                    INSERT INTO CareTaker VALUES (ctuname, aname, age, null);
                    INSERT INTO FullTimer VALUES (ctuname);
                    INSERT INTO Cares VALUES (ctuname, pettype, price);
                END IF;
                INSERT INTO Has_Availability VALUES (ctuname, period1_s, period1_e);
                INSERT INTO Has_Availability VALUES (ctuname, period2_s, period2_e);
            END IF;
        END If;
    END;$$
LANGUAGE plpgsql;

/* add parttime */
CREATE OR REPLACE PROCEDURE add_parttimer(
    ctuname VARCHAR(50),
    aname VARCHAR(50),
    age   INTEGER,
    pettype VARCHAR(20),
    price INTEGER,
    salary INTEGER DEFAULT NULL
    )  AS $$
    DECLARE ctx NUMERIC;
    BEGIN
        SELECT COUNT(*) INTO ctx FROM PartTimer
                WHERE PartTimer.username = ctuname;
        IF ctx = 0 THEN
            INSERT INTO CareTaker VALUES (ctuname, aname, age, salary);
            INSERT INTO PartTimer VALUES (ctuname);
        END IF;
        INSERT INTO Cares VALUES (ctuname, pettype, price);
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
            RAISE EXCEPTION 'This username belongs to an existing caretaker.';
        ELSE 
            RETURN NEW;
        END IF; END; $$
LANGUAGE plpgsql;

CREATE TRIGGER check_fulltimer
BEFORE INSERT ON CareTaker
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
            RAISE EXCEPTION 'This username belongs to an existing fulltimer.';
        ELSE 
            RETURN NEW;
        END IF; END; $$
LANGUAGE plpgsql;

CREATE TRIGGER check_parttimer
BEFORE INSERT ON PartTimer
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
            RAISE EXCEPTION 'This username belongs to an existing parttimer.';
        ELSE 
            RETURN NEW;
        END IF; END; $$
LANGUAGE plpgsql;

CREATE TRIGGER check_fulltimer
BEFORE INSERT ON FullTimer
FOR EACH ROW EXECUTE PROCEDURE not_parttimer();

---------------------------------------------------------- Cares ------------------------------------------------------------
/* Checks if the price of FT is the same as base price set by PCSadmine for each category */

CREATE OR REPLACE FUNCTION check_ft_cares_price()
RETURNS TRIGGER AS
$$ BEGIN
        IF (SELECT 1 WHERE EXISTS (SELECT 1 FROM FullTimer WHERE NEW.ctuname = FullTimer.username)) THEN
        
            IF (NEW.price <> (SELECT base_price FROM Category WHERE Category.pettype = NEW.pettype)) THEN
                RAISE EXCEPTION 'Cares prices for Fulltimers must adhere to the basic prices set by PCSadmin.';
            ELSE
                RETURN NEW;
            END IF;
        ELSE
            RETURN NEW;
        END IF;
    END; $$
LANGUAGE plpgsql;

CREATE TRIGGER check_ft_cares_price
BEFORE INSERT ON Cares
FOR EACH ROW EXECUTE PROCEDURE check_ft_cares_price();

------------------------------------------------------------ Bid ------------------------------------------------------------

CREATE OR REPLACE FUNCTION mark_bid_automatically_for_fulltimer()
RETURNS TRIGGER AS
$$
DECLARE ft NUMERIC;
DECLARE bidcount NUMERIC;
    BEGIN
        -- Automatically attempt to mark bid if caretaker is a fulltimer and can do so
        SELECT COUNT(*) INTO ft
            FROM FullTimer F
            WHERE NEW.ctuname = F.username;
        SELECT COUNT(*) INTO bidcount
            FROM Bid
            WHERE NEW.ctuname = Bid.ctuname AND Bid.is_win = True AND (NEW.s_time, NEW.e_time) OVERLAPS (Bid.s_time, Bid.e_time);
        IF ft > 0 THEN
            -- If the Fulltimer has capacity
            IF bidcount < 5 THEN
                UPDATE Bid SET is_win = True WHERE ctuname = NEW.ctuname AND pouname = NEW.pouname AND petname = NEW.petname
                    AND pettype = NEW.pettype AND s_time = NEW.s_time AND e_time = NEW.e_time;
            ELSE
                UPDATE Bid SET is_win = False WHERE ctuname = NEW.ctuname AND pouname = NEW.pouname AND petname = NEW.petname
                    AND pettype = NEW.pettype AND s_time = NEW.s_time AND e_time = NEW.e_time;
            END IF;
        END IF;
        RETURN NEW;
    END; $$
LANGUAGE plpgsql;

CREATE TRIGGER fulltimer_automatic_mark_upon_insert
AFTER INSERT ON Bid
FOR EACH ROW
EXECUTE PROCEDURE mark_bid_automatically_for_fulltimer();


CREATE OR REPLACE FUNCTION validate_mark()
RETURNS TRIGGER AS
$$
DECLARE ctx NUMERIC;
DECLARE pet NUMERIC;
DECLARE matchtype NUMERIC;
DECLARE care NUMERIC;
DECLARE rate NUMERIC;
    BEGIN
        -- Since this is a mark-validating trigger, if the Bid has already been marked, then return
        IF OLD.is_win = True THEN
            RETURN NEW;
        END IF;

        -- Check if the Pet will already be cared for by a Caretaker during this period
        SELECT COUNT(*) INTO pet
            FROM Bid
            WHERE NEW.pouname = Bid.pouname AND NEW.petname = Bid.petname AND Bid.is_win = True
              AND (NEW.s_time, NEW.e_time) OVERLAPS (Bid.s_time, Bid.e_time);

        -- Check if the Caretaker is able to care for the Pet type
        SELECT COUNT(*) INTO matchtype
            FROM Cares
            WHERE NEW.ctuname = Cares.ctuname AND NEW.pettype = Cares.pettype;

        IF pet > 0 THEN -- If a winning bid has already been made for the same Pet which overlaps this new Bid
            RAISE EXCEPTION 'This Pet will be taken care of by another caretaker during that period.';
        ELSIF matchtype = 0 THEN -- Else if the caretaker is incapable of taking care of this Pet type
            RAISE EXCEPTION 'This caretaker is unable to take care of that Pet type.';
        END IF;

        -- Find out if this is a fulltimer, and how many Bids they have won for that period
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
                FROM Bid AS B
                WHERE NEW.ctuname = B.ctuname;
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
EXECUTE PROCEDURE validate_mark();


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
            IF care >= 5 THEN -- If marking this Bid would exceed the capacity of the caretaker, automatically cancel all remaining Bids overlapping this Availability
                UPDATE Bid SET is_win = False WHERE NEW.ctuname = Bid.ctuname AND Bid.is_win IS NULL AND (NEW.s_time, NEW.e_time) OVERLAPS (Bid.s_time, Bid.e_time);
            END IF;
            RETURN NULL;
        ELSE -- If CT is a parttimer
            SELECT AVG(rating) INTO rate
                FROM Bid AS B
                WHERE NEW.ctuname = B.ctuname;
            IF rate IS NULL OR rate < 4 THEN
                IF care >= 2 THEN
                    UPDATE Bid SET is_win = False WHERE NEW.ctuname = Bid.ctuname AND Bid.is_win IS NULL AND (NEW.s_time, NEW.e_time) OVERLAPS (Bid.s_time, Bid.e_time);
                END IF;
                RETURN NULL;
            ELSE
                IF care >= 5 THEN
                    UPDATE Bid SET is_win = False WHERE NEW.ctuname = Bid.ctuname AND Bid.is_win IS NULL AND (NEW.s_time, NEW.e_time) OVERLAPS (Bid.s_time, Bid.e_time);
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

CREATE OR REPLACE FUNCTION check_rating_update()
RETURNS TRIGGER AS
$$
DECLARE avg_rating NUMERIC;
    BEGIN
        -- If updating rating
        IF (NEW.rating IS NOT NULL) THEN
            IF ((SELECT CURRENT_DATE) > NEW.e_time) THEN
                IF (NEW.pay_status = TRUE AND NEW.is_win = TRUE) THEN
                    RETURN NEW;
                ELSE
                    RAISE EXCEPTION 'Bids and payment must be successful before ratings or reviews can be updated.';
                END IF;
            ELSE
                RAISE EXCEPTION 'Ratings and reviews cannot be updated before the end of the job.';
            END IF;
        END IF;
        RETURN NEW;
    END; $$
LANGUAGE plpgsql;

CREATE TRIGGER check_rating_update
AFTER UPDATE ON Bid
FOR EACH ROW
EXECUTE PROCEDURE check_rating_update();


CREATE OR REPLACE PROCEDURE add_bid(
    _pouname VARCHAR(50),
    _petname VARCHAR(20),
    _pettype VARCHAR(20),
    _ctuname VARCHAR(50),
    _s_time DATE,
    _e_time DATE,
    _pay_type VARCHAR(20),
    _pet_pickup VARCHAR(20)
    ) AS
        $$
        DECLARE care NUMERIC;
        DECLARE avail NUMERIC;
        DECLARE cost NUMERIC;
        BEGIN
            -- Ensures that the ct can care for this pet type
            SELECT COUNT(*) INTO care
                FROM Cares
                WHERE Cares.ctuname = _ctuname AND Cares.pettype = _pettype;
            IF care = 0 THEN
               RAISE EXCEPTION 'Caretaker is unable to care for this pet type.';
            END IF;

            -- Ensures that ct has availability at this time period
            SELECT COUNT(*) INTO avail
                FROM Has_Availability
                WHERE Has_Availability.ctuname = _ctuname AND (Has_Availability.s_time <= _s_time) AND (Has_Availability.e_time >= _e_time);
            IF avail = 0 THEN
                RAISE EXCEPTION 'Caretaker is unavailable for this period.';
            END IF;

            -- Calculate cost
            SELECT (Cares.price * (_e_time - _s_time + 1)) INTO cost
                FROM Cares
                WHERE Cares.ctuname = _ctuname AND Cares.pettype = _pettype;
            INSERT INTO Bid(pouname, petname, pettype, ctuname, s_time, e_time, cost, pay_type, pet_pickup)
               VALUES (_pouname, _petname, _pettype, _ctuname, _s_time, _e_time, cost, _pay_type, _pet_pickup);
        END;
        $$
    LANGUAGE plpgsql;


/* Views */
CREATE OR REPLACE VIEW Users AS (
   SELECT CASE WHEN C.username IS NULL THEN P.username 
            ELSE C.username END AS username, 
        CASE WHEN C.carername IS NULL THEN P.ownername 
            ELSE C.carername END AS firstname, 
        CASE WHEN C.age IS NULL THEN P.age 
            ELSE C.age END AS age, 
        salary, 
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
   SELECT username, adminName, age, NULL AS salary, false AS is_carer, true AS is_admin FROM PCSAdmin
   UNION ALL
   SELECT username, carerName, age, salary, true AS is_carer, false AS is_admin FROM CareTaker
   UNION ALL
   SELECT username, ownerName, age, NULL AS salary, false AS is_carer, false AS is_admin FROM PetOwner
);

/* SEED */
INSERT INTO PCSAdmin(username, adminName) VALUES ('Red', 'red');
--INSERT INTO PCSAdmin(username, adminName) VALUES ('White', 'white');
--
--/* Setting categories and their base price */
--INSERT INTO Category(pettype, base_price) VALUES ('dog', 60),('cat', 60),('rabbit', 50),('big dogs', 70),('lizard', 60),('bird', 60),('snake', 70),('fish',30);
--
--CALL add_fulltimer('yellowchicken', 'chick', 22, 'bird', 60, '2020-01-01', '2020-05-30', '2020-06-01', '2020-12-20');
--CALL add_fulltimer('purpledog', 'purple', 25, 'dog', 60, '2020-01-01', '2020-05-30', '2020-06-01', '2020-12-20');
--CALL add_fulltimer('redduck', 'ducklings', 20, 'rabbit', 50, '2020-01-01', '2020-05-30', '2020-06-01', '2020-12-20');
--/* add next year periods for redduck FT */
--CALL add_fulltimer('redduck', NULL, NULL, NULL, NULL, '2021-01-01', '2021-05-30', '2021-06-01', '2021-12-20');
--
--CALL add_parttimer('yellowbird', 'bird', 35, 'cat', 60);
--CALL add_parttimer('bluerhino', 'rhino', 28, 'cat', 35);
--CALL add_parttimer('orangedonald', 'bird', 35, 'cat', 60);
--
--CALL add_petOwner('johnthebest', 'John', 50, 'dog', 'Fido', 10, NULL);
--CALL add_petOwner('marythemess', 'Mary', 25, 'dog', 'Fido', 10, NULL);
--CALL add_petOwner('thomasthetank', 'Tom', 15, 'cat', 'Claw', 10, NULL);
--
--INSERT INTO Owned_Pet_Belongs VALUES ('marythemess', 'big dogs', 'Champ', 10, NULL);
--INSERT INTO Owned_Pet_Belongs VALUES ('marythemess', 'big dogs', 'Ruff', 12, 'Hates cats');
--INSERT INTO Owned_Pet_Belongs VALUES ('marythemess', 'big dogs', 'Bark', 14, 'Can be very loud');
--INSERT INTO Owned_Pet_Belongs VALUES ('marythemess', 'cat', 'Meow', 10, NULL);
--INSERT INTO Owned_Pet_Belongs VALUES ('marythemess', 'cat', 'Purr', 15, 'Hates dogs');
--INSERT INTO Owned_Pet_Belongs VALUES ('marythemess', 'cat', 'Sneak', 20, 'Needs to go outside a lot');
--INSERT INTO Owned_Pet_Belongs VALUES ('johnthebest', 'fish', 'Bloop', 1, 'Needs to be fed thrice a day');
--INSERT INTO Owned_Pet_Belongs VALUES ('johnthebest', 'snake', 'Hiss', 5, 'Just keep an eye on him');
--
--/* Fulltimers' cares */
--INSERT INTO Cares VALUES ('yellowchicken', 'rabbit', 50);
--INSERT INTO Cares VALUES ('yellowchicken', 'dog', 60);
--INSERT INTO Cares VALUES ('yellowchicken', 'big dogs', 70);
--INSERT INTO Cares VALUES ('yellowchicken', 'cat', 60);
--INSERT INTO Cares VALUES ('redduck', 'big dogs', 70);
--INSERT INTO Cares VALUES ('redduck', 'snake', 70);
--INSERT INTO Cares VALUES ('redduck', 'fish', 30);
----INSERT INTO Cares VALUES ('purpledog', 'big dogs', 70);
--INSERT INTO Cares VALUES ('purpledog', 'cat', 60);
--
--/* Parttimers' Cares */
--INSERT INTO Cares VALUES ('yellowbird', 'dog', 60);
--/* Remove the following line to encounter pet type error */
--INSERT INTO Cares VALUES ('yellowbird', 'big dogs', 90);
--
--INSERT INTO Has_Availability VALUES ('yellowchicken', '2020-01-01', '2020-03-04');
--INSERT INTO Has_Availability VALUES ('yellowchicken', '2021-01-01', '2021-03-04');
--INSERT INTO Has_Availability VALUES ('purpledog', '2021-01-01', '2021-03-04');
--INSERT INTO Has_Availability VALUES ('redduck', '2021-01-01', '2021-03-04');
--INSERT INTO Has_Availability VALUES ('yellowbird', '2021-01-01', '2021-03-04');
--INSERT INTO Has_Availability VALUES ('yellowbird', '2020-06-02', '2020-06-08');
--INSERT INTO Has_Availability VALUES ('yellowbird', '2020-12-04', '2020-12-20');
--INSERT INTO Has_Availability VALUES ('yellowbird', '2020-08-08', '2020-08-10');
--
--CALL add_bid('johnthebest', 'Bloop', 'fish', 'redduck', '2021-01-05', '2021-02-20', 'cash', 'poDeliver');
--CALL add_bid('johnthebest', 'Hiss', 'snake', 'redduck', '2021-01-05', '2021-02-20', 'cash', 'poDeliver');
----UPDATE Bid SET is_win = False WHERE ctuname = 'redduck' AND pouname = 'johnthebest' AND petname = 'Hiss' AND pettype = 'snake' AND s_time = to_date('20210105','YYYYMMDD') AND e_time = to_date('20210220','YYYYMMDD');
--CALL add_bid('marythemess', 'Ruff', 'big dogs', 'yellowbird', '2021-01-05', '2021-02-20', 'cash', 'poDeliver');
--CALL add_bid('marythemess', 'Champ', 'big dogs', 'yellowbird', '2021-01-05', '2021-01-20', 'cash', 'poDeliver');
--UPDATE Bid SET is_win = True WHERE ctuname = 'yellowbird' AND pouname = 'marythemess' AND petname = 'Ruff' AND pettype = 'big dogs' AND s_time = to_date('20210105','YYYYMMDD') AND e_time = to_date('20210220','YYYYMMDD');
--UPDATE Bid SET is_win = True WHERE ctuname = 'yellowbird' AND pouname = 'marythemess' AND petname = 'Champ' AND pettype = 'big dogs' AND s_time = to_date('20210105','YYYYMMDD') AND e_time = to_date('20210120','YYYYMMDD');
--
---- The following test case overloads 'marythemess' with more bids than she can accept
--CALL add_bid('marythemess', 'Meow', 'cat', 'yellowchicken', '2021-01-01', '2021-02-28', NULL, NULL);
--CALL add_bid('marythemess', 'Bark', 'big dogs', 'yellowchicken', '2021-01-01', '2021-02-28', NULL, NULL);
----CALL add_bid('marythemess', 'Champ', 'big dogs', 'purpledog', '2021-02-01', '2021-02-23', 'cash', 'poDeliver');
--CALL add_bid('marythemess', 'Purr', 'cat', 'purpledog', '2021-02-03', '2021-02-22', 'cash', 'ctPickup');
--CALL add_bid('marythemess', 'Champ', 'big dogs', 'yellowchicken', '2021-02-24', '2021-02-28', 'cash', 'poDeliver');
--CALL add_bid('marythemess', 'Ruff', 'big dogs', 'yellowchicken', '2021-02-25', '2021-02-28', 'cash', 'ctPickup');
--CALL add_bid('marythemess', 'Purr', 'cat', 'yellowchicken', '2021-02-26', '2021-02-28', 'cash', 'poDeliver');
--CALL add_bid('marythemess', 'Sneak', 'cat', 'yellowchicken', '2021-02-27', '2021-02-28', 'cash', 'poDeliver');
--
-- The following test case sets up a completed Bid
--CALL add_bid('marythemess', 'Champ', 'big dogs', 'yellowchicken', '2020-02-05', '2020-02-20', 'credit card', 'ctPickup');
--UPDATE Bid SET is_win = true WHERE ctuname = 'yellowchicken' AND pouname = 'marythemess' AND petname = 'Champ'
--    AND pettype = 'big dogs' AND s_time = to_date('20200205','YYYYMMDD') AND e_time = to_date('20200220','YYYYMMDD');
--UPDATE Bid SET pay_type = 'cash', pet_pickup = 'poDeliver', rating = '3', review = 'sample review', pay_status = true
--    WHERE ctuname = 'yellowchicken' AND pouname = 'marythemess' AND petname = 'Champ' AND pettype = 'big dogs'
--    AND s_time = to_date('20200205','YYYYMMDD') AND e_time = to_date('20200220','YYYYMMDD') AND is_win = true;
--
 /* Expected outcome: 'marythemess' wins both bids at timestamp 1-4 and 2-4. This causes 'johnthebest' to lose the 2-4		
     bid. The 1-4 bid by 'johnthebest' that is inserted afterwards immediately loses as well, since 'yellowbird' has		
     reached their maximum capacity already.*/		
--  INSERT INTO Bid VALUES ('marythemess', 'Fido', 'dog', 'yellowbird', to_timestamp('1000000'), to_timestamp('4000000'));		
--  INSERT INTO Bid VALUES ('marythemess', 'Champ', 'big dogs', 'yellowbird', to_timestamp('2000000'), to_timestamp('4000000'));		
--  INSERT INTO Bid VALUES ('johnthebest', 'Fido', 'dog', 'yellowbird', to_timestamp('2000000'), to_timestamp('4000000'));		
--  INSERT INTO Bid VALUES ('marythemess', 'Meow', 'cat', 'yellowbird', to_timestamp('3000000'), to_timestamp('4000000'));

--  UPDATE Bid SET is_win = True WHERE ctuname = 'yellowbird' AND pouname = 'marythemess' AND petname = 'Fido' AND pettype = 'dog' AND s_time = to_timestamp('1000000') AND e_time = to_timestamp('4000000');		
--  UPDATE Bid SET is_win = True WHERE ctuname = 'yellowbird' AND pouname = 'marythemess' AND petname = 'Champ' AND pettype = 'big dogs' AND s_time = to_timestamp('2000000') AND e_time = to_timestamp('4000000');

--  INSERT INTO Bid VALUES ('johnthebest', 'Fido', 'dog', 'yellowbird', to_timestamp('1000000'), to_timestamp('4000000'));

--------------- TEST all_ct query, testing with 'marythemess' at time period 2020-06-01 to 2020-06-06 ---------------------

-- These are to set the ratings for following cts
-- yellow chicken
--CALL add_bid('marythemess', 'Champ', 'big dogs', 'yellowchicken', '2020-02-24', '2020-02-28', 'cash', 'poDeliver');
--UPDATE Bid SET is_win = true WHERE ctuname = 'yellowchicken' AND pouname = 'marythemess' AND petname = 'Champ'
--   AND pettype = 'big dogs' AND s_time = to_date('20200224','YYYYMMDD') AND e_time = to_date('20200228','YYYYMMDD');
--UPDATE Bid SET pay_type = 'cash', pet_pickup = 'poDeliver', rating = '5', review = 'sample review', pay_status = true
--   WHERE ctuname = 'yellowchicken' AND pouname = 'marythemess' AND petname = 'Champ' AND pettype = 'big dogs'
--   AND s_time = to_date('20200224','YYYYMMDD') AND e_time = to_date('20200228','YYYYMMDD') AND is_win = true;
---- yellowbird
--INSERT INTO Has_Availability VALUES ('yellowbird', '2020-01-05', '2020-01-20');
--CALL add_bid('marythemess', 'Champ', 'big dogs', 'yellowbird', '2020-01-05', '2020-01-10', 'cash', 'poDeliver');
--UPDATE Bid SET is_win = true WHERE ctuname = 'yellowbird' AND pouname = 'marythemess' AND petname = 'Champ'
--   AND pettype = 'big dogs' AND s_time = to_date('20200105','YYYYMMDD') AND e_time = to_date('20200110','YYYYMMDD');
--UPDATE Bid SET pay_type = 'cash', pet_pickup = 'poDeliver', rating = '3', review = 'sample review', pay_status = true
--    WHERE ctuname = 'yellowbird' AND pouname = 'marythemess' AND petname = 'Champ' AND pettype = 'big dogs'
--    AND s_time = to_date('20200105','YYYYMMDD') AND e_time = to_date('20200110','YYYYMMDD');
---- purpleddog
--CALL add_bid('marythemess', 'Purr', 'cat', 'purpledog', '2020-02-03', '2020-02-22', 'cash', 'poDeliver');
--UPDATE Bid SET is_win = true WHERE ctuname = 'purpledog' AND pouname = 'marythemess' AND petname = 'Purr'
--   AND pettype = 'cat' AND s_time = to_date('20200203','YYYYMMDD') AND e_time = to_date('20200222','YYYYMMDD');
--UPDATE Bid SET pay_type = 'cash', pet_pickup = 'poDeliver', rating = '1', review = 'sample review', pay_status = true
--   WHERE ctuname = 'purpledog' AND pouname = 'marythemess' AND petname = 'Purr' AND pettype = 'cat'
--   AND s_time = to_date('20200203','YYYYMMDD') AND e_time = to_date('20200222','YYYYMMDD') AND is_win = true;
--
--
--INSERT INTO Has_Availability VALUES ('yellowbird', '2020-06-01', '2020-06-06');
--INSERT INTO Has_Availability VALUES ('yellowchicken', '2020-06-01', '2020-06-06');
--INSERT INTO Has_Availability VALUES ('purpledog', '2020-06-01', '2020-06-06');
--
---- saturation of PT capacity --
--CALL add_bid('marythemess', 'Champ', 'big dogs', 'yellowbird', '2020-06-01', '2020-06-06', 'cash', 'poDeliver');
--UPDATE Bid SET is_win = true WHERE ctuname = 'yellowbird' AND pouname = 'marythemess' AND petname = 'Champ'
--   AND pettype = 'big dogs' AND s_time = to_date('20200601','YYYYMMDD') AND e_time = to_date('20200606','YYYYMMDD');
--CALL add_bid('marythemess', 'Meow', 'cat', 'yellowbird', '2020-06-01', '2020-06-06', 'cash', 'poDeliver');
--UPDATE Bid SET is_win = true WHERE ctuname = 'yellowbird' AND pouname = 'marythemess' AND petname = 'Meow'
--   AND pettype = 'cat' AND s_time = to_date('20200601','YYYYMMDD') AND e_time = to_date('20200606','YYYYMMDD');













----------- Mock data insertion --------------



-- PetOwner --

insert into PetOwner (username, ownerName, age) values ('rpippin0', 'Rowena Pippin', 29);
insert into PetOwner (username, ownerName, age) values ('gpetrolli1', 'Gwendolin Petrolli', 79);
insert into PetOwner (username, ownerName, age) values ('svorley2', 'Sauncho Vorley', 59);
insert into PetOwner (username, ownerName, age) values ('mgoom3', 'Miriam Goom', null);
insert into PetOwner (username, ownerName, age) values ('ygill4', 'Ysabel Gill', 37);
insert into PetOwner (username, ownerName, age) values ('ljanicijevic5', 'Lyndel Janicijevic', null);
insert into PetOwner (username, ownerName, age) values ('bmcilherran6', 'Byron McIlherran', 63);
insert into PetOwner (username, ownerName, age) values ('eburrass7', 'Eldon Burrass', null);
insert into PetOwner (username, ownerName, age) values ('gpundy8', 'Glen Pundy', 30);
insert into PetOwner (username, ownerName, age) values ('joakhill9', 'June Oakhill', 44);
insert into PetOwner (username, ownerName, age) values ('msladera', 'Merci Slader', null);
insert into PetOwner (username, ownerName, age) values ('rrentelllb', 'Rossie Rentelll', 58);
insert into PetOwner (username, ownerName, age) values ('bubsdallc', 'Bertrando Ubsdall', null);
insert into PetOwner (username, ownerName, age) values ('ljerdond', 'Leif Jerdon', null);
insert into PetOwner (username, ownerName, age) values ('trosee', 'Tierney Rose', 50);
insert into PetOwner (username, ownerName, age) values ('belmsf', 'Beverley Elms', null);
insert into PetOwner (username, ownerName, age) values ('isailorg', 'Ignatius Sailor', 53);
insert into PetOwner (username, ownerName, age) values ('nleh', 'Nicolle Le Franc', null);
insert into PetOwner (username, ownerName, age) values ('mkelleni', 'Matty Kellen', 68);
insert into PetOwner (username, ownerName, age) values ('ncampellij', 'Nelia Campelli', 24);
insert into PetOwner (username, ownerName, age) values ('dendersk', 'Durant Enders', 28);
insert into PetOwner (username, ownerName, age) values ('lwrathalll', 'Leland Wrathall', 78);
insert into PetOwner (username, ownerName, age) values ('mherrerom', 'Melany Herrero', 38);
insert into PetOwner (username, ownerName, age) values ('ljordenn', 'Leelah Jorden', null);
insert into PetOwner (username, ownerName, age) values ('lchancelloro', 'Liv Chancellor', 58);
insert into PetOwner (username, ownerName, age) values ('hbeakesp', 'Herc Beakes', 37);
insert into PetOwner (username, ownerName, age) values ('mpettegreeq', 'Merwin Pettegree', 34);
insert into PetOwner (username, ownerName, age) values ('bpickerinr', 'Boigie Pickerin', 60);
insert into PetOwner (username, ownerName, age) values ('rfritschels', 'Rosa Fritschel', 58);
insert into PetOwner (username, ownerName, age) values ('cbeerst', 'Camila Beers', 52);
insert into PetOwner (username, ownerName, age) values ('fmanktelowu', 'Florette Manktelow', null);
insert into PetOwner (username, ownerName, age) values ('sshurmerv', 'Sancho Shurmer', 19);
insert into PetOwner (username, ownerName, age) values ('abennw', 'Agatha Benn', null);
insert into PetOwner (username, ownerName, age) values ('jlafeex', 'Jessa Lafee', 17);
insert into PetOwner (username, ownerName, age) values ('dpomfrety', 'Diane Pomfret', null);
insert into PetOwner (username, ownerName, age) values ('dlimpkinz', 'Dal Limpkin', 17);
insert into PetOwner (username, ownerName, age) values ('dcordeux10', 'Davide Cordeux', 12);
insert into PetOwner (username, ownerName, age) values ('jsangra11', 'Jenda Sangra', 76);
insert into PetOwner (username, ownerName, age) values ('chens12', 'Chrysler Hens', 37);
insert into PetOwner (username, ownerName, age) values ('lbodham13', 'Lula Bodham', 70);
insert into PetOwner (username, ownerName, age) values ('tbuessen14', 'Tabbi Buessen', 69);
insert into PetOwner (username, ownerName, age) values ('adowrey15', 'Andriana Dowrey', 70);
insert into PetOwner (username, ownerName, age) values ('nlindstrom16', 'Nicky Lindstrom', 49);
insert into PetOwner (username, ownerName, age) values ('sburbudge17', 'Sammy Burbudge', 69);
insert into PetOwner (username, ownerName, age) values ('fmcdugal18', 'Frannie McDugal', null);
insert into PetOwner (username, ownerName, age) values ('smenichini19', 'Sherill Menichini', 55);
insert into PetOwner (username, ownerName, age) values ('aschwandermann1a', 'Andras Schwandermann', 77);
insert into PetOwner (username, ownerName, age) values ('dvacher1b', 'Douglass Vacher', 54);
insert into PetOwner (username, ownerName, age) values ('gwalewski1c', 'Gwenni Walewski', 33);
insert into PetOwner (username, ownerName, age) values ('dle1d', 'Doro Le Gallo', null);
insert into PetOwner (username, ownerName, age) values ('bcordell1e', 'Bride Cordell', null);
insert into PetOwner (username, ownerName, age) values ('jcorrington1f', 'Jemmie Corrington', null);
insert into PetOwner (username, ownerName, age) values ('jvynoll1g', 'Jeffy Vynoll', null);
insert into PetOwner (username, ownerName, age) values ('knutkins1h', 'Kaylil Nutkins', null);
insert into PetOwner (username, ownerName, age) values ('vgilhoolie1i', 'Vittoria Gilhoolie', 46);
insert into PetOwner (username, ownerName, age) values ('cmerrin1j', 'Cary Merrin', 40);
insert into PetOwner (username, ownerName, age) values ('efallis1k', 'Edee Fallis', 40);
insert into PetOwner (username, ownerName, age) values ('vbingell1l', 'Vikky Bingell', null);
insert into PetOwner (username, ownerName, age) values ('mdruitt1m', 'Moll Druitt', 66);
insert into PetOwner (username, ownerName, age) values ('dfewings1n', 'Demetris Fewings', null);
insert into PetOwner (username, ownerName, age) values ('rkop1o', 'Ronny Kop', null);
insert into PetOwner (username, ownerName, age) values ('mswaine1p', 'Meta Swaine', 31);
insert into PetOwner (username, ownerName, age) values ('esterrie1q', 'Evangelia Sterrie', null);
insert into PetOwner (username, ownerName, age) values ('msadgrove1r', 'Mordy Sadgrove', null);
insert into PetOwner (username, ownerName, age) values ('jlyman1s', 'Jabez Lyman', null);
insert into PetOwner (username, ownerName, age) values ('rrawet1t', 'Rosalinde Rawet', 23);
insert into PetOwner (username, ownerName, age) values ('idalligan1u', 'Ingrid Dalligan', 14);
insert into PetOwner (username, ownerName, age) values ('ebourgour1v', 'Elissa Bourgour', 62);
insert into PetOwner (username, ownerName, age) values ('rvarah1w', 'Randie Varah', null);
insert into PetOwner (username, ownerName, age) values ('kglasgow1x', 'Kristos Glasgow', null);
insert into PetOwner (username, ownerName, age) values ('cspurdon1y', 'Chloris Spurdon', 13);
insert into PetOwner (username, ownerName, age) values ('gdebrick1z', 'Gilemette Debrick', null);
insert into PetOwner (username, ownerName, age) values ('lwaything20', 'Lorne Waything', 26);
insert into PetOwner (username, ownerName, age) values ('edewicke21', 'Eben Dewicke', null);
insert into PetOwner (username, ownerName, age) values ('skarby22', 'Stephanus Karby', 22);
insert into PetOwner (username, ownerName, age) values ('dcicerone23', 'Denna Cicerone', null);
insert into PetOwner (username, ownerName, age) values ('rnaisbit24', 'Romola Naisbit', null);
insert into PetOwner (username, ownerName, age) values ('bferris25', 'Brockie Ferris', 58);
insert into PetOwner (username, ownerName, age) values ('vdoe26', 'Vannie Doe', null);
insert into PetOwner (username, ownerName, age) values ('mlavers27', 'Marketa Lavers', 20);
insert into PetOwner (username, ownerName, age) values ('grummins28', 'Gladi Rummins', null);
insert into PetOwner (username, ownerName, age) values ('crope29', 'Claresta Rope', 35);
insert into PetOwner (username, ownerName, age) values ('celvins2a', 'Callean Elvins', 17);
insert into PetOwner (username, ownerName, age) values ('ejojic2b', 'Emmott Jojic', 34);
insert into PetOwner (username, ownerName, age) values ('sfratson2c', 'Stefanie Fratson', null);
insert into PetOwner (username, ownerName, age) values ('bpayley2d', 'Billie Payley', null);
insert into PetOwner (username, ownerName, age) values ('tgetty2e', 'Tades Getty', null);
insert into PetOwner (username, ownerName, age) values ('maron2f', 'Maury Aron', null);
insert into PetOwner (username, ownerName, age) values ('pesby2g', 'Pansie Esby', 44);
insert into PetOwner (username, ownerName, age) values ('dsampson2h', 'Dannel Sampson', 53);
insert into PetOwner (username, ownerName, age) values ('rharbison2i', 'Rhoda Harbison', null);
insert into PetOwner (username, ownerName, age) values ('kcrowch2j', 'Kelley Crowch', null);
insert into PetOwner (username, ownerName, age) values ('irapper2k', 'Isa Rapper', 41);
insert into PetOwner (username, ownerName, age) values ('cducarne2l', 'Corie Ducarne', null);
insert into PetOwner (username, ownerName, age) values ('dpurry2m', 'Dorri Purry', 17);
insert into PetOwner (username, ownerName, age) values ('sduffer2n', 'Sheilakathryn Duffer', null);
insert into PetOwner (username, ownerName, age) values ('lpunch2o', 'Lorin Punch', 11);
insert into PetOwner (username, ownerName, age) values ('lemmins2p', 'Lisetta Emmins', 20);
insert into PetOwner (username, ownerName, age) values ('kperrie2q', 'Katine Perrie', 51);
insert into PetOwner (username, ownerName, age) values ('rcorradi2r', 'Ramsey Corradi', 12);
insert into PetOwner (username, ownerName, age) values ('crickman2s', 'Calhoun Rickman', 60);
insert into PetOwner (username, ownerName, age) values ('isimonel2t', 'Ingar Simonel', null);
insert into PetOwner (username, ownerName, age) values ('kporkiss2u', 'Korney Porkiss', null);
insert into PetOwner (username, ownerName, age) values ('heyer2v', 'Helenka Eyer', 23);
insert into PetOwner (username, ownerName, age) values ('udjordjevic2w', 'Ulberto Djordjevic', 37);
insert into PetOwner (username, ownerName, age) values ('sdeakins2x', 'Sherie Deakins', 47);
insert into PetOwner (username, ownerName, age) values ('oheigl2y', 'Obadias Heigl', 39);
insert into PetOwner (username, ownerName, age) values ('dpluvier2z', 'Dew Pluvier', 62);
insert into PetOwner (username, ownerName, age) values ('klaying30', 'Kennan Laying', null);
insert into PetOwner (username, ownerName, age) values ('eshelp31', 'Ede Shelp', null);
insert into PetOwner (username, ownerName, age) values ('fyesenin32', 'Fredia Yesenin', 30);
insert into PetOwner (username, ownerName, age) values ('smarcroft33', 'Sharyl Marcroft', 78);
insert into PetOwner (username, ownerName, age) values ('kneil34', 'Kathye Neil', null);
insert into PetOwner (username, ownerName, age) values ('nwalkowski35', 'Nara Walkowski', 65);
insert into PetOwner (username, ownerName, age) values ('drameaux36', 'Drud Rameaux', 15);
insert into PetOwner (username, ownerName, age) values ('jdrance37', 'Jermain Drance', null);
insert into PetOwner (username, ownerName, age) values ('sandrejevic38', 'Sophie Andrejevic', null);
insert into PetOwner (username, ownerName, age) values ('cconibere39', 'Clywd Conibere', null);
insert into PetOwner (username, ownerName, age) values ('gvan3a', 'Gardiner Van der Kruis', 64);
insert into PetOwner (username, ownerName, age) values ('anajara3b', 'Albert Najara', 10);
insert into PetOwner (username, ownerName, age) values ('kversey3c', 'Kristien Versey', 20);
insert into PetOwner (username, ownerName, age) values ('pfryman3d', 'Philbert Fryman', null);
insert into PetOwner (username, ownerName, age) values ('cchessil3e', 'Cassius Chessil', null);
insert into PetOwner (username, ownerName, age) values ('dparsand3f', 'Danyette Parsand', 53);
insert into PetOwner (username, ownerName, age) values ('jbenwell3g', 'Jaclin Benwell', null);
insert into PetOwner (username, ownerName, age) values ('awardesworth3h', 'Annabal Wardesworth', 32);
insert into PetOwner (username, ownerName, age) values ('fmac3i', 'Felecia Mac Giolla Pheadair', 17);
insert into PetOwner (username, ownerName, age) values ('ebrody3j', 'Emmet Brody', 74);
insert into PetOwner (username, ownerName, age) values ('ktwomey3k', 'Karena Twomey', 69);
insert into PetOwner (username, ownerName, age) values ('cbewick3l', 'Chuck Bewick', 52);
insert into PetOwner (username, ownerName, age) values ('smaddinon3m', 'Stillmann Maddinon', 23);
insert into PetOwner (username, ownerName, age) values ('yaspin3n', 'Yettie Aspin', 69);
insert into PetOwner (username, ownerName, age) values ('msimonetti3o', 'Milton Simonetti', null);
insert into PetOwner (username, ownerName, age) values ('jbraden3p', 'Jilly Braden', 16);
insert into PetOwner (username, ownerName, age) values ('rorsi3q', 'Rafaelita Orsi', 77);
insert into PetOwner (username, ownerName, age) values ('romara3r', 'Renate O''Mara', null);
insert into PetOwner (username, ownerName, age) values ('rluby3s', 'Raynell Luby', 46);
insert into PetOwner (username, ownerName, age) values ('hgamblin3t', 'Harris Gamblin', null);
insert into PetOwner (username, ownerName, age) values ('jmckern3u', 'Jennifer McKern', null);
insert into PetOwner (username, ownerName, age) values ('mgrigoriev3v', 'Mirella Grigoriev', 42);
insert into PetOwner (username, ownerName, age) values ('mharcombe3w', 'Minta Harcombe', 63);
insert into PetOwner (username, ownerName, age) values ('rskune3x', 'Rhona Skune', 77);
insert into PetOwner (username, ownerName, age) values ('hbarrand3y', 'Hughie Barrand', 80);
insert into PetOwner (username, ownerName, age) values ('jhullot3z', 'Jerrie Hullot', 12);
insert into PetOwner (username, ownerName, age) values ('smccawley40', 'Sidnee McCawley', 32);
insert into PetOwner (username, ownerName, age) values ('rshynn41', 'Rakel Shynn', 36);
insert into PetOwner (username, ownerName, age) values ('cizkovitz42', 'Catlee Izkovitz', 11);
insert into PetOwner (username, ownerName, age) values ('ebullman43', 'Electra Bullman', 66);
insert into PetOwner (username, ownerName, age) values ('mguidini44', 'Melissa Guidini', 37);
insert into PetOwner (username, ownerName, age) values ('rwhorall45', 'Ruth Whorall', null);
insert into PetOwner (username, ownerName, age) values ('cboggs46', 'Chandler Boggs', null);
insert into PetOwner (username, ownerName, age) values ('dwitt47', 'De witt Quinane', null);
insert into PetOwner (username, ownerName, age) values ('yfarenden48', 'Yasmin Farenden', 76);
insert into PetOwner (username, ownerName, age) values ('wdavio49', 'Whitaker Davio', 58);
insert into PetOwner (username, ownerName, age) values ('iadelsberg4a', 'Isabelle Adelsberg', 74);
insert into PetOwner (username, ownerName, age) values ('mbelton4b', 'Marilee Belton', 22);
insert into PetOwner (username, ownerName, age) values ('qmcgougan4c', 'Quillan McGougan', 67);
insert into PetOwner (username, ownerName, age) values ('umackartan4d', 'Ursulina MacKartan', 53);
insert into PetOwner (username, ownerName, age) values ('chumbie4e', 'Clovis Humbie', 51);
insert into PetOwner (username, ownerName, age) values ('aphillot4f', 'Allister Phillot', null);
insert into PetOwner (username, ownerName, age) values ('dfarrance4g', 'Dita Farrance', null);
insert into PetOwner (username, ownerName, age) values ('mwillshee4h', 'Mirilla Willshee', 13);
insert into PetOwner (username, ownerName, age) values ('cthurgood4i', 'Ced Thurgood', 76);
insert into PetOwner (username, ownerName, age) values ('mpithie4j', 'Marlena Pithie', 20);
insert into PetOwner (username, ownerName, age) values ('mmcevilly4k', 'Misty McEvilly', 46);
insert into PetOwner (username, ownerName, age) values ('nkollach4l', 'Nance Kollach', 51);
insert into PetOwner (username, ownerName, age) values ('ecurd4m', 'Eberto Curd', 11);
insert into PetOwner (username, ownerName, age) values ('zlord4n', 'Zeb Lord', null);
insert into PetOwner (username, ownerName, age) values ('ebingley4o', 'Early Bingley', null);
insert into PetOwner (username, ownerName, age) values ('jmarquez4p', 'Jaquenetta Marquez', 44);
insert into PetOwner (username, ownerName, age) values ('dmullany4q', 'Deanna Mullany', 71);
insert into PetOwner (username, ownerName, age) values ('wlemm4r', 'Wally Lemm', null);
insert into PetOwner (username, ownerName, age) values ('tbrigg4s', 'Tory Brigg', 34);
insert into PetOwner (username, ownerName, age) values ('cgladtbach4t', 'Caye Gladtbach', 73);
insert into PetOwner (username, ownerName, age) values ('dbalaizot4u', 'Dorian Balaizot', 16);
insert into PetOwner (username, ownerName, age) values ('borpin4v', 'Brenda Orpin', 65);
insert into PetOwner (username, ownerName, age) values ('gverma4w', 'Gradey Verma', null);
insert into PetOwner (username, ownerName, age) values ('acoverly4x', 'Alon Coverly', 48);
insert into PetOwner (username, ownerName, age) values ('ffoulgham4y', 'Frannie Foulgham', null);
insert into PetOwner (username, ownerName, age) values ('oglavis4z', 'Orly Glavis', 57);
insert into PetOwner (username, ownerName, age) values ('fstickford50', 'Fanechka Stickford', 53);
insert into PetOwner (username, ownerName, age) values ('dbarber51', 'Dietrich Barber', 31);
insert into PetOwner (username, ownerName, age) values ('iandries52', 'Ivette Andries', 75);
insert into PetOwner (username, ownerName, age) values ('nhallows53', 'Neile Hallows', 31);
insert into PetOwner (username, ownerName, age) values ('gbourdel54', 'Georgianne Bourdel', 10);
insert into PetOwner (username, ownerName, age) values ('sdarcy55', 'Shermy d''Arcy', null);
insert into PetOwner (username, ownerName, age) values ('nsalle56', 'Netta Salle', 52);
insert into PetOwner (username, ownerName, age) values ('hcowland57', 'Henrik Cowland', null);
insert into PetOwner (username, ownerName, age) values ('shathaway58', 'Shanna Hathaway', null);
insert into PetOwner (username, ownerName, age) values ('rbratty59', 'Ronica Bratty', null);
insert into PetOwner (username, ownerName, age) values ('llionel5a', 'Lothaire Lionel', 69);
insert into PetOwner (username, ownerName, age) values ('dyandell5b', 'Dayna Yandell', 54);
insert into PetOwner (username, ownerName, age) values ('lgleadle5c', 'Leanna Gleadle', 33);
insert into PetOwner (username, ownerName, age) values ('ashotbolt5d', 'Ambur Shotbolt', 58);
insert into PetOwner (username, ownerName, age) values ('rboss5e', 'Randall Boss', 67);
insert into PetOwner (username, ownerName, age) values ('kdonn5f', 'Kitty Donn', null);
insert into PetOwner (username, ownerName, age) values ('lgulliver5g', 'Lani Gulliver', 61);
insert into PetOwner (username, ownerName, age) values ('hquinell5h', 'Herculie Quinell', 55);
insert into PetOwner (username, ownerName, age) values ('pmoss5i', 'Pauly Moss', 76);
insert into PetOwner (username, ownerName, age) values ('bbrotherhed5j', 'Barry Brotherhed', 75);
insert into PetOwner (username, ownerName, age) values ('mkingston5k', 'Malinda Kingston', null);
insert into PetOwner (username, ownerName, age) values ('pdorney5l', 'Pinchas Dorney', 73);
insert into PetOwner (username, ownerName, age) values ('wshawcroft5m', 'Wittie Shawcroft', 80);
insert into PetOwner (username, ownerName, age) values ('ttraylen5n', 'Tulley Traylen', null);
insert into PetOwner (username, ownerName, age) values ('gspyvye5o', 'George Spyvye', 23);
insert into PetOwner (username, ownerName, age) values ('dfieldstone5p', 'Dollie Fieldstone', 54);
insert into PetOwner (username, ownerName, age) values ('dbrugman5q', 'Donny Brugman', null);
insert into PetOwner (username, ownerName, age) values ('hmacfadyen5r', 'Hillary MacFadyen', 26);
insert into PetOwner (username, ownerName, age) values ('ksouthcoat5s', 'Krystyna Southcoat', null);
insert into PetOwner (username, ownerName, age) values ('hawcock5t', 'Hughie Awcock', 40);
insert into PetOwner (username, ownerName, age) values ('srattenberie5u', 'Standford Rattenberie', 65);
insert into PetOwner (username, ownerName, age) values ('njoust5v', 'Nona Joust', 14);
insert into PetOwner (username, ownerName, age) values ('ctrevascus5w', 'Clemmy Trevascus', 69);
insert into PetOwner (username, ownerName, age) values ('bminer5x', 'Benjy Miner', 79);
insert into PetOwner (username, ownerName, age) values ('abarrell5y', 'Alleen Barrell', 45);
insert into PetOwner (username, ownerName, age) values ('dfruser5z', 'Dominga Fruser', 24);
insert into PetOwner (username, ownerName, age) values ('adeknevet60', 'Adara deKnevet', null);
insert into PetOwner (username, ownerName, age) values ('shatwell61', 'Shanta Hatwell', null);
insert into PetOwner (username, ownerName, age) values ('glambshine62', 'Granny Lamb-shine', null);
insert into PetOwner (username, ownerName, age) values ('clongmate63', 'Cris Longmate', 66);
insert into PetOwner (username, ownerName, age) values ('gburl64', 'Guy Burl', null);
insert into PetOwner (username, ownerName, age) values ('pbeddow65', 'Peria Beddow', 34);
insert into PetOwner (username, ownerName, age) values ('kjansen66', 'Krissy Jansen', 71);
insert into PetOwner (username, ownerName, age) values ('mdottridge67', 'Maurice Dottridge', null);
insert into PetOwner (username, ownerName, age) values ('frobelet68', 'Francois Robelet', 14);
insert into PetOwner (username, ownerName, age) values ('mlillico69', 'Maura Lillico', 56);
insert into PetOwner (username, ownerName, age) values ('ccorneljes6a', 'Cooper Corneljes', null);
insert into PetOwner (username, ownerName, age) values ('blathe6b', 'Brynna Lathe', 10);
insert into PetOwner (username, ownerName, age) values ('mhaile6c', 'Marcos Haile', null);
insert into PetOwner (username, ownerName, age) values ('dtotton6d', 'Donelle Totton', 65);
insert into PetOwner (username, ownerName, age) values ('ascardafield6e', 'Avigdor Scardafield', null);
insert into PetOwner (username, ownerName, age) values ('wcornforth6f', 'Warren Cornforth', null);
insert into PetOwner (username, ownerName, age) values ('dreina6g', 'Dorothea Reina', 54);
insert into PetOwner (username, ownerName, age) values ('fchurchard6h', 'Fayth Churchard', null);
insert into PetOwner (username, ownerName, age) values ('fsnedden6i', 'Foss Snedden', 22);
insert into PetOwner (username, ownerName, age) values ('vrilings6j', 'Vida Rilings', 10);
insert into PetOwner (username, ownerName, age) values ('hpirnie6k', 'Heida Pirnie', 73);
insert into PetOwner (username, ownerName, age) values ('oschapero6l', 'Odelinda Schapero', 56);
insert into PetOwner (username, ownerName, age) values ('rmarmion6m', 'Rochell Marmion', 78);
insert into PetOwner (username, ownerName, age) values ('cchapling6n', 'Caryn Chapling', 54);
insert into PetOwner (username, ownerName, age) values ('ghackelton6o', 'Ginni Hackelton', 59);
insert into PetOwner (username, ownerName, age) values ('tbris6p', 'Tyne Bris', 73);
insert into PetOwner (username, ownerName, age) values ('rliven6q', 'Roarke Liven', null);
insert into PetOwner (username, ownerName, age) values ('tseres6r', 'Torrance Seres', 24);
insert into PetOwner (username, ownerName, age) values ('lnucator6s', 'Ludwig Nucator', 57);
insert into PetOwner (username, ownerName, age) values ('erigts6t', 'Emmery Rigts', null);
insert into PetOwner (username, ownerName, age) values ('iclynman6u', 'Illa Clynman', null);
insert into PetOwner (username, ownerName, age) values ('jmckniely6v', 'Julita McKniely', 17);
insert into PetOwner (username, ownerName, age) values ('fivanchikov6w', 'Freddie Ivanchikov', 36);
insert into PetOwner (username, ownerName, age) values ('kparsons6x', 'Kass Parsons', 49);
insert into PetOwner (username, ownerName, age) values ('wmandifield6y', 'Waiter Mandifield', null);
insert into PetOwner (username, ownerName, age) values ('fdusting6z', 'Filmore Dusting', 18);
insert into PetOwner (username, ownerName, age) values ('mmeake70', 'Morissa Meake', null);
insert into PetOwner (username, ownerName, age) values ('mcroan71', 'Melitta Croan', null);
insert into PetOwner (username, ownerName, age) values ('afreddi72', 'Anette Freddi', null);
insert into PetOwner (username, ownerName, age) values ('rcrosland73', 'Rickard Crosland', 14);
insert into PetOwner (username, ownerName, age) values ('aminci74', 'Ase Minci', 44);
insert into PetOwner (username, ownerName, age) values ('tride75', 'Tracie Ride', 15);
insert into PetOwner (username, ownerName, age) values ('tskeldinge76', 'Theresita Skeldinge', 54);
insert into PetOwner (username, ownerName, age) values ('cbard77', 'Clementius Bard', null);
insert into PetOwner (username, ownerName, age) values ('pjamot78', 'Padriac Jamot', null);
insert into PetOwner (username, ownerName, age) values ('nsanthouse79', 'Nicko Santhouse', 25);
insert into PetOwner (username, ownerName, age) values ('cmarvelley7a', 'Catha Marvelley', 49);
insert into PetOwner (username, ownerName, age) values ('fsansbury7b', 'Freddy Sansbury', 16);
insert into PetOwner (username, ownerName, age) values ('edee7c', 'Elijah Dee', 62);
insert into PetOwner (username, ownerName, age) values ('spossell7d', 'Shawn Possell', null);
insert into PetOwner (username, ownerName, age) values ('afisby7e', 'Alan Fisby', 79);
insert into PetOwner (username, ownerName, age) values ('gcultcheth7f', 'Garrick Cultcheth', null);
insert into PetOwner (username, ownerName, age) values ('bduly7g', 'Barnett Duly', null);
insert into PetOwner (username, ownerName, age) values ('oramberg7h', 'Olimpia Ramberg', 76);
insert into PetOwner (username, ownerName, age) values ('educkett7i', 'Erny Duckett', 14);
insert into PetOwner (username, ownerName, age) values ('bblackleech7j', 'Baryram Blackleech', null);
insert into PetOwner (username, ownerName, age) values ('ksheringham7k', 'Karel Sheringham', null);
insert into PetOwner (username, ownerName, age) values ('jbellison7l', 'Jamie Bellison', 64);
insert into PetOwner (username, ownerName, age) values ('bphilipeau7m', 'Birgit Philipeau', 68);
insert into PetOwner (username, ownerName, age) values ('kfritz7n', 'Khalil Fritz', 25);
insert into PetOwner (username, ownerName, age) values ('hgrinley7o', 'Hetty Grinley', null);
insert into PetOwner (username, ownerName, age) values ('mpaulley7p', 'Mira Paulley', 30);
insert into PetOwner (username, ownerName, age) values ('dblenkinsopp7q', 'Delora Blenkinsopp', 42);
insert into PetOwner (username, ownerName, age) values ('tjouanot7r', 'Tabbi Jouanot', 22);
insert into PetOwner (username, ownerName, age) values ('dbirts7s', 'Dosi Birts', 56);
insert into PetOwner (username, ownerName, age) values ('wguiu7t', 'Wilbert Guiu', null);
insert into PetOwner (username, ownerName, age) values ('vhalbard7u', 'Vance Halbard', 40);
insert into PetOwner (username, ownerName, age) values ('dbenedek7v', 'Delcina Benedek', null);
insert into PetOwner (username, ownerName, age) values ('fridgley7w', 'Frans Ridgley', null);
insert into PetOwner (username, ownerName, age) values ('amora7x', 'Amandie Mora', 37);
insert into PetOwner (username, ownerName, age) values ('vstibbs7y', 'Vern Stibbs', 76);
insert into PetOwner (username, ownerName, age) values ('tmee7z', 'Talya Mee', 26);
insert into PetOwner (username, ownerName, age) values ('lcartner80', 'Lainey Cartner', 73);
insert into PetOwner (username, ownerName, age) values ('rsolway81', 'Rafael Solway', null);
insert into PetOwner (username, ownerName, age) values ('ctandy82', 'Constance Tandy', 25);
insert into PetOwner (username, ownerName, age) values ('tgothup83', 'Tiffy Gothup', 58);
insert into PetOwner (username, ownerName, age) values ('cpirri84', 'Curt Pirri', 45);
insert into PetOwner (username, ownerName, age) values ('sdutchburn85', 'Sela Dutchburn', null);
insert into PetOwner (username, ownerName, age) values ('jeyckelbeck86', 'Jeanna Eyckelbeck', 57);
insert into PetOwner (username, ownerName, age) values ('pmcgonigle87', 'Pierette McGonigle', null);
insert into PetOwner (username, ownerName, age) values ('dsibray88', 'Dell Sibray', 51);
insert into PetOwner (username, ownerName, age) values ('nsculpher89', 'Norrie Sculpher', 20);
insert into PetOwner (username, ownerName, age) values ('blanger8a', 'Bald Langer', 44);
insert into PetOwner (username, ownerName, age) values ('draspel8b', 'Daniele Raspel', 53);
insert into PetOwner (username, ownerName, age) values ('relders8c', 'Reinwald Elders', null);
insert into PetOwner (username, ownerName, age) values ('vcocking8d', 'Veradis Cocking', 73);
insert into PetOwner (username, ownerName, age) values ('rburnes8e', 'Rodi Burnes', 42);
insert into PetOwner (username, ownerName, age) values ('rivashechkin8f', 'Robinson Ivashechkin', 27);
insert into PetOwner (username, ownerName, age) values ('cnelsey8g', 'Chris Nelsey', 76);
insert into PetOwner (username, ownerName, age) values ('atilzey8h', 'Aubert Tilzey', 62);
insert into PetOwner (username, ownerName, age) values ('pmcure8i', 'Pet McUre', 69);
insert into PetOwner (username, ownerName, age) values ('grolfe8j', 'Giacinta Rolfe', 62);
insert into PetOwner (username, ownerName, age) values ('gtosdevin8k', 'Gardie Tosdevin', null);
insert into PetOwner (username, ownerName, age) values ('jfennelly8l', 'Jayson Fennelly', 74);
insert into PetOwner (username, ownerName, age) values ('salcide8m', 'Sara-ann Alcide', 39);
insert into PetOwner (username, ownerName, age) values ('hgarley8n', 'Hermie Garley', 68);
insert into PetOwner (username, ownerName, age) values ('fmccarlie8o', 'Florentia McCarlie', 17);
insert into PetOwner (username, ownerName, age) values ('hkarpenya8p', 'Hubert Karpenya', null);
insert into PetOwner (username, ownerName, age) values ('jvsanelli8q', 'Jada Vsanelli', 21);
insert into PetOwner (username, ownerName, age) values ('rbeirne8r', 'Rebeka Beirne', 43);
insert into PetOwner (username, ownerName, age) values ('sbuckel8s', 'Shalna Buckel', 34);
insert into PetOwner (username, ownerName, age) values ('evasyunichev8t', 'Estel Vasyunichev', 69);
insert into PetOwner (username, ownerName, age) values ('ceyre8u', 'Cherida Eyre', null);
insert into PetOwner (username, ownerName, age) values ('tchaters8v', 'Timmi Chaters', null);
insert into PetOwner (username, ownerName, age) values ('ameecher8w', 'Antonie Meecher', 34);
insert into PetOwner (username, ownerName, age) values ('ede8x', 'Emmye De Normanville', 41);
insert into PetOwner (username, ownerName, age) values ('dboreland8y', 'Dinnie Boreland', 27);
insert into PetOwner (username, ownerName, age) values ('aarp8z', 'Aurthur Arp', 39);
insert into PetOwner (username, ownerName, age) values ('jkerwin90', 'Jobye Kerwin', 53);
insert into PetOwner (username, ownerName, age) values ('hgreenhalf91', 'Hamnet Greenhalf', null);
insert into PetOwner (username, ownerName, age) values ('sparkeson92', 'Susannah Parkeson', 69);
insert into PetOwner (username, ownerName, age) values ('aferrarotti93', 'Alina Ferrarotti', null);
insert into PetOwner (username, ownerName, age) values ('jvan94', 'Jilleen Van der Kruys', 10);
insert into PetOwner (username, ownerName, age) values ('ominall95', 'Odette Minall', 48);
insert into PetOwner (username, ownerName, age) values ('tsaiger96', 'Tandie Saiger', 33);
insert into PetOwner (username, ownerName, age) values ('erodenburgh97', 'Eustacia Rodenburgh', 58);
insert into PetOwner (username, ownerName, age) values ('lduckett98', 'Lucho Duckett', 46);
insert into PetOwner (username, ownerName, age) values ('tgaggen99', 'Thibaud Gaggen', 77);
insert into PetOwner (username, ownerName, age) values ('bivanishchev9a', 'Benetta Ivanishchev', 68);
insert into PetOwner (username, ownerName, age) values ('pbrafield9b', 'Patricia Brafield', 41);
insert into PetOwner (username, ownerName, age) values ('thalls9c', 'Tyler Halls', 49);
insert into PetOwner (username, ownerName, age) values ('hduddle9d', 'Heall Duddle', 17);
insert into PetOwner (username, ownerName, age) values ('gfairchild9e', 'Ginnifer Fairchild', 69);
insert into PetOwner (username, ownerName, age) values ('aashborn9f', 'Alden Ashborn', 51);
insert into PetOwner (username, ownerName, age) values ('mthorns9g', 'Mariele Thorns', 55);
insert into PetOwner (username, ownerName, age) values ('dgowthrop9h', 'Dianna Gowthrop', null);
insert into PetOwner (username, ownerName, age) values ('lsenussi9i', 'Lottie Senussi', null);
insert into PetOwner (username, ownerName, age) values ('ustowers9j', 'Ula Stowers', null);
insert into PetOwner (username, ownerName, age) values ('sburstowe9k', 'Stormi Burstowe', 56);
insert into PetOwner (username, ownerName, age) values ('pstidston9l', 'Pren Stidston', null);
insert into PetOwner (username, ownerName, age) values ('broscow9m', 'Birgit Roscow', 65);
insert into PetOwner (username, ownerName, age) values ('hjoynt9n', 'Hilary Joynt', 59);
insert into PetOwner (username, ownerName, age) values ('jjirzik9o', 'Jacquette Jirzik', 63);
insert into PetOwner (username, ownerName, age) values ('ascripps9p', 'Archibald Scripps', null);
insert into PetOwner (username, ownerName, age) values ('dhuggett9q', 'Diannne Huggett', null);
insert into PetOwner (username, ownerName, age) values ('bblockley9r', 'Bellina Blockley', 22);
insert into PetOwner (username, ownerName, age) values ('gbradforth9s', 'Grenville Bradforth', 75);
insert into PetOwner (username, ownerName, age) values ('dmccaskill9t', 'Dorothy McCaskill', null);
insert into PetOwner (username, ownerName, age) values ('tchell9u', 'Torrin Chell', 40);
insert into PetOwner (username, ownerName, age) values ('gkeddy9v', 'Guss Keddy', 63);
insert into PetOwner (username, ownerName, age) values ('eshilito9w', 'Essa Shilito', 56);
insert into PetOwner (username, ownerName, age) values ('dvannoort9x', 'Demeter Vannoort', 37);
insert into PetOwner (username, ownerName, age) values ('ejanecki9y', 'Erika Janecki', 79);
insert into PetOwner (username, ownerName, age) values ('pverdon9z', 'Phillipp Verdon', 42);
insert into PetOwner (username, ownerName, age) values ('rlightwooda0', 'Reinhold Lightwood', 79);
insert into PetOwner (username, ownerName, age) values ('eingredaa1', 'Edvard Ingreda', null);
insert into PetOwner (username, ownerName, age) values ('wscintsburya2', 'Willi Scintsbury', null);
insert into PetOwner (username, ownerName, age) values ('bmapholma3', 'Bibby Mapholm', null);
insert into PetOwner (username, ownerName, age) values ('msaylea4', 'Marylin Sayle', 25);
insert into PetOwner (username, ownerName, age) values ('mwallwortha5', 'Marve Wallworth', 16);
insert into PetOwner (username, ownerName, age) values ('cscarglea6', 'Chaunce Scargle', 69);
insert into PetOwner (username, ownerName, age) values ('cchestera7', 'Charlean Chester', 39);
insert into PetOwner (username, ownerName, age) values ('revaa8', 'Rockwell Eva', 55);
insert into PetOwner (username, ownerName, age) values ('hlemmertza9', 'Hershel Lemmertz', 26);
insert into PetOwner (username, ownerName, age) values ('imosedillaa', 'Iolande Mosedill', 39);
insert into PetOwner (username, ownerName, age) values ('edahlmanab', 'Ephrayim Dahlman', 72);
insert into PetOwner (username, ownerName, age) values ('mgeneverac', 'Marylou Genever', null);
insert into PetOwner (username, ownerName, age) values ('hcurrerad', 'Hatty Currer', null);
insert into PetOwner (username, ownerName, age) values ('eprandinae', 'Eden Prandin', 72);
insert into PetOwner (username, ownerName, age) values ('rhickenaf', 'Rex Hicken', 36);
insert into PetOwner (username, ownerName, age) values ('dfilippozziag', 'Darcy Filippozzi', 15);
insert into PetOwner (username, ownerName, age) values ('omacredmondah', 'Ofelia MacRedmond', 37);
insert into PetOwner (username, ownerName, age) values ('swoodruffai', 'Sidonia Woodruff', 42);
insert into PetOwner (username, ownerName, age) values ('doaj', 'Dolores O'' Bee', 19);
insert into PetOwner (username, ownerName, age) values ('asimoninak', 'Allene Simonin', 61);
insert into PetOwner (username, ownerName, age) values ('achasieral', 'Anselm Chasier', null);
insert into PetOwner (username, ownerName, age) values ('dhauxleyam', 'Davis Hauxley', 33);
insert into PetOwner (username, ownerName, age) values ('swhaitesan', 'Sherm Whaites', 14);
insert into PetOwner (username, ownerName, age) values ('fswedeao', 'Fidel Swede', null);
insert into PetOwner (username, ownerName, age) values ('jsaintsburyap', 'John Saintsbury', 52);
insert into PetOwner (username, ownerName, age) values ('cpickthornaq', 'Cecilius Pickthorn', null);
insert into PetOwner (username, ownerName, age) values ('vizzatar', 'Veronika Izzat', 43);
insert into PetOwner (username, ownerName, age) values ('cpeskinas', 'Colman Peskin', 23);
insert into PetOwner (username, ownerName, age) values ('aduckhamat', 'Anatollo Duckham', 64);
insert into PetOwner (username, ownerName, age) values ('abemwellau', 'Anastasia Bemwell', 59);
insert into PetOwner (username, ownerName, age) values ('eligertwoodav', 'Elfreda Ligertwood', null);
insert into PetOwner (username, ownerName, age) values ('agollandaw', 'Anet Golland', 59);
insert into PetOwner (username, ownerName, age) values ('hmingaudax', 'Hadleigh Mingaud', 54);
insert into PetOwner (username, ownerName, age) values ('fshiptonay', 'Franciskus Shipton', 74);
insert into PetOwner (username, ownerName, age) values ('dethelstonaz', 'Drusie Ethelston', 61);
insert into PetOwner (username, ownerName, age) values ('jtriggb0', 'Jamal Trigg', null);
insert into PetOwner (username, ownerName, age) values ('gsandayb1', 'Galen Sanday', null);
insert into PetOwner (username, ownerName, age) values ('ieasthopeb2', 'Iseabal Easthope', null);
insert into PetOwner (username, ownerName, age) values ('gdeboickb3', 'Gael Deboick', 38);
insert into PetOwner (username, ownerName, age) values ('sblackshawb4', 'Standford Blackshaw', 71);
insert into PetOwner (username, ownerName, age) values ('cfaucettb5', 'Chaddie Faucett', 70);
insert into PetOwner (username, ownerName, age) values ('rqueenb6', 'Reggy Queen', null);
insert into PetOwner (username, ownerName, age) values ('glanahanb7', 'Ginger Lanahan', 11);
insert into PetOwner (username, ownerName, age) values ('bmccrawb8', 'Benedicto McCraw', 14);
insert into PetOwner (username, ownerName, age) values ('dbowmenb9', 'Danie Bowmen', 77);
insert into PetOwner (username, ownerName, age) values ('lmottenba', 'Lexi Motten', null);
insert into PetOwner (username, ownerName, age) values ('zmalyjbb', 'Zacharie Malyj', 73);
insert into PetOwner (username, ownerName, age) values ('sdochebc', 'Sascha Doche', 33);
insert into PetOwner (username, ownerName, age) values ('mdelahuntbd', 'Merrile Delahunt', 12);
insert into PetOwner (username, ownerName, age) values ('nfouxbe', 'Nona Foux', null);
insert into PetOwner (username, ownerName, age) values ('kmcveaghbf', 'Kayla McVeagh', null);
insert into PetOwner (username, ownerName, age) values ('cjustebg', 'Corilla Juste', 35);
insert into PetOwner (username, ownerName, age) values ('bglaviasbh', 'Braden Glavias', null);
insert into PetOwner (username, ownerName, age) values ('ashireffbi', 'Aleta Shireff', 21);
insert into PetOwner (username, ownerName, age) values ('lwottonbj', 'Leonard Wotton', null);
insert into PetOwner (username, ownerName, age) values ('mmurreybk', 'Mead Murrey', 71);
insert into PetOwner (username, ownerName, age) values ('rmcilraithbl', 'Rahal McIlraith', 50);
insert into PetOwner (username, ownerName, age) values ('dgreavebm', 'Dulsea Greave', 73);
insert into PetOwner (username, ownerName, age) values ('gorchartbn', 'Garland Orchart', null);
insert into PetOwner (username, ownerName, age) values ('eanglissbo', 'Erhard Angliss', 35);
insert into PetOwner (username, ownerName, age) values ('brensbp', 'Bogey Rens', 21);
insert into PetOwner (username, ownerName, age) values ('nbloomanbq', 'Nico Blooman', 50);
insert into PetOwner (username, ownerName, age) values ('kdodellbr', 'Kerrin Dodell', null);
insert into PetOwner (username, ownerName, age) values ('cscrewtonbs', 'Camel Screwton', 49);
insert into PetOwner (username, ownerName, age) values ('xlagadubt', 'Xever Lagadu', null);
insert into PetOwner (username, ownerName, age) values ('jboarderbu', 'Joela Boarder', 70);
insert into PetOwner (username, ownerName, age) values ('smiddlebv', 'Salvidor Middle', 77);
insert into PetOwner (username, ownerName, age) values ('bgwilliamsbw', 'Briana Gwilliams', null);
insert into PetOwner (username, ownerName, age) values ('lmathivonbx', 'Leslie Mathivon', 23);
insert into PetOwner (username, ownerName, age) values ('cpavlataby', 'Cecilio Pavlata', 77);
insert into PetOwner (username, ownerName, age) values ('dmatchellbz', 'Doll Matchell', 70);
insert into PetOwner (username, ownerName, age) values ('flidellc0', 'Fonsie Lidell', 48);
insert into PetOwner (username, ownerName, age) values ('mcattanachc1', 'Marylee Cattanach', 74);
insert into PetOwner (username, ownerName, age) values ('dmarrianc2', 'Deeann Marrian', 62);
insert into PetOwner (username, ownerName, age) values ('samerc3', 'Shirline Amer', null);
insert into PetOwner (username, ownerName, age) values ('rphippinc4', 'Rois Phippin', 44);
insert into PetOwner (username, ownerName, age) values ('rjunkinsonc5', 'Ramsey Junkinson', 44);
insert into PetOwner (username, ownerName, age) values ('lmarttc6', 'Loria Martt', 56);
insert into PetOwner (username, ownerName, age) values ('dkinzec7', 'Daveen Kinze', 57);
insert into PetOwner (username, ownerName, age) values ('tmckeaneyc8', 'Tamara McKeaney', null);
insert into PetOwner (username, ownerName, age) values ('cmulbryc9', 'Cosme Mulbry', 37);
insert into PetOwner (username, ownerName, age) values ('cparissca', 'Cyrill Pariss', null);
insert into PetOwner (username, ownerName, age) values ('igaitskillcb', 'Idaline Gaitskill', null);
insert into PetOwner (username, ownerName, age) values ('tdurbincc', 'Tonye Durbin', 21);
insert into PetOwner (username, ownerName, age) values ('gderbycd', 'Gussy Derby', 36);
insert into PetOwner (username, ownerName, age) values ('ffranklince', 'Fancie Franklin', 25);
insert into PetOwner (username, ownerName, age) values ('mpoytherascf', 'Martie Poytheras', 28);
insert into PetOwner (username, ownerName, age) values ('igoodmancg', 'Inger Goodman', null);
insert into PetOwner (username, ownerName, age) values ('wkrinksch', 'Winslow Krinks', 59);
insert into PetOwner (username, ownerName, age) values ('htraiseci', 'Hakim Traise', null);
insert into PetOwner (username, ownerName, age) values ('qjelfcj', 'Quintin Jelf', 62);
insert into PetOwner (username, ownerName, age) values ('bferronierck', 'Baron Ferronier', null);
insert into PetOwner (username, ownerName, age) values ('ssongistcl', 'Silvie Songist', null);
insert into PetOwner (username, ownerName, age) values ('scejkacm', 'Sauncho Cejka', 73);
insert into PetOwner (username, ownerName, age) values ('sduchamcn', 'Sybil Ducham', 51);
insert into PetOwner (username, ownerName, age) values ('sphilotco', 'Sibyl Philot', 38);
insert into PetOwner (username, ownerName, age) values ('tocorrcp', 'Travus O''Corr', 53);
insert into PetOwner (username, ownerName, age) values ('aashfoldcq', 'Averill Ashfold', 34);
insert into PetOwner (username, ownerName, age) values ('lklimushevcr', 'Lela Klimushev', 38);
insert into PetOwner (username, ownerName, age) values ('emalancs', 'Ebba Malan', 40);
insert into PetOwner (username, ownerName, age) values ('icooringtonct', 'Ingemar Coorington', null);
insert into PetOwner (username, ownerName, age) values ('rhuskcu', 'Rab Husk', 32);
insert into PetOwner (username, ownerName, age) values ('twelchmancv', 'Thain Welchman', null);
insert into PetOwner (username, ownerName, age) values ('ldelanycw', 'Lenna Delany', null);
insert into PetOwner (username, ownerName, age) values ('cgullcx', 'Candis Gull', 23);
insert into PetOwner (username, ownerName, age) values ('ctironecy', 'Cesare Tirone', 62);
insert into PetOwner (username, ownerName, age) values ('bdegoixcz', 'Berte Degoix', 60);
insert into PetOwner (username, ownerName, age) values ('kshillingtond0', 'Kirsteni Shillington', null);
insert into PetOwner (username, ownerName, age) values ('xmccafferyd1', 'Xavier McCaffery', 77);
insert into PetOwner (username, ownerName, age) values ('wwardsd2', 'Waldemar Wards', 44);
insert into PetOwner (username, ownerName, age) values ('vlindstedtd3', 'Vonnie Lindstedt', 48);
insert into PetOwner (username, ownerName, age) values ('rwrennalld4', 'Risa Wrennall', 64);
insert into PetOwner (username, ownerName, age) values ('roflanneryd5', 'Rosmunda O''Flannery', 15);
insert into PetOwner (username, ownerName, age) values ('dcarmed6', 'Devora Carme', null);
insert into PetOwner (username, ownerName, age) values ('emarquesed7', 'Evelyn Marquese', 77);
insert into PetOwner (username, ownerName, age) values ('rswafieldd8', 'Rosie Swafield', null);
insert into PetOwner (username, ownerName, age) values ('egeikied9', 'Evered Geikie', null);
insert into PetOwner (username, ownerName, age) values ('dmedmoreda', 'Dru Medmore', null);
insert into PetOwner (username, ownerName, age) values ('ealfonsinidb', 'Estel Alfonsini', null);
insert into PetOwner (username, ownerName, age) values ('smouserdc', 'Saunders Mouser', null);
insert into PetOwner (username, ownerName, age) values ('caugustdd', 'Chelsie August', 25);
insert into PetOwner (username, ownerName, age) values ('ssturgesde', 'Sharity Sturges', 36);
insert into PetOwner (username, ownerName, age) values ('eleadbitterdf', 'Erin Leadbitter', 62);
insert into PetOwner (username, ownerName, age) values ('wkellowaydg', 'Witty Kelloway', null);
insert into PetOwner (username, ownerName, age) values ('bmintoffdh', 'Benedick Mintoff', 38);
insert into PetOwner (username, ownerName, age) values ('jmullanedi', 'Jessey Mullane', null);
insert into PetOwner (username, ownerName, age) values ('lkilbeedj', 'Latrina Kilbee', null);
insert into PetOwner (username, ownerName, age) values ('sespinosadk', 'Stevy Espinosa', null);
insert into PetOwner (username, ownerName, age) values ('jagneaudl', 'Jessica Agneau', 47);
insert into PetOwner (username, ownerName, age) values ('tnoblettdm', 'Trevor Noblett', null);
insert into PetOwner (username, ownerName, age) values ('raddicottdn', 'Raina Addicott', 60);
insert into PetOwner (username, ownerName, age) values ('bcrudendo', 'Beverlie Cruden', null);
insert into PetOwner (username, ownerName, age) values ('pskadedp', 'Padgett Skade', 65);
insert into PetOwner (username, ownerName, age) values ('hyesenevdq', 'Hugues Yesenev', null);
insert into PetOwner (username, ownerName, age) values ('nlondingdr', 'Nadean Londing', 25);
insert into PetOwner (username, ownerName, age) values ('klorenzods', 'Kenn Lorenzo', null);
insert into PetOwner (username, ownerName, age) values ('bjakovdt', 'Brear Jakov', 24);
insert into PetOwner (username, ownerName, age) values ('kdedu', 'Klarrisa De Luna', 24);
insert into PetOwner (username, ownerName, age) values ('flillgarddv', 'Findlay Lillgard', null);
insert into PetOwner (username, ownerName, age) values ('jshirleydw', 'Jocelyn Shirley', 71);
insert into PetOwner (username, ownerName, age) values ('skornilovdx', 'Shannen Kornilov', 62);
insert into PetOwner (username, ownerName, age) values ('aharradencedy', 'Ashely Harradence', 77);
insert into PetOwner (username, ownerName, age) values ('jivettsdz', 'Justen Ivetts', 79);
insert into PetOwner (username, ownerName, age) values ('ewisdene0', 'Elsinore Wisden', 66);
insert into PetOwner (username, ownerName, age) values ('nvasilyeve1', 'Naoma Vasilyev', 75);
insert into PetOwner (username, ownerName, age) values ('shasele2', 'Starlene Hasel', null);
insert into PetOwner (username, ownerName, age) values ('fscantleburye3', 'Freddy Scantlebury', 43);
insert into PetOwner (username, ownerName, age) values ('rladleye4', 'Richmound Ladley', 51);
insert into PetOwner (username, ownerName, age) values ('abrowne5', 'Ashli Brown', 33);
insert into PetOwner (username, ownerName, age) values ('echeesmane6', 'Etty Cheesman', null);
insert into PetOwner (username, ownerName, age) values ('asangare7', 'Alexei Sangar', 27);
insert into PetOwner (username, ownerName, age) values ('biozefoviche8', 'Bern Iozefovich', 54);
insert into PetOwner (username, ownerName, age) values ('rseabrockee9', 'Ronda Seabrocke', 55);
insert into PetOwner (username, ownerName, age) values ('mfessierea', 'Megen Fessier', 23);
insert into PetOwner (username, ownerName, age) values ('tfranssenieb', 'Thorpe Fransseni', 22);
insert into PetOwner (username, ownerName, age) values ('rcasottiec', 'Rheba Casotti', 12);
insert into PetOwner (username, ownerName, age) values ('sbasnetted', 'Saundra Basnett', 16);
insert into PetOwner (username, ownerName, age) values ('kjanceyee', 'Kelwin Jancey', 62);
insert into PetOwner (username, ownerName, age) values ('agrinstedef', 'Allayne Grinsted', 39);
insert into PetOwner (username, ownerName, age) values ('bgrisdaleeg', 'Braden Grisdale', 26);
insert into PetOwner (username, ownerName, age) values ('mpylkynytoneh', 'Marta Pylkynyton', null);
insert into PetOwner (username, ownerName, age) values ('ddummiganei', 'Doris Dummigan', 65);
insert into PetOwner (username, ownerName, age) values ('zkarpeevej', 'Zane Karpeev', 17);
insert into PetOwner (username, ownerName, age) values ('kgleaveek', 'Kelbee Gleave', 68);
insert into PetOwner (username, ownerName, age) values ('khinckesel', 'Kamillah Hinckes', 75);
insert into PetOwner (username, ownerName, age) values ('bclubbeem', 'Britt Clubbe', 49);
insert into PetOwner (username, ownerName, age) values ('jstokesen', 'Jeno Stokes', null);
insert into PetOwner (username, ownerName, age) values ('amccuisheo', 'Aurie McCuish', 40);
insert into PetOwner (username, ownerName, age) values ('tparramoreep', 'Tamara Parramore', 52);
insert into PetOwner (username, ownerName, age) values ('rkempstoneq', 'Rasia Kempston', 33);
insert into PetOwner (username, ownerName, age) values ('cscoraher', 'Chelsea Scorah', 24);
insert into PetOwner (username, ownerName, age) values ('ebrunaes', 'Emma Bruna', 16);
insert into PetOwner (username, ownerName, age) values ('hbattramet', 'Halley Battram', null);
insert into PetOwner (username, ownerName, age) values ('lmatzeitiseu', 'Lauri Matzeitis', 28);
insert into PetOwner (username, ownerName, age) values ('adanfordev', 'Allison Danford', null);
insert into PetOwner (username, ownerName, age) values ('cmayceyew', 'Cookie Maycey', 43);
insert into PetOwner (username, ownerName, age) values ('mheinleex', 'Margaret Heinle', 49);
insert into PetOwner (username, ownerName, age) values ('apimblettey', 'Arlie Pimblett', null);
insert into PetOwner (username, ownerName, age) values ('kstolbergez', 'Kennie Stolberg', null);
insert into PetOwner (username, ownerName, age) values ('kcalleryf0', 'Kevan Callery', 44);
insert into PetOwner (username, ownerName, age) values ('kcardof1', 'Kiah Cardo', null);
insert into PetOwner (username, ownerName, age) values ('jburyf2', 'Jessa Bury', 21);
insert into PetOwner (username, ownerName, age) values ('mjoscelynf3', 'Margit Joscelyn', 48);
insert into PetOwner (username, ownerName, age) values ('mhutfieldf4', 'Morlee Hutfield', 52);
insert into PetOwner (username, ownerName, age) values ('tproppersf5', 'Tirrell Proppers', 54);
insert into PetOwner (username, ownerName, age) values ('lhurticf6', 'Lindie Hurtic', 40);
insert into PetOwner (username, ownerName, age) values ('zzsaf7', 'Zsa zsa Romanini', 67);
insert into PetOwner (username, ownerName, age) values ('dgoodyearf8', 'Debora Goodyear', 39);
insert into PetOwner (username, ownerName, age) values ('bstorckf9', 'Bernhard Storck', null);
insert into PetOwner (username, ownerName, age) values ('tkilcullenfa', 'Tuckie Kilcullen', 25);
insert into PetOwner (username, ownerName, age) values ('gdoddrellfb', 'Ginger Doddrell', 65);
insert into PetOwner (username, ownerName, age) values ('kkirimaafc', 'Kamila Kirimaa', 29);
insert into PetOwner (username, ownerName, age) values ('wpetronisfd', 'Wilone Petronis', 70);
insert into PetOwner (username, ownerName, age) values ('mperotfe', 'Marcelline Perot', 49);
insert into PetOwner (username, ownerName, age) values ('vhaneyff', 'Vilma Haney`', 28);
insert into PetOwner (username, ownerName, age) values ('atweenfg', 'Alysa Tween', null);
insert into PetOwner (username, ownerName, age) values ('jbiesterfeldfh', 'Jaimie Biesterfeld', 79);
insert into PetOwner (username, ownerName, age) values ('zglasfi', 'Zerk Glas', 42);
insert into PetOwner (username, ownerName, age) values ('fvaneevfj', 'Fionna Vaneev', 14);
insert into PetOwner (username, ownerName, age) values ('hmegarryfk', 'Ham Megarry', 26);
insert into PetOwner (username, ownerName, age) values ('ahankinfl', 'Augustus Hankin', 33);
insert into PetOwner (username, ownerName, age) values ('ctodmanfm', 'Celestyn Todman', null);
insert into PetOwner (username, ownerName, age) values ('kklaggemanfn', 'Kirbee Klaggeman', 37);
insert into PetOwner (username, ownerName, age) values ('vfairsfo', 'Vale Fairs', 31);
insert into PetOwner (username, ownerName, age) values ('bmackeaguefp', 'Beret MacKeague', 20);
insert into PetOwner (username, ownerName, age) values ('elatusfq', 'Eleen Latus', 69);
insert into PetOwner (username, ownerName, age) values ('jgabeyfr', 'Janetta Gabey', 78);
insert into PetOwner (username, ownerName, age) values ('jverissimofs', 'Jeno Verissimo', 46);
insert into PetOwner (username, ownerName, age) values ('slathomft', 'Sacha Lathom', 60);
insert into PetOwner (username, ownerName, age) values ('ffishleyfu', 'Fergus Fishley', 49);
insert into PetOwner (username, ownerName, age) values ('awinckworthfv', 'Annissa Winckworth', 35);
insert into PetOwner (username, ownerName, age) values ('stroreyfw', 'Sidonia Trorey', 66);
insert into PetOwner (username, ownerName, age) values ('tmacquarriefx', 'Tawsha MacQuarrie', 31);
insert into PetOwner (username, ownerName, age) values ('gsibthorpfy', 'Georgia Sibthorp', 68);
insert into PetOwner (username, ownerName, age) values ('nfranzettifz', 'Natale Franzetti', 44);
insert into PetOwner (username, ownerName, age) values ('fgotthardsfg0', 'Flinn Gotthard.sf', null);
insert into PetOwner (username, ownerName, age) values ('jnicolg1', 'Jandy Nicol', 49);
insert into PetOwner (username, ownerName, age) values ('jrouffg2', 'Jemie Rouff', null);
insert into PetOwner (username, ownerName, age) values ('jphoebeg3', 'Josselyn Phoebe', 67);
insert into PetOwner (username, ownerName, age) values ('pridgleyg4', 'Pattie Ridgley', null);
insert into PetOwner (username, ownerName, age) values ('opaoluccig5', 'Ondrea Paolucci', 70);
insert into PetOwner (username, ownerName, age) values ('bhosierg6', 'Berenice Hosier', 73);
insert into PetOwner (username, ownerName, age) values ('fdunphyg7', 'Frannie Dunphy', 27);
insert into PetOwner (username, ownerName, age) values ('gnearsg8', 'Gloria Nears', 74);
insert into PetOwner (username, ownerName, age) values ('ymoralisg9', 'Yvonne Moralis', 21);
insert into PetOwner (username, ownerName, age) values ('hsmalingga', 'Hedi Smaling', 57);
insert into PetOwner (username, ownerName, age) values ('nkleinstubgb', 'Neala Kleinstub', 10);
insert into PetOwner (username, ownerName, age) values ('cfishleighgc', 'Carma Fishleigh', 23);
insert into PetOwner (username, ownerName, age) values ('fshavelgd', 'Francisca Shavel', 36);
insert into PetOwner (username, ownerName, age) values ('rbudnkge', 'Rodney Budnk', 39);
insert into PetOwner (username, ownerName, age) values ('ndumkegf', 'Nickie Dumke', null);
insert into PetOwner (username, ownerName, age) values ('blandagg', 'Brunhilde Landa', null);
insert into PetOwner (username, ownerName, age) values ('afenkelgh', 'Abey Fenkel', 22);
insert into PetOwner (username, ownerName, age) values ('whallsworthgi', 'Windham Hallsworth', 35);
insert into PetOwner (username, ownerName, age) values ('lmccarvergj', 'Laural McCarver', 70);
insert into PetOwner (username, ownerName, age) values ('dlyddiattgk', 'Dalt Lyddiatt', 79);
insert into PetOwner (username, ownerName, age) values ('ndederickgl', 'Nonnah Dederick', 52);
insert into PetOwner (username, ownerName, age) values ('nbranngm', 'Nicolea Brann', null);
insert into PetOwner (username, ownerName, age) values ('atredwellgn', 'Alika Tredwell', 14);
insert into PetOwner (username, ownerName, age) values ('fmatusiakgo', 'Florri Matusiak', 61);
insert into PetOwner (username, ownerName, age) values ('cwhorfgp', 'Cordy Whorf', 62);
insert into PetOwner (username, ownerName, age) values ('wsmowtongq', 'Winnie Smowton', 14);
insert into PetOwner (username, ownerName, age) values ('fjugginggr', 'Ferris Jugging', 54);
insert into PetOwner (username, ownerName, age) values ('sboatrightgs', 'Sande Boatright', 67);
insert into PetOwner (username, ownerName, age) values ('tburnhamsgt', 'Talbot Burnhams', 57);
insert into PetOwner (username, ownerName, age) values ('wleasorgu', 'Winthrop Leasor', 54);
insert into PetOwner (username, ownerName, age) values ('lqualtroughgv', 'Leoline Qualtrough', null);
insert into PetOwner (username, ownerName, age) values ('mswiggergw', 'Myrwyn Swigger', 47);
insert into PetOwner (username, ownerName, age) values ('sgalesgx', 'Shanda Gales', 32);
insert into PetOwner (username, ownerName, age) values ('ishailergy', 'Ilise Shailer', null);
insert into PetOwner (username, ownerName, age) values ('gpresideygz', 'Gerta Presidey', 39);
insert into PetOwner (username, ownerName, age) values ('beymerh0', 'Blondy Eymer', null);
insert into PetOwner (username, ownerName, age) values ('llubertoh1', 'Lazar Luberto', 39);
insert into PetOwner (username, ownerName, age) values ('aficklingh2', 'Amandy Fickling', 10);
insert into PetOwner (username, ownerName, age) values ('mjahndelh3', 'Merl Jahndel', 53);
insert into PetOwner (username, ownerName, age) values ('akeepenceh4', 'Agatha Keepence', 30);
insert into PetOwner (username, ownerName, age) values ('scoulbeckh5', 'Shepherd Coulbeck', null);
insert into PetOwner (username, ownerName, age) values ('jbrilonh6', 'Johann Brilon', 56);
insert into PetOwner (username, ownerName, age) values ('gdarrigoneh7', 'Gus Darrigone', 53);
insert into PetOwner (username, ownerName, age) values ('gfidelerh8', 'Garry Fideler', 13);
insert into PetOwner (username, ownerName, age) values ('bvannuccih9', 'Bartholomeus Vannucci', 77);
insert into PetOwner (username, ownerName, age) values ('bsoppittha', 'Bobbie Soppitt', null);
insert into PetOwner (username, ownerName, age) values ('btoolanhb', 'Burty Toolan', 38);
insert into PetOwner (username, ownerName, age) values ('btreagusthc', 'Babbie Treagust', 26);
insert into PetOwner (username, ownerName, age) values ('tgetcliffhd', 'Tessa Getcliff', 62);
insert into PetOwner (username, ownerName, age) values ('lraffleshe', 'Lorry Raffles', null);
insert into PetOwner (username, ownerName, age) values ('mprettejohnshf', 'Moyna Prettejohns', null);
insert into PetOwner (username, ownerName, age) values ('lwilliamsonhg', 'Lazarus Williamson', 23);
insert into PetOwner (username, ownerName, age) values ('atevlinhh', 'Adriaens Tevlin', 54);
insert into PetOwner (username, ownerName, age) values ('djaycoxhi', 'Dorey Jaycox', 72);
insert into PetOwner (username, ownerName, age) values ('pmcgeachyhj', 'Pavla McGeachy', 55);
insert into PetOwner (username, ownerName, age) values ('mfieldenhk', 'Margie Fielden', null);
insert into PetOwner (username, ownerName, age) values ('cspaduccihl', 'Cherlyn Spaducci', 35);
insert into PetOwner (username, ownerName, age) values ('lbragerhm', 'Lotti Brager', null);
insert into PetOwner (username, ownerName, age) values ('jivanyukovhn', 'Jock Ivanyukov', 30);
insert into PetOwner (username, ownerName, age) values ('gsamwayesho', 'Garald Samwayes', 17);
insert into PetOwner (username, ownerName, age) values ('grozanskihp', 'Griffy Rozanski', 45);
insert into PetOwner (username, ownerName, age) values ('iandreixhq', 'Ives Andreix', null);
insert into PetOwner (username, ownerName, age) values ('dgreenhallhr', 'Drusie Greenhall', null);
insert into PetOwner (username, ownerName, age) values ('kloomishs', 'Keenan Loomis', null);
insert into PetOwner (username, ownerName, age) values ('nwindridgeht', 'Neysa Windridge', 76);
insert into PetOwner (username, ownerName, age) values ('jdanneilhu', 'Jasun Danneil', 47);
insert into PetOwner (username, ownerName, age) values ('lbellochthv', 'Laryssa Bellocht', 59);
insert into PetOwner (username, ownerName, age) values ('rlewishw', 'Ralina Lewis', 74);
insert into PetOwner (username, ownerName, age) values ('vshoebottomhx', 'Veronica Shoebottom', 14);
insert into PetOwner (username, ownerName, age) values ('gcockillhy', 'Gleda Cockill', null);
insert into PetOwner (username, ownerName, age) values ('mfradsonhz', 'Mikaela Fradson', 23);
insert into PetOwner (username, ownerName, age) values ('dlamprechti0', 'Dionis Lamprecht', 40);
insert into PetOwner (username, ownerName, age) values ('fmccourtiei1', 'Faith McCourtie', 16);
insert into PetOwner (username, ownerName, age) values ('sjebbi2', 'Sula Jebb', 26);
insert into PetOwner (username, ownerName, age) values ('fbortoli3', 'Florian Bortol', null);
insert into PetOwner (username, ownerName, age) values ('msketti4', 'Malcolm Skett', null);
insert into PetOwner (username, ownerName, age) values ('cmcgrearyi5', 'Chickie McGreary', 59);
insert into PetOwner (username, ownerName, age) values ('dulyati6', 'Derrek Ulyat', null);
insert into PetOwner (username, ownerName, age) values ('smattacki7', 'Stephenie Mattack', 65);
insert into PetOwner (username, ownerName, age) values ('phollingtoni8', 'Pearl Hollington', null);
insert into PetOwner (username, ownerName, age) values ('nnittoi9', 'Neall Nitto', 31);
insert into PetOwner (username, ownerName, age) values ('lfountainia', 'Lothaire Fountain', 40);
insert into PetOwner (username, ownerName, age) values ('rpercivalib', 'Rooney Percival', null);
insert into PetOwner (username, ownerName, age) values ('hstreetenic', 'Harcourt Streeten', 76);
insert into PetOwner (username, ownerName, age) values ('rpasmoreid', 'Reggi Pasmore', null);
insert into PetOwner (username, ownerName, age) values ('mlongmanie', 'Meredith Longman', 19);
insert into PetOwner (username, ownerName, age) values ('aflowerdewif', 'Archer Flowerdew', 42);
insert into PetOwner (username, ownerName, age) values ('dburnepig', 'Dorry Burnep', 28);
insert into PetOwner (username, ownerName, age) values ('bdriversih', 'Brig Drivers', 24);
insert into PetOwner (username, ownerName, age) values ('gskyrmii', 'Gwennie Skyrm', 47);
insert into PetOwner (username, ownerName, age) values ('gpimblottij', 'Georges Pimblott', null);
insert into PetOwner (username, ownerName, age) values ('jgraineik', 'Judith Graine', null);
insert into PetOwner (username, ownerName, age) values ('kregisil', 'Katherina Regis', null);
insert into PetOwner (username, ownerName, age) values ('lanearim', 'Lisabeth Anear', null);
insert into PetOwner (username, ownerName, age) values ('kqueyosin', 'Karlene Queyos', null);
insert into PetOwner (username, ownerName, age) values ('gdeio', 'Garth De Few', null);
insert into PetOwner (username, ownerName, age) values ('mbreacheip', 'Mellisa Breache', null);
insert into PetOwner (username, ownerName, age) values ('ddavidowiq', 'Dixie Davidow', null);
insert into PetOwner (username, ownerName, age) values ('fmoffattir', 'Feodor Moffatt', 76);
insert into PetOwner (username, ownerName, age) values ('rdohmannis', 'Regine Dohmann', 75);
insert into PetOwner (username, ownerName, age) values ('tjusthamit', 'Tommi Justham', null);
insert into PetOwner (username, ownerName, age) values ('mengleyiu', 'Mara Engley', 46);
insert into PetOwner (username, ownerName, age) values ('pdoumerciv', 'Parker Doumerc', 69);
insert into PetOwner (username, ownerName, age) values ('kjubertiw', 'Kesley Jubert', 76);
insert into PetOwner (username, ownerName, age) values ('rbutterwickix', 'Reba Butterwick', 11);
insert into PetOwner (username, ownerName, age) values ('lmcmurrayiy', 'Lin McMurray', null);
insert into PetOwner (username, ownerName, age) values ('hsherwoodiz', 'Howard Sherwood', 75);
insert into PetOwner (username, ownerName, age) values ('gdepkaj0', 'Ginny Depka', 30);
insert into PetOwner (username, ownerName, age) values ('dbolmannj1', 'Darwin Bolmann', 30);
insert into PetOwner (username, ownerName, age) values ('mskulej2', 'Marget Skule', 72);
insert into PetOwner (username, ownerName, age) values ('wdugganj3', 'Weidar Duggan', 21);
insert into PetOwner (username, ownerName, age) values ('ksouterj4', 'Kirstyn Souter', 26);
insert into PetOwner (username, ownerName, age) values ('isemeniukj5', 'Isa Semeniuk', null);
insert into PetOwner (username, ownerName, age) values ('bkiltiej6', 'Bethina Kiltie', 77);
insert into PetOwner (username, ownerName, age) values ('mmckeemanj7', 'Madelin McKeeman', null);
insert into PetOwner (username, ownerName, age) values ('gmargueritej8', 'Goldarina Marguerite', 67);
insert into PetOwner (username, ownerName, age) values ('dhudlestonj9', 'Dotty Hudleston', 46);
insert into PetOwner (username, ownerName, age) values ('rdouthwaiteja', 'Roberta Douthwaite', 70);
insert into PetOwner (username, ownerName, age) values ('acoughanjb', 'Adah Coughan', 48);
insert into PetOwner (username, ownerName, age) values ('sbaconjc', 'Sherlock Bacon', null);
insert into PetOwner (username, ownerName, age) values ('cmattsjd', 'Cullan Matts', null);
insert into PetOwner (username, ownerName, age) values ('jcanaanje', 'Jaclin Canaan', 48);
insert into PetOwner (username, ownerName, age) values ('mglabachjf', 'Manon Glabach', 35);
insert into PetOwner (username, ownerName, age) values ('kjohniganjg', 'Kincaid Johnigan', 40);
insert into PetOwner (username, ownerName, age) values ('avallentinjh', 'Alexis Vallentin', 35);
insert into PetOwner (username, ownerName, age) values ('syateji', 'Shane Yate', null);
insert into PetOwner (username, ownerName, age) values ('crooperjj', 'Currey Rooper', 42);
insert into PetOwner (username, ownerName, age) values ('aslymanjk', 'Aleece Slyman', 36);
insert into PetOwner (username, ownerName, age) values ('tlangstonejl', 'Teirtza Langstone', 33);
insert into PetOwner (username, ownerName, age) values ('rtregienjm', 'Rabi Tregien', null);
insert into PetOwner (username, ownerName, age) values ('dcarekjn', 'Deana Carek', null);
insert into PetOwner (username, ownerName, age) values ('dlymanjo', 'Dewitt Lyman', 42);
insert into PetOwner (username, ownerName, age) values ('pocahilljp', 'Pat O''Cahill', 11);
insert into PetOwner (username, ownerName, age) values ('vgrievejq', 'Vi Grieve', 56);
insert into PetOwner (username, ownerName, age) values ('alowniejr', 'Allys Lownie', 21);
insert into PetOwner (username, ownerName, age) values ('idrydenjs', 'Ivory Dryden', 67);
insert into PetOwner (username, ownerName, age) values ('jbirdwhistlejt', 'Jourdain Birdwhistle', 39);
insert into PetOwner (username, ownerName, age) values ('bpendellju', 'Bealle Pendell', 44);
insert into PetOwner (username, ownerName, age) values ('jdeloozejv', 'Johnathon Delooze', 50);
insert into PetOwner (username, ownerName, age) values ('ckhanjw', 'Culver Khan', 17);
insert into PetOwner (username, ownerName, age) values ('dsuddickjx', 'Doti Suddick', 62);
insert into PetOwner (username, ownerName, age) values ('awoolfootjy', 'Ashla Woolfoot', null);
insert into PetOwner (username, ownerName, age) values ('rrowbottamjz', 'Rafa Rowbottam', 61);
insert into PetOwner (username, ownerName, age) values ('kpickettk0', 'Keefer Pickett', 48);
insert into PetOwner (username, ownerName, age) values ('fennalsk1', 'Felic Ennals', 34);
insert into PetOwner (username, ownerName, age) values ('ndurkink2', 'Nomi Durkin', null);
insert into PetOwner (username, ownerName, age) values ('alambirthk3', 'Anabelle Lambirth', 42);
insert into PetOwner (username, ownerName, age) values ('cnorburyk4', 'Carney Norbury', 39);
insert into PetOwner (username, ownerName, age) values ('ldautryk5', 'Lynn Dautry', 28);
insert into PetOwner (username, ownerName, age) values ('dpaladinik6', 'Dwight Paladini', 12);
insert into PetOwner (username, ownerName, age) values ('jlohmeyerk7', 'Jermain Lohmeyer', 25);
insert into PetOwner (username, ownerName, age) values ('sgiacomok8', 'Sheeree Giacomo', null);
insert into PetOwner (username, ownerName, age) values ('aalvaradok9', 'Alissa Alvarado', null);
insert into PetOwner (username, ownerName, age) values ('amaccaughenka', 'Ailene MacCaughen', 79);
insert into PetOwner (username, ownerName, age) values ('apeschmannkb', 'Arman Peschmann', 54);
insert into PetOwner (username, ownerName, age) values ('pwroutkc', 'Peta Wrout', 77);
insert into PetOwner (username, ownerName, age) values ('aveldenkd', 'Ara Velden', 80);
insert into PetOwner (username, ownerName, age) values ('dtarteke', 'Debi Tarte', 65);
insert into PetOwner (username, ownerName, age) values ('mgiabuzzikf', 'Mose Giabuzzi', 60);
insert into PetOwner (username, ownerName, age) values ('wmowerkg', 'Westley Mower', 45);
insert into PetOwner (username, ownerName, age) values ('lcanwellkh', 'Lurleen Canwell', 50);
insert into PetOwner (username, ownerName, age) values ('ofoisterki', 'Ole Foister', 27);
insert into PetOwner (username, ownerName, age) values ('hrosebykj', 'Hughie Roseby', 72);
insert into PetOwner (username, ownerName, age) values ('fgoodaykk', 'Fancie Gooday', null);
insert into PetOwner (username, ownerName, age) values ('rcaccavarikl', 'Ricki Caccavari', null);
insert into PetOwner (username, ownerName, age) values ('moleaghamkm', 'Mandie O''Leagham', null);
insert into PetOwner (username, ownerName, age) values ('eallmankn', 'Ellene Allman', null);
insert into PetOwner (username, ownerName, age) values ('thurryko', 'Tobin Hurry', null);
insert into PetOwner (username, ownerName, age) values ('rtunnkp', 'Reyna Tunn', 61);
insert into PetOwner (username, ownerName, age) values ('cquinbykq', 'Clark Quinby', 68);
insert into PetOwner (username, ownerName, age) values ('kfraynekr', 'Kirbie Frayne', 14);
insert into PetOwner (username, ownerName, age) values ('pcanadaks', 'Padget Canada', null);
insert into PetOwner (username, ownerName, age) values ('gdurnokt', 'Gunilla Durno', 63);


-- CareTaker --





