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
    pettype VARCHAR(20) PRIMARY KEY
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
/* Insert into fulltimers, will add into caretakers table */
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
    BEGIN
            SELECT COUNT(*) INTO ctx FROM FullTimer
                WHERE FullTimer.username = ctuname;
            IF ctx = 0 THEN
                INSERT INTO CareTaker VALUES (ctuname, aname, age, null);
                INSERT INTO FullTimer VALUES (ctuname);
            END IF;
            INSERT INTO Cares VALUES (ctuname, pettype, price);
            INSERT INTO Has_Availability VALUES (ctuname, period1_s, period1_e);
            INSERT INTO Has_Availability VALUES (ctuname, period2_s, period2_e);
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

/* check if the periods are 150 consecutive days within a year*/

CREATE OR REPLACE FUNCTION check_period()
RETURNS TRIGGER AS
    $$ 
    DECLARE period1 NUMERIC;
    DECLARE period2 NUMERIC;
    BEGIN
        -- check if both periods overlap
        IF (NEW.period1_s, NEW.period1_e) OVERLAPS (NEW.period2_s, NEW.period2_e) THEN
            RAISE EXCEPTION 'Invalid periods: Periods are overlapping.';
        ELSE
            SELECT (NEW.period1_e - NEW.period1_s) AS DAYS INTO period1;
            SELECT (NEW.period2_e - NEW.period2_s) AS DAYS INTO period2;
            IF (period1 < 150 OR period2 < 150) THEN
                RAISE EXCEPTION 'Invalid periods: Less than 150 days.';
            ELSE
                RETURN NEW;
            END IF;
        END IF;
    END; $$
LANGUAGE plpgsql;


CREATE TRIGGER check_ft_period
BEFORE INSERT ON FullTimer
FOR EACH ROW EXECUTE PROCEDURE check_period();

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
        IF ft > 0 AND bidcount < 5 THEN
            UPDATE Bid SET is_win = True WHERE ctuname = NEW.ctuname AND pouname = NEW.pouname AND petname = NEW.petname
                 AND pettype = NEW.pettype AND s_time = NEW.s_time AND e_time = NEW.e_time;
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
            IF care >= 5 THEN -- If marking this Bid would exceed the capacity of the caretaker, automatically cancel all remaining Bids for this Availability
                UPDATE Bid SET is_win = False WHERE NEW.ctuname = Bid.ctuname AND Bid.is_win IS NULL AND NEW.s_time = Bid.s_time AND NEW.e_time = Bid.e_time;
            END IF;
            RETURN NULL;
        ELSE -- If CT is a parttimer
            SELECT AVG(rating) INTO rate
                FROM Bid AS B
                WHERE NEW.ctuname = B.ctuname;
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
            SELECT (Cares.price * (_e_time - _s_time)) INTO cost
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

INSERT INTO Category VALUES ('dog'),('cat'),('rabbit'),('big dogs'),('lizard'),('bird');

CALL add_fulltimer('yellowchicken', 'chick', 22, 'bird', 50, '2020-01-01', '2020-05-30', '2020-06-01', '2020-12-20');
CALL add_fulltimer('purpledog', 'purple', 25, 'dog', 60, '2020-01-01', '2020-05-30', '2020-06-01', '2020-12-20');
CALL add_fulltimer('redduck', 'ducklings', 20, 'rabbit', 35, '2020-01-01', '2020-05-30', '2020-06-01', '2020-12-20');

CALL add_parttimer('yellowbird', 'bird', 35, 'cat', 60);

CALL add_petOwner('johnthebest', 'John', 50, 'dog', 'Fido', 10, NULL);
CALL add_petOwner('marythemess', 'Mary', 25, 'dog', 'Fido', 10, NULL);
CALL add_petOwner('thomasthetank', 'Tom', 15, 'cat', 'Claw', 10, NULL);

INSERT INTO Owned_Pet_Belongs VALUES ('marythemess', 'big dogs', 'Champ', 10, NULL);
INSERT INTO Owned_Pet_Belongs VALUES ('marythemess', 'big dogs', 'Ruff', 12, 'Hates cats');
INSERT INTO Owned_Pet_Belongs VALUES ('marythemess', 'big dogs', 'Bark', 14, 'Can be very loud');
INSERT INTO Owned_Pet_Belongs VALUES ('marythemess', 'cat', 'Meow', 10, NULL);
INSERT INTO Owned_Pet_Belongs VALUES ('marythemess', 'cat', 'Purr', 15, 'Hates dogs');
INSERT INTO Owned_Pet_Belongs VALUES ('marythemess', 'cat', 'Sneak', 20, 'Needs to go outside a lot');

INSERT INTO Cares VALUES ('yellowchicken', 'rabbit', 40);
INSERT INTO Cares VALUES ('yellowchicken', 'dog', 40);
INSERT INTO Cares VALUES ('yellowchicken', 'big dogs', 70);
INSERT INTO Cares VALUES ('yellowchicken', 'cat', 50);
INSERT INTO Cares VALUES ('redduck', 'big dogs', 80);
INSERT INTO Cares VALUES ('purpledog', 'big dogs', 150);
INSERT INTO Cares VALUES ('purpledog', 'cat', 80);
INSERT INTO Cares VALUES ('yellowbird', 'dog', 50);
/* Remove the following line to encounter pet type error */
INSERT INTO Cares VALUES ('yellowbird', 'big dogs', 90);

INSERT INTO Has_Availability VALUES ('yellowchicken', '2020-01-01', '2020-03-04');
INSERT INTO Has_Availability VALUES ('yellowchicken', '2021-01-01', '2021-03-04');
INSERT INTO Has_Availability VALUES ('purpledog', '2021-01-01', '2021-03-04');
INSERT INTO Has_Availability VALUES ('yellowbird', '2021-01-01', '2021-03-04');
INSERT INTO Has_Availability VALUES ('yellowbird', '2020-06-02', '2020-06-08');
INSERT INTO Has_Availability VALUES ('yellowbird', '2020-12-04', '2020-12-20');
INSERT INTO Has_Availability VALUES ('yellowbird', '2020-08-08', '2020-08-10');

CALL add_bid('marythemess', 'Champ', 'big dogs', 'yellowbird', '2021-02-05', '2021-02-20', 'cash', 'poDeliver');

-- The following test case overloads 'marythemess' with more bids than she can accept
CALL add_bid('marythemess', 'Meow', 'cat', 'yellowchicken', '2021-01-01', '2021-02-28', NULL, NULL);
CALL add_bid('marythemess', 'Bark', 'big dogs', 'yellowchicken', '2021-01-01', '2021-02-28', NULL, NULL);
CALL add_bid('marythemess', 'Champ', 'big dogs', 'purpledog', '2021-02-01', '2021-02-23', 'cash', 'poDeliver');
CALL add_bid('marythemess', 'Purr', 'cat', 'purpledog', '2021-02-03', '2021-02-22', 'cash', 'ctPickup');
CALL add_bid('marythemess', 'Champ', 'big dogs', 'yellowchicken', '2021-02-24', '2021-02-28', 'cash', 'poDeliver');
CALL add_bid('marythemess', 'Ruff', 'big dogs', 'yellowchicken', '2021-02-25', '2021-02-28', 'cash', 'ctPickup');
CALL add_bid('marythemess', 'Purr', 'cat', 'yellowchicken', '2021-02-26', '2021-02-28', 'cash', 'poDeliver');
CALL add_bid('marythemess', 'Sneak', 'cat', 'yellowchicken', '2021-02-27', '2021-02-28', 'cash', 'poDeliver');

-- The following test case sets up a completed Bid
--CALL add_bid('marythemess', 'Champ', 'big dogs', 'yellowchicken', '2020-02-05', '2020-02-20', 'credit card', 'ctPickup');
--UPDATE Bid SET is_win = true WHERE ctuname = 'yellowchicken' AND pouname = 'marythemess' AND petname = 'Champ'
--    AND pettype = 'big dogs' AND s_time = to_date('20200205','YYYYMMDD') AND e_time = to_date('20200220','YYYYMMDD');
--UPDATE Bid SET pay_type = 'cash', pet_pickup = 'poDeliver', rating = '3', review = 'sample review', pay_status = true
--    WHERE ctuname = 'yellowchicken' AND pouname = 'marythemess' AND petname = 'Champ' AND pettype = 'big dogs'
--    AND s_time = to_date('20200205','YYYYMMDD') AND e_time = to_date('20200220','YYYYMMDD') AND is_win = true;

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