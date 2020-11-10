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
-- DO
-- $do$
-- DECLARE
--    _sql text;
-- BEGIN
--    SELECT INTO _sql
--           string_agg(format('DROP %s %s;'
--                           , CASE prokind
--                               WHEN 'f' THEN 'FUNCTION'
--                               WHEN 'a' THEN 'AGGREGATE'
--                               WHEN 'p' THEN 'PROCEDURE'
--                               WHEN 'w' THEN 'FUNCTION'  -- window function (rarely applicable)
--                               -- ELSE NULL              -- not possible in pg 11
--                             END
--                           , oid::regprocedure)
--                    , E'\n')
--    FROM   pg_proc
--    WHERE  pronamespace = 'public'::regnamespace  -- schema name here!
--    -- AND    prokind = ANY ('{f,a,p,w}')         -- optionally filter kinds
--    ;

--    IF _sql IS NOT NULL THEN
--        RAISE NOTICE '%', _sql;  -- debug / check first
--        EXECUTE _sql;         -- uncomment payload once you are sure
--    ELSE
--        RAISE NOTICE 'No fuctions found in schema %', quote_ident(_schema);
--    END IF;
-- END
-- $do$;


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

-- /*TRIGGERS AND PROCEDURE*/
-- ------------------------------------------------ Pet Owner ------------------------------------------------------------
-- CREATE OR REPLACE PROCEDURE
--     add_petOwner(uName VARCHAR(50), oName VARCHAR(50), oAge INTEGER, pType VARCHAR(20), pName VARCHAR(20),
--         pAge INTEGER, req VARCHAR(50)) AS
--         $$
--         DECLARE ctx NUMERIC;
--         BEGIN
--             SELECT COUNT(*) INTO ctx FROM PetOwner
--                 WHERE PetOwner.username = uName;
--             IF ctx = 0 THEN
--                 INSERT INTO PetOwner VALUES (uName, oName, oAge);
--             END IF;
--             INSERT INTO Owned_Pet_Belongs VALUES (uName, pType, pName, pAge, req);
--         END;
--         $$
--     LANGUAGE plpgsql;

-- ------------------------------------------------ CareTaker ------------------------------------------------------------

-- /* This procedure is used to add 
--     - New fulltimers
--     - Existing fulltimers' new availabilities (availabilities must be two periods of at least 150 days each within a year)
-- */

-- CREATE OR REPLACE PROCEDURE add_fulltimer(
--     ctuname VARCHAR(50),
--     aname VARCHAR(50),
--     age   INTEGER,
--     pettype VARCHAR(20),
--     price INTEGER,
--     period1_s DATE, 
--     period1_e DATE, 
--     period2_s DATE,
--     period2_e DATE
--     )  AS $$
--     DECLARE ctx NUMERIC;
--     DECLARE period1 NUMERIC;
--     DECLARE period2 NUMERIC;
--     DECLARE t_period NUMERIC;
--     BEGIN
--         -- check if both periods overlap
--         IF (period1_s, period1_e) OVERLAPS (period2_s, period2_e) THEN
--             RAISE EXCEPTION 'Invalid periods: Periods are overlapping.';
--         ELSE
--             SELECT (period1_e - period1_s + 1) AS DAYS INTO period1;
--             SELECT (period2_e - period2_s + 1) AS DAYS INTO period2;
--             IF (period1 < 150 OR period2 < 150) THEN
--                 RAISE EXCEPTION 'Invalid periods: Less than 150 days.';
--             END IF;
--             SELECT (period2_e - period1_s + 1) AS DAYS INTO t_period;
--             IF (t_period > 365) THEN
--                 RAISE EXCEPTION 'Invalid periods: Periods are not within a year.';
--             ELSE
--                 SELECT COUNT(*) INTO ctx FROM FullTimer WHERE FullTimer.username = ctuname;
--                 IF ctx = 0 THEN
--                     INSERT INTO CareTaker VALUES (ctuname, aname, age);
--                     INSERT INTO FullTimer VALUES (ctuname);
--                     INSERT INTO Cares VALUES (ctuname, pettype, price);
--                 END IF;
--                 INSERT INTO Has_Availability VALUES (ctuname, period1_s, period1_e);
--                 INSERT INTO Has_Availability VALUES (ctuname, period2_s, period2_e);
--             END IF;
--         END If;
--     END;$$
-- LANGUAGE plpgsql;

-- /* add parttime */
-- CREATE OR REPLACE PROCEDURE add_parttimer(
--     ctuname VARCHAR(50),
--     aname VARCHAR(50),
--     age   INTEGER,
--     pettype VARCHAR(20),
--     price INTEGER
--     )  AS $$
--     DECLARE ctx NUMERIC;
--     BEGIN
--         SELECT COUNT(*) INTO ctx FROM PartTimer
--                 WHERE PartTimer.username = ctuname;
--         IF ctx = 0 THEN
--             INSERT INTO CareTaker VALUES (ctuname, aname, age);
--             INSERT INTO PartTimer VALUES (ctuname);
--         END IF;
--         INSERT INTO Cares VALUES (ctuname, pettype, price);
--     END;$$
-- LANGUAGE plpgsql;

-- /* check if caretaker is not already part of PartTimer or FullTimer. To fulfill the no-overlap constraint */
-- CREATE OR REPLACE FUNCTION not_parttimer_or_fulltimer()
-- RETURNS TRIGGER AS
-- $$ DECLARE Pctx NUMERIC;
--     DECLARE Fctx NUMERIC;
--     BEGIN
--         SELECT COUNT(*) INTO Pctx 
--         FROM PartTimer P
--         WHERE NEW.username = P.username;

--         SELECT COUNT(*) INTO Fctx 
--         FROM FullTimer F
--         WHERE NEW.username = F.username;

--         IF (Pctx > 0 OR Fctx > 0) THEN
--             RAISE EXCEPTION 'This username belongs to an existing caretaker.';
--         ELSE 
--             RETURN NEW;
--         END IF; END; $$
-- LANGUAGE plpgsql;

-- CREATE TRIGGER check_fulltimer
-- BEFORE INSERT ON CareTaker
-- FOR EACH ROW EXECUTE PROCEDURE not_parttimer_or_fulltimer();

-- /* check if parttimer that is being added is not a fulltimer. To fulfill the no-overlap constraint */
-- CREATE OR REPLACE FUNCTION not_fulltimer()
-- RETURNS TRIGGER AS
-- $$ DECLARE ctx NUMERIC;
--     BEGIN
--         SELECT COUNT(*) INTO ctx 
--         FROM FullTimer F
--         WHERE NEW.username = F.username;

--         IF ctx > 0 THEN
--             RAISE EXCEPTION 'This username belongs to an existing fulltimer.';
--         ELSE 
--             RETURN NEW;
--         END IF; END; $$
-- LANGUAGE plpgsql;

-- CREATE TRIGGER check_parttimer
-- BEFORE INSERT ON PartTimer
-- FOR EACH ROW EXECUTE PROCEDURE not_fulltimer();

-- /* check if fulltimer that is being added is not a parttimer. To fulfill the no-overlap constraint */
-- CREATE OR REPLACE FUNCTION not_parttimer()
-- RETURNS TRIGGER AS
-- $$ DECLARE ctx NUMERIC;
--     BEGIN
--         SELECT COUNT(*) INTO ctx 
--         FROM PartTimer P
--         WHERE NEW.username = P.username;

--         IF ctx > 0 THEN
--             RAISE EXCEPTION 'This username belongs to an existing parttimer.';
--         ELSE 
--             RETURN NEW;
--         END IF; END; $$
-- LANGUAGE plpgsql;

-- CREATE TRIGGER check_fulltimer
-- BEFORE INSERT ON FullTimer
-- FOR EACH ROW EXECUTE PROCEDURE not_parttimer();

-- ---------------------------------------------------------- Cares ------------------------------------------------------------
-- /* Checks if the price of FT is the same as base price set by PCSadmine for each category */

-- CREATE OR REPLACE FUNCTION check_ft_cares_price()
-- RETURNS TRIGGER AS
-- $$ BEGIN
--         IF (SELECT 1 WHERE EXISTS (SELECT 1 FROM FullTimer WHERE NEW.ctuname = FullTimer.username)) THEN
        
--             IF (NEW.price <> (SELECT base_price FROM Category WHERE Category.pettype = NEW.pettype)) THEN
--                 RAISE EXCEPTION 'Cares prices for Fulltimers must adhere to the basic prices set by PCSadmin.';
--             ELSE
--                 RETURN NEW;
--             END IF;
--         ELSE
--             RETURN NEW;
--         END IF;
--     END; $$
-- LANGUAGE plpgsql;

-- CREATE TRIGGER check_ft_cares_price
-- BEFORE INSERT ON Cares
-- FOR EACH ROW EXECUTE PROCEDURE check_ft_cares_price();

-- ---------------------------------------------------------- Category ------------------------------------------------------------

-- CREATE OR REPLACE FUNCTION check_update_base_price()
-- RETURNS TRIGGER AS
-- $$ BEGIN
--         --if base price of category changes, update FT cares' prices as well
--         IF (NEW.base_price <> OLD.base_price) THEN
--             UPDATE Cares SET price = New.base_price WHERE (Cares.ctuname IN (SELECT username FROM FullTimer)) AND Cares.pettype = NEW.pettype;
--         END IF;
--         RETURN NEW;
--     END; $$
-- LANGUAGE plpgsql;

-- CREATE TRIGGER check_update_base_price
-- BEFORE UPDATE ON Category
-- FOR EACH ROW EXECUTE PROCEDURE check_update_base_price();

-- ------------------------------------------------------------ Bid ------------------------------------------------------------

-- CREATE OR REPLACE FUNCTION mark_bid_automatically_for_fulltimer()
-- RETURNS TRIGGER AS
-- $$
-- DECLARE ft NUMERIC;
-- DECLARE bidcount NUMERIC;
--     BEGIN
--         -- Automatically attempt to mark bid if caretaker is a fulltimer and can do so
--         SELECT COUNT(*) INTO ft
--             FROM FullTimer F
--             WHERE NEW.ctuname = F.username;
--         SELECT COUNT(*) INTO bidcount
--             FROM Bid
--             WHERE NEW.ctuname = Bid.ctuname AND Bid.is_win = True AND (NEW.s_time, NEW.e_time) OVERLAPS (Bid.s_time, Bid.e_time);
--         IF ft > 0 THEN
--             -- If the Fulltimer has capacity
--             IF bidcount < 5 THEN
--                 UPDATE Bid SET is_win = True WHERE ctuname = NEW.ctuname AND pouname = NEW.pouname AND petname = NEW.petname
--                     AND pettype = NEW.pettype AND s_time = NEW.s_time AND e_time = NEW.e_time;
--             ELSE
--                 UPDATE Bid SET is_win = False WHERE ctuname = NEW.ctuname AND pouname = NEW.pouname AND petname = NEW.petname
--                     AND pettype = NEW.pettype AND s_time = NEW.s_time AND e_time = NEW.e_time;
--             END IF;
--         END IF;
--         RETURN NEW;
--     END; $$
-- LANGUAGE plpgsql;

-- CREATE TRIGGER fulltimer_automatic_mark_upon_insert
-- AFTER INSERT ON Bid
-- FOR EACH ROW
-- EXECUTE PROCEDURE mark_bid_automatically_for_fulltimer();


-- CREATE OR REPLACE FUNCTION validate_mark()
-- RETURNS TRIGGER AS
-- $$
-- DECLARE ctx NUMERIC;
-- DECLARE pet NUMERIC;
-- DECLARE matchtype NUMERIC;
-- DECLARE care NUMERIC;
-- DECLARE rate NUMERIC;
--     BEGIN
--         -- Since this is a mark-validating trigger, if the Bid has already been marked, then return
--         IF OLD.is_win = True THEN
--             RETURN NEW;
--         END IF;

--         -- Check if the Pet will already be cared for by a Caretaker during this period
--         SELECT COUNT(*) INTO pet
--             FROM Bid
--             WHERE NEW.pouname = Bid.pouname AND NEW.petname = Bid.petname AND Bid.is_win = True
--               AND (NEW.s_time, NEW.e_time) OVERLAPS (Bid.s_time, Bid.e_time);

--         -- Check if the Caretaker is able to care for the Pet type
--         SELECT COUNT(*) INTO matchtype
--             FROM Cares
--             WHERE NEW.ctuname = Cares.ctuname AND NEW.pettype = Cares.pettype;

--         IF pet > 0 THEN -- If a winning bid has already been made for the same Pet which overlaps this new Bid
--             RAISE EXCEPTION 'This Pet will be taken care of by another caretaker during that period.';
--         ELSIF matchtype = 0 THEN -- Else if the caretaker is incapable of taking care of this Pet type
--             RAISE EXCEPTION 'This caretaker is unable to take care of that Pet type.';
--         END IF;

--         -- Find out if this is a fulltimer, and how many Bids they have won for that period
--         SELECT COUNT(*) INTO ctx
--             FROM FullTimer F
--             WHERE NEW.ctuname = F.username;
--         SELECT COUNT(*) INTO care
--             FROM Bid
--             WHERE NEW.ctuname = Bid.ctuname AND Bid.is_win = True AND (NEW.s_time, NEW.e_time) OVERLAPS (Bid.s_time, Bid.e_time);

--         IF ctx > 0 THEN -- If CT is a fulltimer
--             IF care >= 5 AND NEW.is_win = True THEN -- If marking this Bid would exceed the capacity of the caretaker, abort
--                 RAISE EXCEPTION 'This caretaker has exceeded their capacity.';
--             ELSE -- Otherwise, continue as-per normal
--                 RETURN NEW;
--             END IF;
--         ELSE -- If CT is a parttimer
--             SELECT AVG(rating) INTO rate
--                 FROM Bid AS B
--                 WHERE NEW.ctuname = B.ctuname;
--             IF rate IS NULL OR rate < 4 THEN
--                 IF care >= 2 AND NEW.is_win = True THEN
--                     RAISE EXCEPTION 'This caretaker has exceeded their capacity.';
--                 ELSE
--                     RETURN NEW;
--                 END IF;
--             ELSE
--                 IF care >= 5 AND NEW.is_win = True THEN
--                     RAISE EXCEPTION 'This caretaker has exceeded their capacity.';
--                 ELSE
--                     RETURN NEW;
--                 END IF;
--             END IF;
--         END IF;
--     END; $$
-- LANGUAGE plpgsql;

-- CREATE TRIGGER validate_bid_marking
-- BEFORE INSERT OR UPDATE ON Bid
-- FOR EACH ROW
-- EXECUTE PROCEDURE validate_mark();


-- CREATE OR REPLACE FUNCTION mark_other_bids()
-- RETURNS TRIGGER AS
-- $$
-- DECLARE ctx NUMERIC;
-- DECLARE care NUMERIC;
-- DECLARE rate NUMERIC;
--     BEGIN
--         SELECT COUNT(*) INTO ctx
--             FROM FullTimer F
--             WHERE NEW.ctuname = F.username;
--         SELECT COUNT(*) INTO care
--             FROM Bid
--             WHERE NEW.ctuname = Bid.ctuname AND Bid.is_win = True AND (NEW.s_time, NEW.e_time) OVERLAPS (Bid.s_time, Bid.e_time);

--         IF ctx > 0 THEN -- If CT is a fulltimer
--             IF care >= 5 THEN -- If marking this Bid would exceed the capacity of the caretaker, automatically cancel all remaining Bids overlapping this Availability
--                 UPDATE Bid SET is_win = False WHERE NEW.ctuname = Bid.ctuname AND Bid.is_win IS NULL AND (NEW.s_time, NEW.e_time) OVERLAPS (Bid.s_time, Bid.e_time);
--             END IF;
--             RETURN NULL;
--         ELSE -- If CT is a parttimer
--             SELECT AVG(rating) INTO rate
--                 FROM Bid AS B
--                 WHERE NEW.ctuname = B.ctuname;
--             IF rate IS NULL OR rate < 4 THEN
--                 IF care >= 2 THEN
--                     UPDATE Bid SET is_win = False WHERE NEW.ctuname = Bid.ctuname AND Bid.is_win IS NULL AND (NEW.s_time, NEW.e_time) OVERLAPS (Bid.s_time, Bid.e_time);
--                 END IF;
--                 RETURN NULL;
--             ELSE
--                 IF care >= 5 THEN
--                     UPDATE Bid SET is_win = False WHERE NEW.ctuname = Bid.ctuname AND Bid.is_win IS NULL AND (NEW.s_time, NEW.e_time) OVERLAPS (Bid.s_time, Bid.e_time);
--                 END IF;
--                 RETURN NULL;
--             END IF;
--         END IF;
--     END; $$
-- LANGUAGE plpgsql;

-- CREATE TRIGGER mark_other_bids_false
-- AFTER INSERT OR UPDATE ON Bid
-- FOR EACH ROW
-- EXECUTE PROCEDURE mark_other_bids();

-- CREATE OR REPLACE FUNCTION check_rating_update()
-- RETURNS TRIGGER AS
-- $$
-- DECLARE avg_rating NUMERIC;
--     BEGIN
--         -- If updating rating
--         IF (NEW.rating IS NOT NULL) THEN
--             IF ((SELECT CURRENT_DATE) > NEW.e_time) THEN
--                 IF (NEW.pay_status = TRUE AND NEW.is_win = TRUE) THEN
--                     RETURN NEW;
--                 ELSE
--                     RAISE EXCEPTION 'Bids and payment must be successful before ratings or reviews can be updated.';
--                 END IF;
--             ELSE
--                 RAISE EXCEPTION 'Ratings and reviews cannot be updated before the end of the job.';
--             END IF;
--         END IF;
--         RETURN NEW;
--     END; $$
-- LANGUAGE plpgsql;

-- CREATE TRIGGER check_rating_update
-- AFTER UPDATE ON Bid
-- FOR EACH ROW
-- EXECUTE PROCEDURE check_rating_update();


-- CREATE OR REPLACE PROCEDURE add_bid(
--     _pouname VARCHAR(50),
--     _petname VARCHAR(20),
--     _pettype VARCHAR(20),
--     _ctuname VARCHAR(50),
--     _s_time DATE,
--     _e_time DATE,
--     _pay_type VARCHAR(20),
--     _pet_pickup VARCHAR(20)
--     ) AS
--         $$
--         DECLARE care NUMERIC;
--         DECLARE avail NUMERIC;
--         DECLARE cost NUMERIC;
--         BEGIN
--             -- Ensures that the ct can care for this pet type
--             SELECT COUNT(*) INTO care
--                 FROM Cares
--                 WHERE Cares.ctuname = _ctuname AND Cares.pettype = _pettype;
--             IF care = 0 THEN
--                RAISE EXCEPTION 'Caretaker is unable to care for this pet type.';
--             END IF;

--             -- Ensures that ct has availability at this time period
--             SELECT COUNT(*) INTO avail
--                 FROM Has_Availability
--                 WHERE Has_Availability.ctuname = _ctuname AND (Has_Availability.s_time <= _s_time) AND (Has_Availability.e_time >= _e_time);
--             IF avail = 0 THEN
--                 RAISE EXCEPTION 'Caretaker is unavailable for this period.';
--             END IF;

--             -- Calculate cost
--             SELECT (Cares.price * (_e_time - _s_time + 1)) INTO cost
--                 FROM Cares
--                 WHERE Cares.ctuname = _ctuname AND Cares.pettype = _pettype;
--             INSERT INTO Bid(pouname, petname, pettype, ctuname, s_time, e_time, cost, pay_type, pet_pickup)
--                VALUES (_pouname, _petname, _pettype, _ctuname, _s_time, _e_time, cost, _pay_type, _pet_pickup);
--         END;
--         $$
--     LANGUAGE plpgsql;


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

/* SEED */
--    AND pettype = 'big dog' AND s_time = to_date('20200205','YYYYMMDD') AND e_time = to_date('20200220','YYYYMMDD');
-- UPDATE Bid SET pay_type = 'cash', pet_pickup = 'poDeliver', rating = '3', review = 'sample review', pay_status = true
--    WHERE ctuname = 'yellowchicken' AND pouname = 'marythemess' AND petname = 'Champ' AND pettype = 'big dog'
--    AND s_time = to_date('20200205','YYYYMMDD') AND e_time = to_date('20200220','YYYYMMDD') AND is_win = true;
--
 /* Expected outcome: 'marythemess' wins both bids at timestamp 1-4 and 2-4. This causes 'johnthebest' to lose the 2-4		
     bid. The 1-4 bid by 'johnthebest' that is inserted afterwards immediately loses as well, since 'yellowbird' has		
     reached their maximum capacity already.*/		
--  INSERT INTO Bid VALUES ('marythemess', 'Fido', 'dog', 'yellowbird', to_timestamp('1000000'), to_timestamp('4000000'));		
--  INSERT INTO Bid VALUES ('marythemess', 'Champ', 'big dog', 'yellowbird', to_timestamp('2000000'), to_timestamp('4000000'));		
--  INSERT INTO Bid VALUES ('johnthebest', 'Fido', 'dog', 'yellowbird', to_timestamp('2000000'), to_timestamp('4000000'));		
--  INSERT INTO Bid VALUES ('marythemess', 'Meow', 'cat', 'yellowbird', to_timestamp('3000000'), to_timestamp('4000000'));

--  UPDATE Bid SET is_win = True WHERE ctuname = 'yellowbird' AND pouname = 'marythemess' AND petname = 'Fido' AND pettype = 'dog' AND s_time = to_timestamp('1000000') AND e_time = to_timestamp('4000000');		
--  UPDATE Bid SET is_win = True WHERE ctuname = 'yellowbird' AND pouname = 'marythemess' AND petname = 'Champ' AND pettype = 'big dog' AND s_time = to_timestamp('2000000') AND e_time = to_timestamp('4000000');

--  INSERT INTO Bid VALUES ('johnthebest', 'Fido', 'dog', 'yellowbird', to_timestamp('1000000'), to_timestamp('4000000'));

--------------- TEST all_ct query, testing with 'marythemess' at time period 2020-06-01 to 2020-06-06 ---------------------

-- These are to set the ratings for following cts
-- yellow chicken










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

insert into CareTaker (username, carerName, age) values ('clampkin0', 'Ches Lampkin', 65);
insert into CareTaker (username, carerName, age) values ('msquier1', 'Marilee Squier', 27);
insert into CareTaker (username, carerName, age) values ('gmonnelly2', 'Georgiana Monnelly', 37);
insert into CareTaker (username, carerName, age) values ('hglasbey3', 'Harlin Glasbey', 54);
insert into CareTaker (username, carerName, age) values ('sbagge4', 'Stefano Bagge', 15);
insert into CareTaker (username, carerName, age) values ('lcornelleau5', 'Lorena Cornelleau', 25);
insert into CareTaker (username, carerName, age) values ('fnewitt6', 'Faydra Newitt', 48);
insert into CareTaker (username, carerName, age) values ('estoggell7', 'Esme Stoggell', 49);
insert into CareTaker (username, carerName, age) values ('tgwilliam8', 'Tabbie Gwilliam', 37);
insert into CareTaker (username, carerName, age) values ('gle9', 'Goraud Le Marchant', 57);
insert into CareTaker (username, carerName, age) values ('slafonta', 'Shanon Lafont', 23);
insert into CareTaker (username, carerName, age) values ('rbirraneb', 'Raina Birrane', 72);
insert into CareTaker (username, carerName, age) values ('escardifieldc', 'Elianora Scardifield', 25);
insert into CareTaker (username, carerName, age) values ('gcogleyd', 'Gonzalo Cogley', 72);
insert into CareTaker (username, carerName, age) values ('pdumbaree', 'Petronille Dumbare', 75);
insert into CareTaker (username, carerName, age) values ('kvelldenf', 'Kip Vellden', 75);
insert into CareTaker (username, carerName, age) values ('jpinkg', 'Jazmin Pink', 17);
insert into CareTaker (username, carerName, age) values ('jgallonh', 'Jenica Gallon', 21);
insert into CareTaker (username, carerName, age) values ('sstokeyi', 'Sibylle Stokey', 67);
insert into CareTaker (username, carerName, age) values ('tdraiseyj', 'Teddy Draisey', 74);
insert into CareTaker (username, carerName, age) values ('tshillabeark', 'Thomasine Shillabear', 35);
insert into CareTaker (username, carerName, age) values ('gpriddisl', 'Garth Priddis', 18);
insert into CareTaker (username, carerName, age) values ('jmoodycliffem', 'Jenelle Moodycliffe', 36);
insert into CareTaker (username, carerName, age) values ('sspirrittn', 'Shelly Spirritt', 17);
insert into CareTaker (username, carerName, age) values ('giwaszkiewiczo', 'Germayne Iwaszkiewicz', 53);
insert into CareTaker (username, carerName, age) values ('lromainep', 'Lelah Romaine', 55);
insert into CareTaker (username, carerName, age) values ('sferraoq', 'Sisely Ferrao', 25);
insert into CareTaker (username, carerName, age) values ('koleyr', 'Keelia Oley', 45);
insert into CareTaker (username, carerName, age) values ('sscowns', 'Stacy Scown', 53);
insert into CareTaker (username, carerName, age) values ('dklousnert', 'Dex Klousner', 28);
insert into CareTaker (username, carerName, age) values ('gsimminsu', 'Gaspard Simmins', 36);
insert into CareTaker (username, carerName, age) values ('jhawkeridgev', 'Jared Hawkeridge', 55);
insert into CareTaker (username, carerName, age) values ('jstainfieldw', 'Junette Stainfield', 33);
insert into CareTaker (username, carerName, age) values ('cchasemorex', 'Cynde Chasemore', 16);
insert into CareTaker (username, carerName, age) values ('lfinlany', 'Lynnett Finlan', 52);
insert into CareTaker (username, carerName, age) values ('mvankinz', 'Maribeth Vankin', 26);
insert into CareTaker (username, carerName, age) values ('mcockings10', 'Milicent Cockings', 47);
insert into CareTaker (username, carerName, age) values ('wclemenza11', 'Wade Clemenza', 38);
insert into CareTaker (username, carerName, age) values ('sdeakes12', 'Sonia Deakes', 59);
insert into CareTaker (username, carerName, age) values ('fbischof13', 'Ferguson Bischof', 73);
insert into CareTaker (username, carerName, age) values ('hchalice14', 'Hildagard Chalice', 53);
insert into CareTaker (username, carerName, age) values ('cmeiklem15', 'Claybourne Meiklem', 38);
insert into CareTaker (username, carerName, age) values ('cpeabody16', 'Corny Peabody', 75);
insert into CareTaker (username, carerName, age) values ('adalgarno17', 'Allyn Dalgarno', 52);
insert into CareTaker (username, carerName, age) values ('wsesons18', 'Weylin Sesons', 74);
insert into CareTaker (username, carerName, age) values ('ebon19', 'Evered Bon', 28);
insert into CareTaker (username, carerName, age) values ('rfollows1a', 'Reggy Follows', 51);
insert into CareTaker (username, carerName, age) values ('gblasiak1b', 'Garold Blasiak', 32);
insert into CareTaker (username, carerName, age) values ('sspink1c', 'Shawnee Spink', 70);
insert into CareTaker (username, carerName, age) values ('nriggey1d', 'Novelia Riggey', 39);
insert into CareTaker (username, carerName, age) values ('rgirke1e', 'Ramon Girke', 73);
insert into CareTaker (username, carerName, age) values ('zdelafoy1f', 'Zita Delafoy', 51);
insert into CareTaker (username, carerName, age) values ('kleavens1g', 'Katheryn Leavens', 47);
insert into CareTaker (username, carerName, age) values ('tpetrie1h', 'Thelma Petrie', 32);
insert into CareTaker (username, carerName, age) values ('dpascoe1i', 'Dorise Pascoe', 63);
insert into CareTaker (username, carerName, age) values ('cjimmison1j', 'Carlin Jimmison', 31);
insert into CareTaker (username, carerName, age) values ('mrubinov1k', 'Magnum Rubinov', 64);
insert into CareTaker (username, carerName, age) values ('akarmel1l', 'Aurlie Karmel', 37);
insert into CareTaker (username, carerName, age) values ('bcathie1m', 'Benjamin Cathie', 71);
insert into CareTaker (username, carerName, age) values ('bstoppard1n', 'Brien Stoppard', 52);
insert into CareTaker (username, carerName, age) values ('ccheavin1o', 'Constance Cheavin', 73);
insert into CareTaker (username, carerName, age) values ('qtiron1p', 'Quill Tiron', 75);
insert into CareTaker (username, carerName, age) values ('sgarioch1q', 'Suellen Garioch', 18);
insert into CareTaker (username, carerName, age) values ('mconnors1r', 'Major Connors', 59);
insert into CareTaker (username, carerName, age) values ('fmacilhargy1s', 'Ferne MacIlhargy', 54);
insert into CareTaker (username, carerName, age) values ('hdellabbate1t', 'Hannis Dell''Abbate', 16);
insert into CareTaker (username, carerName, age) values ('lsantino1u', 'Lucais Santino', 40);
insert into CareTaker (username, carerName, age) values ('kodd1v', 'Keely Odd', 49);
insert into CareTaker (username, carerName, age) values ('mwehner1w', 'Marketa Wehner', 66);
insert into CareTaker (username, carerName, age) values ('skitchingman1x', 'Sid Kitchingman', 19);
insert into CareTaker (username, carerName, age) values ('lharmour1y', 'Louisa Harmour', 40);
insert into CareTaker (username, carerName, age) values ('rtarquinio1z', 'Rosetta Tarquinio', 16);
insert into CareTaker (username, carerName, age) values ('vloomes20', 'Vittorio Loomes', 70);
insert into CareTaker (username, carerName, age) values ('gvogel21', 'Gracia Vogel', 42);
insert into CareTaker (username, carerName, age) values ('ddignon22', 'Dorise Dignon', 69);
insert into CareTaker (username, carerName, age) values ('mwetheril23', 'Morry Wetheril', 31);
insert into CareTaker (username, carerName, age) values ('chale24', 'Cazzie Hale', 26);
insert into CareTaker (username, carerName, age) values ('dde25', 'Deirdre De Cleen', 44);
insert into CareTaker (username, carerName, age) values ('ehillum26', 'Esmeralda Hillum', 62);
insert into CareTaker (username, carerName, age) values ('jtrelevan27', 'Josselyn Trelevan', 53);
insert into CareTaker (username, carerName, age) values ('kteodoro28', 'Ki Teodoro', 55);
insert into CareTaker (username, carerName, age) values ('bsteventon29', 'Barthel Steventon', 43);
insert into CareTaker (username, carerName, age) values ('asummerson2a', 'Amalita Summerson', 67);
insert into CareTaker (username, carerName, age) values ('aellington2b', 'Annie Ellington', 48);
insert into CareTaker (username, carerName, age) values ('rpourveer2c', 'Reeba Pourveer', 41);
insert into CareTaker (username, carerName, age) values ('cdenington2d', 'Carrol Denington', 24);
insert into CareTaker (username, carerName, age) values ('pzamorrano2e', 'Perl Zamorrano', 54);
insert into CareTaker (username, carerName, age) values ('gbrownrigg2f', 'Gussy Brownrigg', 75);
insert into CareTaker (username, carerName, age) values ('bbeardsley2g', 'Briant Beardsley', 59);
insert into CareTaker (username, carerName, age) values ('gstorms2h', 'Granthem Storms', 72);
insert into CareTaker (username, carerName, age) values ('jandresser2i', 'Jedd Andresser', 68);
insert into CareTaker (username, carerName, age) values ('zfowlston2j', 'Zacherie Fowlston', 42);
insert into CareTaker (username, carerName, age) values ('cbaack2k', 'Carlie Baack', 20);
insert into CareTaker (username, carerName, age) values ('hphin2l', 'Homerus Phin', 74);
insert into CareTaker (username, carerName, age) values ('podowne2m', 'Pincus O''Downe', 25);
insert into CareTaker (username, carerName, age) values ('vpethick2n', 'Victoria Pethick', 21);
insert into CareTaker (username, carerName, age) values ('kbouchier2o', 'Kendra Bouchier', 35);
insert into CareTaker (username, carerName, age) values ('hdorgan2p', 'Hall Dorgan', 19);
insert into CareTaker (username, carerName, age) values ('kpetherick2q', 'Kristofer Petherick', 35);
insert into CareTaker (username, carerName, age) values ('smuir2r', 'Steffi Muir', 28);
insert into CareTaker (username, carerName, age) values ('lchristaeas2s', 'Lurline Christaeas', 23);
insert into CareTaker (username, carerName, age) values ('tjoire2t', 'Tito Joire', 62);
insert into CareTaker (username, carerName, age) values ('lpichmann2u', 'Leigh Pichmann', 42);
insert into CareTaker (username, carerName, age) values ('ndozdill2v', 'Nina Dozdill', 38);
insert into CareTaker (username, carerName, age) values ('aaudus2w', 'Ashlen Audus', 27);
insert into CareTaker (username, carerName, age) values ('dtschierse2x', 'Dulcie Tschierse', 23);
insert into CareTaker (username, carerName, age) values ('gmathon2y', 'Giffer Mathon', 43);
insert into CareTaker (username, carerName, age) values ('pthomkins2z', 'Pauly Thomkins', 67);
insert into CareTaker (username, carerName, age) values ('mniezen30', 'Mead Niezen', 66);
insert into CareTaker (username, carerName, age) values ('shaydock31', 'Standford Haydock', 45);
insert into CareTaker (username, carerName, age) values ('cstickels32', 'Charmian Stickels', 67);
insert into CareTaker (username, carerName, age) values ('cfilan33', 'Cameron Filan', 39);
insert into CareTaker (username, carerName, age) values ('bcovendon34', 'Blane Covendon', 71);
insert into CareTaker (username, carerName, age) values ('cjanousek35', 'Cass Janousek', 23);
insert into CareTaker (username, carerName, age) values ('nmowbray36', 'Nickolas Mowbray', 71);
insert into CareTaker (username, carerName, age) values ('amilmo37', 'Ashley Milmo', 49);
insert into CareTaker (username, carerName, age) values ('lgerkens38', 'Levin Gerkens', 33);
insert into CareTaker (username, carerName, age) values ('aduplan39', 'Aloise Duplan', 24);
insert into CareTaker (username, carerName, age) values ('zbroggio3a', 'Zack Broggio', 53);
insert into CareTaker (username, carerName, age) values ('bphilpault3b', 'Byram Philpault', 58);
insert into CareTaker (username, carerName, age) values ('rgerber3c', 'Rozalie Gerber', 15);
insert into CareTaker (username, carerName, age) values ('rsheaf3d', 'Renelle Sheaf', 37);
insert into CareTaker (username, carerName, age) values ('ikingwell3e', 'Innis Kingwell', 23);
insert into CareTaker (username, carerName, age) values ('ltregea3f', 'Lorna Tregea', 53);
insert into CareTaker (username, carerName, age) values ('mde3g', 'Monika De Mico', 69);
insert into CareTaker (username, carerName, age) values ('igorrissen3h', 'Isidoro Gorrissen', 45);
insert into CareTaker (username, carerName, age) values ('bivanin3i', 'Billy Ivanin', 57);
insert into CareTaker (username, carerName, age) values ('ekaplan3j', 'Elvis Kaplan', 60);
insert into CareTaker (username, carerName, age) values ('lsapauton3k', 'Louella Sapauton', 61);
insert into CareTaker (username, carerName, age) values ('tobern3l', 'Tressa Obern', 19);
insert into CareTaker (username, carerName, age) values ('tgreenhaugh3m', 'Tybie Greenhaugh', 34);
insert into CareTaker (username, carerName, age) values ('jalmond3n', 'Jaine Almond', 33);
insert into CareTaker (username, carerName, age) values ('yjakoviljevic3o', 'Yoko Jakoviljevic', 28);
insert into CareTaker (username, carerName, age) values ('rwragg3p', 'Rayner Wragg', 32);
insert into CareTaker (username, carerName, age) values ('achoake3q', 'Alisha Choake', 51);
insert into CareTaker (username, carerName, age) values ('smetcalf3r', 'Stafani Metcalf', 21);
insert into CareTaker (username, carerName, age) values ('rshapera3s', 'Rolland Shapera', 20);
insert into CareTaker (username, carerName, age) values ('dgittings3t', 'Donnie Gittings', 38);
insert into CareTaker (username, carerName, age) values ('jsteddall3u', 'Jacob Steddall', 59);
insert into CareTaker (username, carerName, age) values ('lgiacaponi3v', 'Laird Giacaponi', 53);
insert into CareTaker (username, carerName, age) values ('ybruffell3w', 'Yolanthe Bruffell', 29);
insert into CareTaker (username, carerName, age) values ('edorman3x', 'Erl Dorman', 35);
insert into CareTaker (username, carerName, age) values ('msonier3y', 'Mariette Sonier', 24);
insert into CareTaker (username, carerName, age) values ('fbleiman3z', 'Frederica Bleiman', 46);
insert into CareTaker (username, carerName, age) values ('mlanfere40', 'Mitchael Lanfere', 72);
insert into CareTaker (username, carerName, age) values ('cgaucher41', 'Clayborn Gaucher', 41);
insert into CareTaker (username, carerName, age) values ('tbrunner42', 'Tillie Brunner', 74);
insert into CareTaker (username, carerName, age) values ('ahartridge43', 'Archibold Hartridge', 42);
insert into CareTaker (username, carerName, age) values ('sgowanson44', 'Somerset Gowanson', 53);
insert into CareTaker (username, carerName, age) values ('lmusgrove45', 'Linet Musgrove', 53);
insert into CareTaker (username, carerName, age) values ('dmacturlough46', 'Doug MacTurlough', 38);
insert into CareTaker (username, carerName, age) values ('ccassella47', 'Chiarra Cassella', 24);
insert into CareTaker (username, carerName, age) values ('mfransemai48', 'Marwin Fransemai', 28);
insert into CareTaker (username, carerName, age) values ('vbirth49', 'Valene Birth', 28);
insert into CareTaker (username, carerName, age) values ('osimmen4a', 'Onfre Simmen', 66);
insert into CareTaker (username, carerName, age) values ('sruscoe4b', 'Selby Ruscoe', 24);
insert into CareTaker (username, carerName, age) values ('triddich4c', 'Tiebold Riddich', 29);
insert into CareTaker (username, carerName, age) values ('dle4d', 'Dar Le Monnier', 28);
insert into CareTaker (username, carerName, age) values ('fdainter4e', 'Frederic Dainter', 36);
insert into CareTaker (username, carerName, age) values ('ssaphir4f', 'Shaylah Saphir', 39);
insert into CareTaker (username, carerName, age) values ('aaveyard4g', 'Ash Aveyard', 56);
insert into CareTaker (username, carerName, age) values ('squainton4h', 'Sal Quainton', 70);
insert into CareTaker (username, carerName, age) values ('spresser4i', 'Shane Presser', 57);
insert into CareTaker (username, carerName, age) values ('aabrahamian4j', 'Angela Abrahamian', 18);
insert into CareTaker (username, carerName, age) values ('mllewhellin4k', 'Morris Llewhellin', 28);
insert into CareTaker (username, carerName, age) values ('abiever4l', 'Antonella Biever', 70);
insert into CareTaker (username, carerName, age) values ('ndunkerley4m', 'Nolana Dunkerley', 66);
insert into CareTaker (username, carerName, age) values ('dde4n', 'Drew De Luna', 29);
insert into CareTaker (username, carerName, age) values ('peckly4o', 'Parry Eckly', 32);
insert into CareTaker (username, carerName, age) values ('daxtens4p', 'Dalia Axtens', 20);
insert into CareTaker (username, carerName, age) values ('rtrunkfield4q', 'Riva Trunkfield', 53);
insert into CareTaker (username, carerName, age) values ('mkuschel4r', 'Meredeth Kuschel', 72);
insert into CareTaker (username, carerName, age) values ('ccamel4s', 'Caty Camel', 36);
insert into CareTaker (username, carerName, age) values ('emacgarrity4t', 'Eberto MacGarrity', 55);
insert into CareTaker (username, carerName, age) values ('lvashchenko4u', 'Lonee Vashchenko', 53);
insert into CareTaker (username, carerName, age) values ('mde4v', 'Moina De Morena', 61);
insert into CareTaker (username, carerName, age) values ('kleary4w', 'Kipp Leary', 31);
insert into CareTaker (username, carerName, age) values ('ede4x', 'Edith de Amaya', 48);
insert into CareTaker (username, carerName, age) values ('gblanche4y', 'Griffith Blanche', 67);
insert into CareTaker (username, carerName, age) values ('lskrzynski4z', 'Lucina Skrzynski', 37);
insert into CareTaker (username, carerName, age) values ('cturbern50', 'Cordi Turbern', 70);
insert into CareTaker (username, carerName, age) values ('mtwentyman51', 'Maurie Twentyman', 34);
insert into CareTaker (username, carerName, age) values ('kschach52', 'Kaitlin Schach', 18);
insert into CareTaker (username, carerName, age) values ('cince53', 'Cari Ince', 70);
insert into CareTaker (username, carerName, age) values ('omeeland54', 'Otes Meeland', 25);
insert into CareTaker (username, carerName, age) values ('echittock55', 'Erwin Chittock', 56);
insert into CareTaker (username, carerName, age) values ('emenguy56', 'Evelyn Menguy', 17);
insert into CareTaker (username, carerName, age) values ('gbarks57', 'Gus Barks', 20);
insert into CareTaker (username, carerName, age) values ('aalliband58', 'Arleta Alliband', 74);
insert into CareTaker (username, carerName, age) values ('ebonnette59', 'Elnora Bonnette', 42);
insert into CareTaker (username, carerName, age) values ('apadell5a', 'Adolph Padell', 41);
insert into CareTaker (username, carerName, age) values ('eobbard5b', 'Edyth Obbard', 37);
insert into CareTaker (username, carerName, age) values ('rbamford5c', 'Roby Bamford', 68);
insert into CareTaker (username, carerName, age) values ('hbranchet5d', 'Hilarius Branchet', 58);
insert into CareTaker (username, carerName, age) values ('cpenswick5e', 'Constantina Penswick', 15);
insert into CareTaker (username, carerName, age) values ('sbiford5f', 'Skelly Biford', 66);
insert into CareTaker (username, carerName, age) values ('atout5g', 'Adolph Tout', 25);
insert into CareTaker (username, carerName, age) values ('mheskins5h', 'Mickie Heskins', 42);
insert into CareTaker (username, carerName, age) values ('ksycamore5i', 'Keane Sycamore', 52);
insert into CareTaker (username, carerName, age) values ('methridge5j', 'Mendy Ethridge', 47);
insert into CareTaker (username, carerName, age) values ('jde5k', 'Jessi De Angelis', 17);
insert into CareTaker (username, carerName, age) values ('do5l', 'Deloris O'' Finan', 61);
insert into CareTaker (username, carerName, age) values ('smcgillivrie5m', 'Sanford McGillivrie', 33);
insert into CareTaker (username, carerName, age) values ('lixor5n', 'Leora Ixor', 29);
insert into CareTaker (username, carerName, age) values ('jkimbury5o', 'Jerald Kimbury', 42);
insert into CareTaker (username, carerName, age) values ('npirrie5p', 'Nancey Pirrie', 62);
insert into CareTaker (username, carerName, age) values ('glainge5q', 'Gilburt Lainge', 30);
insert into CareTaker (username, carerName, age) values ('ugreenman5r', 'Ulrika Greenman', 72);
insert into CareTaker (username, carerName, age) values ('aabramowitch5s', 'Alfie Abramowitch', 42);
insert into CareTaker (username, carerName, age) values ('ibretherick5t', 'Irvine Bretherick', 57);
insert into CareTaker (username, carerName, age) values ('ejeynes5u', 'Editha Jeynes', 38);
insert into CareTaker (username, carerName, age) values ('odunge5v', 'Olivie Dunge', 32);
insert into CareTaker (username, carerName, age) values ('dhaselhurst5w', 'Dallis Haselhurst', 59);
insert into CareTaker (username, carerName, age) values ('aduxbarry5x', 'Angel Duxbarry', 44);
insert into CareTaker (username, carerName, age) values ('jcaltun5y', 'Janaya Caltun', 58);
insert into CareTaker (username, carerName, age) values ('sgirardez5z', 'Silvana Girardez', 69);
insert into CareTaker (username, carerName, age) values ('dlovitt60', 'Dalenna Lovitt', 18);
insert into CareTaker (username, carerName, age) values ('mmarcq61', 'Mirilla Marcq', 18);
insert into CareTaker (username, carerName, age) values ('wmeininking62', 'Wyatt Meininking', 58);
insert into CareTaker (username, carerName, age) values ('iclines63', 'Imojean Clines', 35);
insert into CareTaker (username, carerName, age) values ('jblinde64', 'Jori Blinde', 22);
insert into CareTaker (username, carerName, age) values ('tsears65', 'Tedd Sears', 18);
insert into CareTaker (username, carerName, age) values ('ashakespeare66', 'Almeria Shakespeare', 20);
insert into CareTaker (username, carerName, age) values ('cbeardsley67', 'Claiborne Beardsley', 56);
insert into CareTaker (username, carerName, age) values ('gten68', 'Gilli Ten Broek', 54);
insert into CareTaker (username, carerName, age) values ('rstrathe69', 'Ricky Strathe', 72);
insert into CareTaker (username, carerName, age) values ('wcuckson6a', 'Welbie Cuckson', 21);
insert into CareTaker (username, carerName, age) values ('nsearle6b', 'Nelle Searle', 50);
insert into CareTaker (username, carerName, age) values ('epieche6c', 'Edgar Pieche', 17);
insert into CareTaker (username, carerName, age) values ('crioch6d', 'Costanza Rioch', 36);
insert into CareTaker (username, carerName, age) values ('bhasker6e', 'Bo Hasker', 42);
insert into CareTaker (username, carerName, age) values ('amelson6f', 'Amii Melson', 67);
insert into CareTaker (username, carerName, age) values ('achazette6g', 'Allix Chazette', 20);
insert into CareTaker (username, carerName, age) values ('cdally6h', 'Charleen Dally', 16);
insert into CareTaker (username, carerName, age) values ('hmcartan6i', 'Heath McArtan', 23);
insert into CareTaker (username, carerName, age) values ('eberkley6j', 'Eugenio Berkley', 16);
insert into CareTaker (username, carerName, age) values ('dfurniss6k', 'Deena Furniss', 39);
insert into CareTaker (username, carerName, age) values ('kstaddart6l', 'Kienan Staddart', 20);
insert into CareTaker (username, carerName, age) values ('rbowkett6m', 'Rosabel Bowkett', 55);
insert into CareTaker (username, carerName, age) values ('jzecchinii6n', 'Jedd Zecchinii', 60);
insert into CareTaker (username, carerName, age) values ('fmackett6o', 'Francois Mackett', 62);
insert into CareTaker (username, carerName, age) values ('aabry6p', 'Aggie Abry', 21);
insert into CareTaker (username, carerName, age) values ('bschulz6q', 'Buddie Schulz', 32);
insert into CareTaker (username, carerName, age) values ('bhanaford6r', 'Barnard Hanaford', 57);
insert into CareTaker (username, carerName, age) values ('iaguirre6s', 'Iggy Aguirre', 17);
insert into CareTaker (username, carerName, age) values ('hmapledorum6t', 'Hubert Mapledorum', 49);
insert into CareTaker (username, carerName, age) values ('jmarzele6u', 'Jamill Marzele', 23);
insert into CareTaker (username, carerName, age) values ('mbarhem6v', 'Melantha Barhem', 52);
insert into CareTaker (username, carerName, age) values ('batger6w', 'Bradney Atger', 71);
insert into CareTaker (username, carerName, age) values ('ostoffels6x', 'Odessa Stoffels', 51);
insert into CareTaker (username, carerName, age) values ('cgatus6y', 'Chadd Gatus', 69);
insert into CareTaker (username, carerName, age) values ('hvasentsov6z', 'Harris Vasentsov', 61);
insert into CareTaker (username, carerName, age) values ('lgerner70', 'Lionel Gerner', 34);
insert into CareTaker (username, carerName, age) values ('bfalks71', 'Bertina Falks', 49);
insert into CareTaker (username, carerName, age) values ('geplett72', 'Garvey Eplett', 61);
insert into CareTaker (username, carerName, age) values ('mgontier73', 'Moses Gontier', 66);
insert into CareTaker (username, carerName, age) values ('breardon74', 'Bunny Reardon', 29);
insert into CareTaker (username, carerName, age) values ('mbewlay75', 'Marjie Bewlay', 16);
insert into CareTaker (username, carerName, age) values ('bapperley76', 'Bailey Apperley', 41);
insert into CareTaker (username, carerName, age) values ('mdurand77', 'Marji Durand', 51);
insert into CareTaker (username, carerName, age) values ('scleaver78', 'Stacie Cleaver', 66);
insert into CareTaker (username, carerName, age) values ('rmaffi79', 'Rafferty Maffi', 34);
insert into CareTaker (username, carerName, age) values ('ehardcastle7a', 'Ernesta Hardcastle', 25);
insert into CareTaker (username, carerName, age) values ('tbridel7b', 'Townie Bridel', 47);
insert into CareTaker (username, carerName, age) values ('aarchard7c', 'Addison Archard', 32);
insert into CareTaker (username, carerName, age) values ('mkerans7d', 'Maria Kerans', 18);
insert into CareTaker (username, carerName, age) values ('dtuxell7e', 'Dickie Tuxell', 36);
insert into CareTaker (username, carerName, age) values ('kmccoughan7f', 'Kasey McCoughan', 75);
insert into CareTaker (username, carerName, age) values ('rgarratty7g', 'Rosalinda Garratty', 67);
insert into CareTaker (username, carerName, age) values ('pholbury7h', 'Palm Holbury', 58);
insert into CareTaker (username, carerName, age) values ('wfarnan7i', 'Wilek Farnan', 46);
insert into CareTaker (username, carerName, age) values ('atrayton7j', 'Alia Trayton', 73);
insert into CareTaker (username, carerName, age) values ('sdrance7k', 'Sib Drance', 62);
insert into CareTaker (username, carerName, age) values ('legginson7l', 'Lorenzo Egginson', 35);
insert into CareTaker (username, carerName, age) values ('cgemnett7m', 'Claire Gemnett', 20);
insert into CareTaker (username, carerName, age) values ('gshearsby7n', 'Gabrielle Shearsby', 18);
insert into CareTaker (username, carerName, age) values ('lbeiderbecke7o', 'Lowrance Beiderbecke', 23);
insert into CareTaker (username, carerName, age) values ('mtwining7p', 'Misty Twining', 42);
insert into CareTaker (username, carerName, age) values ('kcortes7q', 'Kristal Cortes', 38);
insert into CareTaker (username, carerName, age) values ('klaurens7r', 'Kitty Laurens', 48);
insert into CareTaker (username, carerName, age) values ('reburah7s', 'Rosamond Eburah', 47);
insert into CareTaker (username, carerName, age) values ('ltidy7t', 'Leta Tidy', 51);
insert into CareTaker (username, carerName, age) values ('blindman7u', 'Brantley Lindman', 74);
insert into CareTaker (username, carerName, age) values ('rfearney7v', 'Riordan Fearney', 74);
insert into CareTaker (username, carerName, age) values ('gpickerell7w', 'Galvin Pickerell', 39);
insert into CareTaker (username, carerName, age) values ('lcroxon7x', 'Loria Croxon', 42);
insert into CareTaker (username, carerName, age) values ('tedgeller7y', 'Teodora Edgeller', 69);
insert into CareTaker (username, carerName, age) values ('vpickavant7z', 'Vivian Pickavant', 35);
insert into CareTaker (username, carerName, age) values ('cswadlinge80', 'Cecile Swadlinge', 31);
insert into CareTaker (username, carerName, age) values ('amoralee81', 'Aurea Moralee', 17);
insert into CareTaker (username, carerName, age) values ('wbisiker82', 'Winslow Bisiker', 33);
insert into CareTaker (username, carerName, age) values ('dfernehough83', 'Deeanne Fernehough', 61);
insert into CareTaker (username, carerName, age) values ('vdayce84', 'Val Dayce', 19);
insert into CareTaker (username, carerName, age) values ('hgunthorpe85', 'Henderson Gunthorpe', 22);
insert into CareTaker (username, carerName, age) values ('kdillaway86', 'Kim Dillaway', 66);
insert into CareTaker (username, carerName, age) values ('mfirebrace87', 'Martguerita Firebrace', 70);
insert into CareTaker (username, carerName, age) values ('ngoly88', 'Nadiya Goly', 32);
insert into CareTaker (username, carerName, age) values ('oclipston89', 'Ollie Clipston', 37);
insert into CareTaker (username, carerName, age) values ('bfilipczak8a', 'Berthe Filipczak', 62);
insert into CareTaker (username, carerName, age) values ('dmcgriffin8b', 'Dorey McGriffin', 30);
insert into CareTaker (username, carerName, age) values ('pclutterham8c', 'Paul Clutterham', 66);
insert into CareTaker (username, carerName, age) values ('blittlechild8d', 'Brucie Littlechild', 19);
insert into CareTaker (username, carerName, age) values ('othornham8e', 'Orel Thornham', 22);
insert into CareTaker (username, carerName, age) values ('elangelaan8f', 'Em Langelaan', 26);
insert into CareTaker (username, carerName, age) values ('mmerrigan8g', 'Maurizio Merrigan', 50);
insert into CareTaker (username, carerName, age) values ('sheppner8h', 'Shea Heppner', 69);
insert into CareTaker (username, carerName, age) values ('rocahill8i', 'Rosmunda O''Cahill', 24);
insert into CareTaker (username, carerName, age) values ('hsenussi8j', 'Hillier Senussi', 40);
insert into CareTaker (username, carerName, age) values ('fjerrold8k', 'Fabian Jerrold', 60);
insert into CareTaker (username, carerName, age) values ('ybury8l', 'Yvon Bury', 51);
insert into CareTaker (username, carerName, age) values ('lsanders8m', 'Loren Sanders', 70);
insert into CareTaker (username, carerName, age) values ('ncano8n', 'Neile Cano', 34);
insert into CareTaker (username, carerName, age) values ('obaversor8o', 'Osborn Baversor', 57);
insert into CareTaker (username, carerName, age) values ('aredish8p', 'Abbott Redish', 55);
insert into CareTaker (username, carerName, age) values ('jverrall8q', 'Jeremy Verrall', 17);
insert into CareTaker (username, carerName, age) values ('iseaking8r', 'Isadore Seaking', 23);
insert into CareTaker (username, carerName, age) values ('vspreag8s', 'Vittoria Spreag', 58);
insert into CareTaker (username, carerName, age) values ('jcavy8t', 'Jaymee Cavy', 33);
insert into CareTaker (username, carerName, age) values ('cvicar8u', 'Caria Vicar', 25);
insert into CareTaker (username, carerName, age) values ('ebakey8v', 'Elvyn Bakey', 42);
insert into CareTaker (username, carerName, age) values ('bpellamont8w', 'Boycey Pellamont', 21);
insert into CareTaker (username, carerName, age) values ('rpattullo8x', 'Radcliffe Pattullo', 32);
insert into CareTaker (username, carerName, age) values ('bbaynes8y', 'Barry Baynes', 46);
insert into CareTaker (username, carerName, age) values ('dkobiera8z', 'Dale Kobiera', 18);
insert into CareTaker (username, carerName, age) values ('rfudge90', 'Romola Fudge', 48);
insert into CareTaker (username, carerName, age) values ('kthexton91', 'Karleen Thexton', 39);
insert into CareTaker (username, carerName, age) values ('dbaffin92', 'Daphene Baffin', 26);
insert into CareTaker (username, carerName, age) values ('gfolonin93', 'Giff Folonin', 25);
insert into CareTaker (username, carerName, age) values ('vdesborough94', 'Vaclav Desborough', 59);
insert into CareTaker (username, carerName, age) values ('vaspinwall95', 'Vinnie Aspinwall', 48);
insert into CareTaker (username, carerName, age) values ('dphillpotts96', 'Diannne Phillpotts', 18);
insert into CareTaker (username, carerName, age) values ('bhurworth97', 'Bertrand Hurworth', 42);
insert into CareTaker (username, carerName, age) values ('gdi98', 'Gerhard Di Roberto', 21);
insert into CareTaker (username, carerName, age) values ('aschankel99', 'Aubree Schankel', 54);
insert into CareTaker (username, carerName, age) values ('tgyngyll9a', 'Tobin Gyngyll', 42);
insert into CareTaker (username, carerName, age) values ('agiovannardi9b', 'Andria Giovannardi', 54);
insert into CareTaker (username, carerName, age) values ('fsimenel9c', 'Franchot Simenel', 66);
insert into CareTaker (username, carerName, age) values ('cisoldi9d', 'Cecile Isoldi', 34);
insert into CareTaker (username, carerName, age) values ('cbeernt9e', 'Clem Beernt', 57);
insert into CareTaker (username, carerName, age) values ('sgrowden9f', 'Sigismundo Growden', 71);
insert into CareTaker (username, carerName, age) values ('rbovingdon9g', 'Regen Bovingdon', 28);
insert into CareTaker (username, carerName, age) values ('cgillard9h', 'Celestine Gillard', 43);
insert into CareTaker (username, carerName, age) values ('hgrumley9i', 'Hanan Grumley', 65);
insert into CareTaker (username, carerName, age) values ('pevill9j', 'Padget Evill', 44);
insert into CareTaker (username, carerName, age) values ('lmcindrew9k', 'Lisha McIndrew', 53);
insert into CareTaker (username, carerName, age) values ('mcayette9l', 'Madelyn Cayette', 34);
insert into CareTaker (username, carerName, age) values ('tscoggans9m', 'Theodor Scoggans', 75);
insert into CareTaker (username, carerName, age) values ('aknevet9n', 'Athene Knevet', 65);
insert into CareTaker (username, carerName, age) values ('lsalzen9o', 'Laverne Salzen', 55);
insert into CareTaker (username, carerName, age) values ('nkyffin9p', 'Noe Kyffin', 55);
insert into CareTaker (username, carerName, age) values ('kbatterton9q', 'Karina Batterton', 40);
insert into CareTaker (username, carerName, age) values ('dbrauns9r', 'Danette Brauns', 47);
insert into CareTaker (username, carerName, age) values ('dreach9s', 'Drucie Reach', 23);
insert into CareTaker (username, carerName, age) values ('rosborne9t', 'Robina Osborne', 62);
insert into CareTaker (username, carerName, age) values ('fnelmes9u', 'Fredericka Nelmes', 56);
insert into CareTaker (username, carerName, age) values ('jjarrell9v', 'Jennilee Jarrell', 57);
insert into CareTaker (username, carerName, age) values ('bgerrell9w', 'Broddy Gerrell', 25);
insert into CareTaker (username, carerName, age) values ('wtodeo9x', 'Wyatt Todeo', 55);
insert into CareTaker (username, carerName, age) values ('csustin9y', 'Clem Sustin', 36);
insert into CareTaker (username, carerName, age) values ('amullinder9z', 'Abagael Mullinder', 60);
insert into CareTaker (username, carerName, age) values ('kmalecka0', 'Kalinda Maleck', 22);
insert into CareTaker (username, carerName, age) values ('ahallicka1', 'Alica Hallick', 56);
insert into CareTaker (username, carerName, age) values ('abennoea2', 'Annie Bennoe', 55);
insert into CareTaker (username, carerName, age) values ('ptruggiana3', 'Prudi Truggian', 45);
insert into CareTaker (username, carerName, age) values ('aschwanta4', 'Alvan Schwant', 32);
insert into CareTaker (username, carerName, age) values ('kflighta5', 'Kay Flight', 26);
insert into CareTaker (username, carerName, age) values ('dskowcrafta6', 'Dosi Skowcraft', 36);
insert into CareTaker (username, carerName, age) values ('hjeskea7', 'Harlie Jeske', 41);
insert into CareTaker (username, carerName, age) values ('tfidgea8', 'Trina Fidge', 32);
insert into CareTaker (username, carerName, age) values ('edaintera9', 'Elwin Dainter', 53);
insert into CareTaker (username, carerName, age) values ('jannaa', 'Jo ann Treherne', 47);
insert into CareTaker (username, carerName, age) values ('mayreab', 'Madelin Ayre', 52);
insert into CareTaker (username, carerName, age) values ('lketcherac', 'Lorens Ketcher', 43);
insert into CareTaker (username, carerName, age) values ('gcossonsad', 'Gilbert Cossons', 47);
insert into CareTaker (username, carerName, age) values ('gdanielae', 'Guntar Daniel', 64);
insert into CareTaker (username, carerName, age) values ('cbarenskieaf', 'Cahra Barenskie', 57);
insert into CareTaker (username, carerName, age) values ('lailmerag', 'Leonard Ailmer', 72);
insert into CareTaker (username, carerName, age) values ('fwoodwingah', 'Fayre Woodwing', 46);
insert into CareTaker (username, carerName, age) values ('bgillionai', 'Blair Gillion', 59);
insert into CareTaker (username, carerName, age) values ('jwestcotaj', 'Jules Westcot', 56);
insert into CareTaker (username, carerName, age) values ('rrosengartenak', 'Rianon Rosengarten', 53);
insert into CareTaker (username, carerName, age) values ('agerretsenal', 'Augustine Gerretsen', 41);
insert into CareTaker (username, carerName, age) values ('gbrunkeam', 'Gillan Brunke', 50);
insert into CareTaker (username, carerName, age) values ('wcouvesan', 'Wash Couves', 40);
insert into CareTaker (username, carerName, age) values ('pfattoriniao', 'Pearl Fattorini', 45);
insert into CareTaker (username, carerName, age) values ('cbaptistaap', 'Catie Baptista', 16);
insert into CareTaker (username, carerName, age) values ('gcracieaq', 'Genvieve Cracie', 33);
insert into CareTaker (username, carerName, age) values ('ochadneyar', 'Obie Chadney', 25);
insert into CareTaker (username, carerName, age) values ('mquinetas', 'Maddie Quinet', 68);
insert into CareTaker (username, carerName, age) values ('nweightat', 'Nani Weight', 53);
insert into CareTaker (username, carerName, age) values ('okeetleyau', 'Olva Keetley', 38);
insert into CareTaker (username, carerName, age) values ('omcphilipav', 'Ogden McPhilip', 30);
insert into CareTaker (username, carerName, age) values ('lbrafertonaw', 'Luciana Braferton', 61);
insert into CareTaker (username, carerName, age) values ('anylesax', 'Anatollo Nyles', 34);
insert into CareTaker (username, carerName, age) values ('cpendreyay', 'Celina Pendrey', 70);
insert into CareTaker (username, carerName, age) values ('rmaryetaz', 'Ronica Maryet', 43);
insert into CareTaker (username, carerName, age) values ('draubenheimb0', 'Daniella Raubenheim', 15);
insert into CareTaker (username, carerName, age) values ('rcurrumb1', 'Ronni Currum', 52);
insert into CareTaker (username, carerName, age) values ('ksimkissb2', 'Karina Simkiss', 25);
insert into CareTaker (username, carerName, age) values ('mfolinib3', 'Murdoch Folini', 44);
insert into CareTaker (username, carerName, age) values ('epavelkab4', 'Emmeline Pavelka', 25);
insert into CareTaker (username, carerName, age) values ('ejearumb5', 'Ellynn Jearum', 69);
insert into CareTaker (username, carerName, age) values ('bsmailb6', 'Benjamen Smail', 24);
insert into CareTaker (username, carerName, age) values ('kibbersonb7', 'Kathie Ibberson', 20);
insert into CareTaker (username, carerName, age) values ('zhubbardb8', 'Zaria Hubbard', 50);
insert into CareTaker (username, carerName, age) values ('mfitzroyb9', 'Micheline Fitzroy', 72);
insert into CareTaker (username, carerName, age) values ('eschwanderba', 'Edgardo Schwander', 70);
insert into CareTaker (username, carerName, age) values ('mgandleybb', 'Mariel Gandley', 42);
insert into CareTaker (username, carerName, age) values ('agarritbc', 'Anette Garrit', 63);
insert into CareTaker (username, carerName, age) values ('hborgarsbd', 'Halsey Borgars', 68);
insert into CareTaker (username, carerName, age) values ('nganforthbe', 'Nicol Ganforth', 66);
insert into CareTaker (username, carerName, age) values ('telsleybf', 'Tannie Elsley', 44);
insert into CareTaker (username, carerName, age) values ('rsheavillsbg', 'Ruggiero Sheavills', 25);
insert into CareTaker (username, carerName, age) values ('clamckenbh', 'Cass Lamcken', 75);
insert into CareTaker (username, carerName, age) values ('trubinowbi', 'Tiphanie Rubinow', 25);
insert into CareTaker (username, carerName, age) values ('bbatterhambj', 'Brendan Batterham', 66);
insert into CareTaker (username, carerName, age) values ('pnysbk', 'Pate Nys', 27);
insert into CareTaker (username, carerName, age) values ('mbolderobl', 'Mill Boldero', 50);
insert into CareTaker (username, carerName, age) values ('vhartburnbm', 'Venita Hartburn', 64);
insert into CareTaker (username, carerName, age) values ('hdacresbn', 'Harman Dacres', 55);
insert into CareTaker (username, carerName, age) values ('ecarssbo', 'Ethelbert Carss', 70);
insert into CareTaker (username, carerName, age) values ('pmcgerraghtybp', 'Pauly McGerraghty', 27);
insert into CareTaker (username, carerName, age) values ('lpozzibq', 'Lauraine Pozzi', 37);
insert into CareTaker (username, carerName, age) values ('hzanucioliibr', 'Harbert Zanuciolii', 57);
insert into CareTaker (username, carerName, age) values ('nmullissbs', 'Nathan Mulliss', 28);
insert into CareTaker (username, carerName, age) values ('ewardallbt', 'Eldon Wardall', 35);
insert into CareTaker (username, carerName, age) values ('lbenkhebu', 'Lucias Benkhe', 18);
insert into CareTaker (username, carerName, age) values ('ecrohanbv', 'Ethelda Crohan', 41);
insert into CareTaker (username, carerName, age) values ('jmorrottbw', 'Jed Morrott', 64);
insert into CareTaker (username, carerName, age) values ('ahollowbx', 'Archy Hollow', 63);
insert into CareTaker (username, carerName, age) values ('omckeighanby', 'Ole McKeighan', 74);
insert into CareTaker (username, carerName, age) values ('fmackibbonbz', 'Ferrell MacKibbon', 23);
insert into CareTaker (username, carerName, age) values ('jnuddsc0', 'Joli Nudds', 41);
insert into CareTaker (username, carerName, age) values ('cbaisec1', 'Clyve Baise', 46);
insert into CareTaker (username, carerName, age) values ('rmewburnc2', 'Reed Mewburn', 20);
insert into CareTaker (username, carerName, age) values ('sedworthiec3', 'Silva Edworthie', 52);
insert into CareTaker (username, carerName, age) values ('dlittlemorec4', 'Dulcia Littlemore', 65);
insert into CareTaker (username, carerName, age) values ('kfetherstonc5', 'Kacie Fetherston', 18);
insert into CareTaker (username, carerName, age) values ('kfundellc6', 'Kassia Fundell', 36);
insert into CareTaker (username, carerName, age) values ('dhullc7', 'Dominique Hull', 33);
insert into CareTaker (username, carerName, age) values ('mjannc8', 'Meghann Jann', 37);
insert into CareTaker (username, carerName, age) values ('mtrudgionc9', 'Malissa Trudgion', 44);
insert into CareTaker (username, carerName, age) values ('msawca', 'Maribelle Saw', 64);
insert into CareTaker (username, carerName, age) values ('brumsbycb', 'Brnaby Rumsby', 57);
insert into CareTaker (username, carerName, age) values ('wdaleycc', 'Wendye Daley', 37);
insert into CareTaker (username, carerName, age) values ('asmewincd', 'Andros Smewin', 65);
insert into CareTaker (username, carerName, age) values ('amcgebenayce', 'Algernon McGebenay', 26);
insert into CareTaker (username, carerName, age) values ('nmcbeithcf', 'Noelyn McBeith', 28);
insert into CareTaker (username, carerName, age) values ('jhustingscg', 'Janessa Hustings', 45);
insert into CareTaker (username, carerName, age) values ('gvinckch', 'Gabriel Vinck', 62);
insert into CareTaker (username, carerName, age) values ('mscardefieldci', 'Meggi Scardefield', 66);
insert into CareTaker (username, carerName, age) values ('btoynbeecj', 'Brigitte Toynbee', 46);
insert into CareTaker (username, carerName, age) values ('cpechack', 'Claybourne Pecha', 33);
insert into CareTaker (username, carerName, age) values ('vkirbycl', 'Violante Kirby', 73);
insert into CareTaker (username, carerName, age) values ('pclarkincm', 'Paulie Clarkin', 32);
insert into CareTaker (username, carerName, age) values ('lkrysztofiakcn', 'Louis Krysztofiak', 60);
insert into CareTaker (username, carerName, age) values ('jobbardco', 'Judah Obbard', 17);
insert into CareTaker (username, carerName, age) values ('atoothillcp', 'Adria Toothill', 41);
insert into CareTaker (username, carerName, age) values ('sstobbescq', 'Symon Stobbes', 69);
insert into CareTaker (username, carerName, age) values ('vderbycr', 'Veronique Derby', 35);
insert into CareTaker (username, carerName, age) values ('torrocs', 'Teddie Orro', 24);
insert into CareTaker (username, carerName, age) values ('ekoenraadct', 'Ely Koenraad', 51);
insert into CareTaker (username, carerName, age) values ('anewartcu', 'Arlene Newart', 29);
insert into CareTaker (username, carerName, age) values ('ledisoncv', 'Lanae Edison', 19);
insert into CareTaker (username, carerName, age) values ('kprovercw', 'Kaylil Prover', 70);
insert into CareTaker (username, carerName, age) values ('hshemmingcx', 'Hollie Shemming', 43);
insert into CareTaker (username, carerName, age) values ('klecointecy', 'Kerri Lecointe', 75);
insert into CareTaker (username, carerName, age) values ('mklemmtcz', 'Maisie Klemmt', 66);
insert into CareTaker (username, carerName, age) values ('mrenderd0', 'Marabel Render', 54);
insert into CareTaker (username, carerName, age) values ('rhamblettd1', 'Rochelle Hamblett', 32);
insert into CareTaker (username, carerName, age) values ('rambrozd2', 'Russ Ambroz', 43);
insert into CareTaker (username, carerName, age) values ('rbutchardd3', 'Rabbi Butchard', 69);
insert into CareTaker (username, carerName, age) values ('lissacsond4', 'Leah Issacson', 52);
insert into CareTaker (username, carerName, age) values ('akeelind5', 'Almire Keelin', 20);
insert into CareTaker (username, carerName, age) values ('astutted6', 'Anjela Stutte', 52);
insert into CareTaker (username, carerName, age) values ('whucknalld7', 'Winfred Hucknall', 52);
insert into CareTaker (username, carerName, age) values ('aeried8', 'Augustina Erie', 72);
insert into CareTaker (username, carerName, age) values ('ddoored9', 'Daphna Doore', 33);
insert into CareTaker (username, carerName, age) values ('ahankinsonda', 'Amber Hankinson', 70);
insert into CareTaker (username, carerName, age) values ('wsmartmandb', 'Wilmette Smartman', 53);
insert into CareTaker (username, carerName, age) values ('ljeedc', 'Lise Jee', 32);
insert into CareTaker (username, carerName, age) values ('dbenarddd', 'Darrel Benard', 42);
insert into CareTaker (username, carerName, age) values ('ldonide', 'Lexi Doni', 23);
insert into CareTaker (username, carerName, age) values ('lcradocdf', 'Lisle Cradoc', 54);
insert into CareTaker (username, carerName, age) values ('gcraigmyledg', 'Geri Craigmyle', 67);
insert into CareTaker (username, carerName, age) values ('fnowakowskadh', 'Ferdie Nowakowska', 63);
insert into CareTaker (username, carerName, age) values ('mfinlowdi', 'Marna Finlow', 28);
insert into CareTaker (username, carerName, age) values ('agepsondj', 'Anatol Gepson', 24);
insert into CareTaker (username, carerName, age) values ('gathelstandk', 'Gaynor Athelstan', 24);
insert into CareTaker (username, carerName, age) values ('hmccurtdl', 'Hort McCurt', 46);
insert into CareTaker (username, carerName, age) values ('vmackrielldm', 'Vanny Mackriell', 56);
insert into CareTaker (username, carerName, age) values ('rdignalldn', 'Rocky Dignall', 47);
insert into CareTaker (username, carerName, age) values ('qtatlockdo', 'Querida Tatlock', 25);
insert into CareTaker (username, carerName, age) values ('rcorterdp', 'Raffaello Corter', 32);
insert into CareTaker (username, carerName, age) values ('nshelpdq', 'Newton Shelp', 33);
insert into CareTaker (username, carerName, age) values ('bdunforddr', 'Brenna Dunford', 72);
insert into CareTaker (username, carerName, age) values ('tatlingds', 'Trey Atling', 46);
insert into CareTaker (username, carerName, age) values ('mmartschkedt', 'Mickie Martschke', 35);
insert into CareTaker (username, carerName, age) values ('torringdu', 'Timmy Orring', 68);
insert into CareTaker (username, carerName, age) values ('gfletcherdv', 'Gino Fletcher', 58);
insert into CareTaker (username, carerName, age) values ('dsuggeydw', 'Donn Suggey', 66);
insert into CareTaker (username, carerName, age) values ('ctendx', 'Cori Ten Broek', 55);
insert into CareTaker (username, carerName, age) values ('ghumbeedy', 'Goldi Humbee', 73);
insert into CareTaker (username, carerName, age) values ('jbeavendz', 'Junia Beaven', 36);
insert into CareTaker (username, carerName, age) values ('lnewartee0', 'Loni Newarte', 42);
insert into CareTaker (username, carerName, age) values ('leville1', 'Luce Evill', 58);
insert into CareTaker (username, carerName, age) values ('ewilkinsone2', 'Eleanora Wilkinson', 29);
insert into CareTaker (username, carerName, age) values ('rsmurfitte3', 'Rhodie Smurfitt', 39);
insert into CareTaker (username, carerName, age) values ('tbatone4', 'Torrence Baton', 17);
insert into CareTaker (username, carerName, age) values ('sassitere5', 'Sterne Assiter', 67);
insert into CareTaker (username, carerName, age) values ('fangersteine6', 'Frannie Angerstein', 68);
insert into CareTaker (username, carerName, age) values ('mfiste7', 'Moshe Fist', 25);
insert into CareTaker (username, carerName, age) values ('cconnicke8', 'Catie Connick', 33);
insert into CareTaker (username, carerName, age) values ('fhazemane9', 'Ferguson Hazeman', 70);
insert into CareTaker (username, carerName, age) values ('whounsomea', 'Wilmette Hounsom', 23);
insert into CareTaker (username, carerName, age) values ('gkerneb', 'Gene Kern', 18);
insert into CareTaker (username, carerName, age) values ('lmehargec', 'Lezlie Meharg', 57);
insert into CareTaker (username, carerName, age) values ('cwadduped', 'Clara Waddup', 36);
insert into CareTaker (username, carerName, age) values ('cgoslinee', 'Carlen Goslin', 58);
insert into CareTaker (username, carerName, age) values ('ybwyeef', 'Yuma Bwye', 55);
insert into CareTaker (username, carerName, age) values ('lportingaleeg', 'Leoine Portingale', 61);
insert into CareTaker (username, carerName, age) values ('ystiegerseh', 'Yvon Stiegers', 65);
insert into CareTaker (username, carerName, age) values ('binchcombei', 'Bobette Inchcomb', 62);
insert into CareTaker (username, carerName, age) values ('kwinsonej', 'Kissiah Winson', 75);
insert into CareTaker (username, carerName, age) values ('edurbynek', 'Edan Durbyn', 27);
insert into CareTaker (username, carerName, age) values ('edemicoliel', 'Estrella Demicoli', 56);
insert into CareTaker (username, carerName, age) values ('tdenneyem', 'Taber Denney', 23);
insert into CareTaker (username, carerName, age) values ('dwoodhallen', 'Dimitri Woodhall', 29);
insert into CareTaker (username, carerName, age) values ('sboullineo', 'Somerset Boullin', 22);
insert into CareTaker (username, carerName, age) values ('rloverockep', 'Ruth Loverock', 59);
insert into CareTaker (username, carerName, age) values ('rdummereq', 'Rowen Dummer', 60);
insert into CareTaker (username, carerName, age) values ('smerrickser', 'Stillman Merricks', 66);
insert into CareTaker (username, carerName, age) values ('droutes', 'Dolley Rout', 53);
insert into CareTaker (username, carerName, age) values ('jbauduccioet', 'Jennifer Bauduccio', 25);
insert into CareTaker (username, carerName, age) values ('zlambleeu', 'Zea Lamble', 68);
insert into CareTaker (username, carerName, age) values ('btaplowev', 'Brady Taplow', 15);
insert into CareTaker (username, carerName, age) values ('akornalikew', 'Aundrea Kornalik', 53);
insert into CareTaker (username, carerName, age) values ('snorthleighex', 'Shalna Northleigh', 41);
insert into CareTaker (username, carerName, age) values ('flamertoney', 'Felix Lamerton', 66);
insert into CareTaker (username, carerName, age) values ('nbouslerez', 'Nona Bousler', 68);
insert into CareTaker (username, carerName, age) values ('keldertonf0', 'Kay Elderton', 47);
insert into CareTaker (username, carerName, age) values ('tcattemullf1', 'Trefor Cattemull', 67);
insert into CareTaker (username, carerName, age) values ('tfianderf2', 'Thaddeus Fiander', 40);
insert into CareTaker (username, carerName, age) values ('mallpressf3', 'Meredith Allpress', 37);
insert into CareTaker (username, carerName, age) values ('uvanf4', 'Ulberto Van den Oord', 41);
insert into CareTaker (username, carerName, age) values ('ldef5', 'Liana de Amaya', 23);
insert into CareTaker (username, carerName, age) values ('swesonf6', 'Skell Weson', 30);
insert into CareTaker (username, carerName, age) values ('ridiensf7', 'Ronda Idiens', 62);
insert into CareTaker (username, carerName, age) values ('gscamerdenf8', 'Gwenette Scamerden', 69);
insert into CareTaker (username, carerName, age) values ('wrothertf9', 'Willie Rothert', 62);
insert into CareTaker (username, carerName, age) values ('nviscofa', 'Nigel Visco', 43);
insert into CareTaker (username, carerName, age) values ('pworsnupfb', 'Peria Worsnup', 27);
insert into CareTaker (username, carerName, age) values ('heagletonfc', 'Harriet Eagleton', 72);
insert into CareTaker (username, carerName, age) values ('gmclainefd', 'Guthrey McLaine', 58);
insert into CareTaker (username, carerName, age) values ('kalflatfe', 'Kelsy Alflat', 45);
insert into CareTaker (username, carerName, age) values ('fayreeff', 'Freddie Ayree', 36);
insert into CareTaker (username, carerName, age) values ('cdewhirstfg', 'Clemence Dewhirst', 66);
insert into CareTaker (username, carerName, age) values ('gberefh', 'Glad Bere', 24);
insert into CareTaker (username, carerName, age) values ('mcornhillfi', 'Mathilda Cornhill', 53);
insert into CareTaker (username, carerName, age) values ('kfibbensfj', 'Katie Fibbens', 24);
insert into CareTaker (username, carerName, age) values ('lwhitemanfk', 'Leann Whiteman', 23);
insert into CareTaker (username, carerName, age) values ('rrichlyfl', 'Rosana Richly', 48);
insert into CareTaker (username, carerName, age) values ('rbarbiefm', 'Raquela Barbie', 27);
insert into CareTaker (username, carerName, age) values ('mswatradgefn', 'Menard Swatradge', 71);
insert into CareTaker (username, carerName, age) values ('hstainerfo', 'Helene Stainer', 26);
insert into CareTaker (username, carerName, age) values ('awillimotfp', 'Allistir Willimot', 36);
insert into CareTaker (username, carerName, age) values ('bheinofq', 'Benjy Heino', 52);
insert into CareTaker (username, carerName, age) values ('lfalshawfr', 'Letta Falshaw', 21);
insert into CareTaker (username, carerName, age) values ('nblackbournfs', 'Nana Blackbourn', 71);
insert into CareTaker (username, carerName, age) values ('atolcherft', 'Adolpho Tolcher', 29);
insert into CareTaker (username, carerName, age) values ('scompfortfu', 'Stephanie Compfort', 42);
insert into CareTaker (username, carerName, age) values ('acastellifv', 'Aloysius Castelli', 42);
insert into CareTaker (username, carerName, age) values ('lchristofefw', 'Laureen Christofe', 21);
insert into CareTaker (username, carerName, age) values ('hsandesonfx', 'Hoebart Sandeson', 45);
insert into CareTaker (username, carerName, age) values ('rpriestnerfy', 'Rebekah Priestner', 58);
insert into CareTaker (username, carerName, age) values ('oboothebiefz', 'Osmund Boothebie', 52);
insert into CareTaker (username, carerName, age) values ('lglentong0', 'Lilli Glenton', 54);
insert into CareTaker (username, carerName, age) values ('teratg1', 'Tris Erat', 33);
insert into CareTaker (username, carerName, age) values ('gpenhaleurackg2', 'Gizela Penhaleurack', 70);
insert into CareTaker (username, carerName, age) values ('twreakg3', 'Twyla Wreak', 71);
insert into CareTaker (username, carerName, age) values ('srobinetteg4', 'Shena Robinette', 18);
insert into CareTaker (username, carerName, age) values ('cgiraudelg5', 'Cornie Giraudel', 51);
insert into CareTaker (username, carerName, age) values ('nfogartyg6', 'Nye Fogarty', 75);
insert into CareTaker (username, carerName, age) values ('dcharding7', 'Drona Chardin', 27);
insert into CareTaker (username, carerName, age) values ('cfollandg8', 'Colan Folland', 45);
insert into CareTaker (username, carerName, age) values ('agynng9', 'Agnola Gynn', 43);
insert into CareTaker (username, carerName, age) values ('cbardega', 'Carry Barde', 54);
insert into CareTaker (username, carerName, age) values ('lfollingb', 'Leesa Follin', 34);
insert into CareTaker (username, carerName, age) values ('bvongc', 'Blinni von Nassau', 53);
insert into CareTaker (username, carerName, age) values ('klegendregd', 'Korey Legendre', 57);
insert into CareTaker (username, carerName, age) values ('koakshottge', 'Kev Oakshott', 55);
insert into CareTaker (username, carerName, age) values ('kockendengf', 'Kelly Ockenden', 39);
insert into CareTaker (username, carerName, age) values ('jisenorgg', 'Jodi Isenor', 50);
insert into CareTaker (username, carerName, age) values ('sloblegh', 'Sollie Loble', 17);
insert into CareTaker (username, carerName, age) values ('kdaingi', 'Kessiah Dain', 42);
insert into CareTaker (username, carerName, age) values ('sslimongj', 'Sophia Slimon', 47);
insert into CareTaker (username, carerName, age) values ('hdayegk', 'Hope Daye', 71);
insert into CareTaker (username, carerName, age) values ('mlinkletergl', 'Meara Linkleter', 64);
insert into CareTaker (username, carerName, age) values ('dnorthamgm', 'Dredi Northam', 53);
insert into CareTaker (username, carerName, age) values ('zwileygn', 'Zachery Wiley', 40);
insert into CareTaker (username, carerName, age) values ('ttrelevengo', 'Tony Treleven', 62);
insert into CareTaker (username, carerName, age) values ('gcranmorgp', 'Galen Cranmor', 23);
insert into CareTaker (username, carerName, age) values ('denosgq', 'Deidre Enos', 19);
insert into CareTaker (username, carerName, age) values ('lmerwedegr', 'Linc Merwede', 71);
insert into CareTaker (username, carerName, age) values ('fdarleygs', 'Felicle Darley', 27);
insert into CareTaker (username, carerName, age) values ('amaiorgt', 'Alfredo Maior', 37);
insert into CareTaker (username, carerName, age) values ('sclemendotgu', 'Skipp Clemendot', 49);
insert into CareTaker (username, carerName, age) values ('gjouannissongv', 'Ginger Jouannisson', 57);
insert into CareTaker (username, carerName, age) values ('lheinemanngw', 'Lorain Heinemann', 24);
insert into CareTaker (username, carerName, age) values ('mhaxbiegx', 'Mariquilla Haxbie', 54);
insert into CareTaker (username, carerName, age) values ('bjakobssongy', 'Bryna Jakobsson', 71);
insert into CareTaker (username, carerName, age) values ('kgoodlipgz', 'Katleen Goodlip', 60);
insert into CareTaker (username, carerName, age) values ('tsparroweh0', 'Theodoric Sparrowe', 21);
insert into CareTaker (username, carerName, age) values ('cdevilh1', 'Costa Devil', 18);
insert into CareTaker (username, carerName, age) values ('mforsytheh2', 'Moses Forsythe', 50);
insert into CareTaker (username, carerName, age) values ('lgiacobinih3', 'Lorrin Giacobini', 37);
insert into CareTaker (username, carerName, age) values ('cvaulsh4', 'Ciro Vauls', 50);
insert into CareTaker (username, carerName, age) values ('jwesonh5', 'Jenifer Weson', 29);
insert into CareTaker (username, carerName, age) values ('ggrisedaleh6', 'Gary Grisedale', 75);
insert into CareTaker (username, carerName, age) values ('nhardageh7', 'Nari Hardage', 37);
insert into CareTaker (username, carerName, age) values ('dwardinglyh8', 'Donni Wardingly', 45);
insert into CareTaker (username, carerName, age) values ('vwalasikh9', 'Vonni Walasik', 21);
insert into CareTaker (username, carerName, age) values ('hcheneha', 'Hermann Chene', 30);
insert into CareTaker (username, carerName, age) values ('eaddamshb', 'Erminia Addams', 43);
insert into CareTaker (username, carerName, age) values ('dwynnehc', 'Dido Wynne', 60);
insert into CareTaker (username, carerName, age) values ('ssutterbyhd', 'Shepperd Sutterby', 34);
insert into CareTaker (username, carerName, age) values ('lblackfordhe', 'Lynda Blackford', 67);
insert into CareTaker (username, carerName, age) values ('lshropshirehf', 'Lenard Shropshire', 32);
insert into CareTaker (username, carerName, age) values ('chebdenhg', 'Corey Hebden', 24);
insert into CareTaker (username, carerName, age) values ('fsommervillehh', 'Florette Sommerville', 67);
insert into CareTaker (username, carerName, age) values ('gcasottihi', 'Guthrey Casotti', 30);
insert into CareTaker (username, carerName, age) values ('haxonhj', 'Hermon Axon', 48);
insert into CareTaker (username, carerName, age) values ('adetloffhk', 'Angeline Detloff', 47);
insert into CareTaker (username, carerName, age) values ('uboundehl', 'Ursuline Bounde', 45);
insert into CareTaker (username, carerName, age) values ('rbergstrandhm', 'Robby Bergstrand', 19);
insert into CareTaker (username, carerName, age) values ('pcristoferihn', 'Philipa Cristoferi', 59);
insert into CareTaker (username, carerName, age) values ('mlancastleho', 'Miguela Lancastle', 21);
insert into CareTaker (username, carerName, age) values ('fduckershp', 'Flo Duckers', 32);
insert into CareTaker (username, carerName, age) values ('ealmeyhq', 'Evelyn Almey', 43);
insert into CareTaker (username, carerName, age) values ('ajuetthr', 'Alan Juett', 65);
insert into CareTaker (username, carerName, age) values ('glangstonehs', 'Gualterio Langstone', 62);
insert into CareTaker (username, carerName, age) values ('ncattleht', 'Niccolo Cattle', 74);
insert into CareTaker (username, carerName, age) values ('nlaverenzhu', 'Nichol Laverenz', 16);
insert into CareTaker (username, carerName, age) values ('kandreuttihv', 'Kalli Andreutti', 71);
insert into CareTaker (username, carerName, age) values ('nmacfarlanhw', 'Novelia MacFarlan', 69);
insert into CareTaker (username, carerName, age) values ('kvalentellihx', 'Kameko Valentelli', 20);
insert into CareTaker (username, carerName, age) values ('etamletthy', 'Elli Tamlett', 60);
insert into CareTaker (username, carerName, age) values ('slansdalehz', 'Shanan Lansdale', 46);
insert into CareTaker (username, carerName, age) values ('syanelei0', 'Sheba Yanele', 74);
insert into CareTaker (username, carerName, age) values ('npenasi1', 'Nester Penas', 46);
insert into CareTaker (username, carerName, age) values ('ucarbonelli2', 'Ulric Carbonell', 34);
insert into CareTaker (username, carerName, age) values ('gumplebyi3', 'Gerik Umpleby', 15);
insert into CareTaker (username, carerName, age) values ('hhugonneti4', 'Hermia Hugonnet', 20);
insert into CareTaker (username, carerName, age) values ('bshanei5', 'Brinna Shane', 42);
insert into CareTaker (username, carerName, age) values ('rgosticki6', 'Richart Gostick', 56);
insert into CareTaker (username, carerName, age) values ('avani7', 'Auria Van Son', 30);
insert into CareTaker (username, carerName, age) values ('fleidli8', 'Frannie Leidl', 39);
insert into CareTaker (username, carerName, age) values ('canderli9', 'Crissie Anderl', 37);
insert into CareTaker (username, carerName, age) values ('fgrzeszczakia', 'Filbert Grzeszczak', 57);
insert into CareTaker (username, carerName, age) values ('sbormanib', 'Sascha Borman', 34);
insert into CareTaker (username, carerName, age) values ('bwilshireic', 'Brooks Wilshire', 73);
insert into CareTaker (username, carerName, age) values ('nkoppid', 'Nettle Kopp', 34);
insert into CareTaker (username, carerName, age) values ('gkachellerie', 'Ginnie Kacheller', 50);
insert into CareTaker (username, carerName, age) values ('mcollacombeif', 'Marsha Collacombe', 70);
insert into CareTaker (username, carerName, age) values ('pkellandig', 'Pincus Kelland', 64);
insert into CareTaker (username, carerName, age) values ('trosternih', 'Tomlin Rostern', 43);
insert into CareTaker (username, carerName, age) values ('ulavissii', 'Ursola Laviss', 32);
insert into CareTaker (username, carerName, age) values ('cmackessockij', 'Caresa MacKessock', 41);
insert into CareTaker (username, carerName, age) values ('gtendahlik', 'Gunther Tendahl', 75);
insert into CareTaker (username, carerName, age) values ('aabreyil', 'Aaren Abrey', 71);
insert into CareTaker (username, carerName, age) values ('bdeim', 'Bealle De Blasi', 44);
insert into CareTaker (username, carerName, age) values ('jsealovein', 'Joe Sealove', 33);
insert into CareTaker (username, carerName, age) values ('scarlsonio', 'Suzanna Carlson', 73);
insert into CareTaker (username, carerName, age) values ('jvanip', 'Jolyn Van Daalen', 50);
insert into CareTaker (username, carerName, age) values ('dtickleiq', 'Devlin Tickle', 63);
insert into CareTaker (username, carerName, age) values ('smacdearmontir', 'Sunny MacDearmont', 64);
insert into CareTaker (username, carerName, age) values ('bfrendis', 'Bernita Frend', 37);
insert into CareTaker (username, carerName, age) values ('gwilloughleyit', 'Gabi Willoughley', 50);
insert into CareTaker (username, carerName, age) values ('srosenthaleriu', 'Salem Rosenthaler', 42);
insert into CareTaker (username, carerName, age) values ('bfippeiv', 'Britney Fippe', 57);
insert into CareTaker (username, carerName, age) values ('cbaldoniiw', 'Cristabel Baldoni', 45);
insert into CareTaker (username, carerName, age) values ('amarjoribanksix', 'Abel Marjoribanks', 23);
insert into CareTaker (username, carerName, age) values ('mvellenderiy', 'Marillin Vellender', 60);
insert into CareTaker (username, carerName, age) values ('kramsieriz', 'Ketty Ramsier', 61);
insert into CareTaker (username, carerName, age) values ('btolsonj0', 'Betta Tolson', 58);
insert into CareTaker (username, carerName, age) values ('nmullarkeyj1', 'Nisse Mullarkey', 31);
insert into CareTaker (username, carerName, age) values ('dferej2', 'Darby Fere', 72);
insert into CareTaker (username, carerName, age) values ('snowickj3', 'Sharla Nowick', 50);
insert into CareTaker (username, carerName, age) values ('eforcadej4', 'Ewell Forcade', 68);
insert into CareTaker (username, carerName, age) values ('hmelinj5', 'Hiram Melin', 41);
insert into CareTaker (username, carerName, age) values ('gnisenj6', 'Gal Nisen', 15);
insert into CareTaker (username, carerName, age) values ('mchantillonj7', 'Michal Chantillon', 67);
insert into CareTaker (username, carerName, age) values ('bmewhirterj8', 'Barbra Mewhirter', 35);
insert into CareTaker (username, carerName, age) values ('sdandiej9', 'Sybyl Dandie', 17);
insert into CareTaker (username, carerName, age) values ('sblackallerja', 'Seka Blackaller', 68);
insert into CareTaker (username, carerName, age) values ('eoddejb', 'Enrica Odde', 25);
insert into CareTaker (username, carerName, age) values ('sgatheridgejc', 'Sloan Gatheridge', 66);
insert into CareTaker (username, carerName, age) values ('akrebsjd', 'Anderson Krebs', 72);
insert into CareTaker (username, carerName, age) values ('dspelsburyje', 'Dorie Spelsbury', 75);
insert into CareTaker (username, carerName, age) values ('aleetejf', 'Anstice Leete', 17);
insert into CareTaker (username, carerName, age) values ('hmccaughenjg', 'Hana McCaughen', 18);
insert into CareTaker (username, carerName, age) values ('ebuckneyjh', 'Elizabet Buckney', 66);
insert into CareTaker (username, carerName, age) values ('egookesji', 'Ed Gookes', 67);
insert into CareTaker (username, carerName, age) values ('wmiddlejj', 'Werner Middle', 73);
insert into CareTaker (username, carerName, age) values ('abiggsjk', 'Alan Biggs', 16);
insert into CareTaker (username, carerName, age) values ('ldejl', 'Langston de Pinna', 23);
insert into CareTaker (username, carerName, age) values ('mbaildonjm', 'Mignon Baildon', 59);
insert into CareTaker (username, carerName, age) values ('bsorensenjn', 'Bobbie Sorensen', 22);
insert into CareTaker (username, carerName, age) values ('tguilfoylejo', 'Tania Guilfoyle', 28);
insert into CareTaker (username, carerName, age) values ('mbiddulphjp', 'Maureen Biddulph', 34);
insert into CareTaker (username, carerName, age) values ('lridenjq', 'Levon Riden', 66);
insert into CareTaker (username, carerName, age) values ('bpietrasikjr', 'Benjamen Pietrasik', 24);
insert into CareTaker (username, carerName, age) values ('lshealsjs', 'Leigha Sheals', 56);
insert into CareTaker (username, carerName, age) values ('fmaasejt', 'Fernanda Maase', 75);
insert into CareTaker (username, carerName, age) values ('hmuddimanju', 'Husain Muddiman', 29);
insert into CareTaker (username, carerName, age) values ('tcapelingjv', 'Tallie Capeling', 24);
insert into CareTaker (username, carerName, age) values ('hpollandjw', 'Heath Polland', 75);
insert into CareTaker (username, carerName, age) values ('cmatteajx', 'Chris Mattea', 61);
insert into CareTaker (username, carerName, age) values ('tlyejy', 'Travis Lye', 28);
insert into CareTaker (username, carerName, age) values ('nmcgillicuddyjz', 'Nil McGillicuddy', 18);
insert into CareTaker (username, carerName, age) values ('gpearnk0', 'Gertrud Pearn', 54);
insert into CareTaker (username, carerName, age) values ('anewlank1', 'Anselma Newlan', 42);
insert into CareTaker (username, carerName, age) values ('nginityk2', 'Nancie Ginity', 34);
insert into CareTaker (username, carerName, age) values ('agarrisonk3', 'Alene Garrison', 15);
insert into CareTaker (username, carerName, age) values ('rdallk4', 'Ranna Dall', 50);
insert into CareTaker (username, carerName, age) values ('mdanielskyk5', 'Mattias Danielsky', 34);
insert into CareTaker (username, carerName, age) values ('achelsomk6', 'Anna-diana Chelsom', 70);
insert into CareTaker (username, carerName, age) values ('eorpynek7', 'Emmye Orpyne', 46);
insert into CareTaker (username, carerName, age) values ('bwoolwardk8', 'Bernhard Woolward', 21);
insert into CareTaker (username, carerName, age) values ('mhayhurstk9', 'Meredeth Hayhurst', 55);
insert into CareTaker (username, carerName, age) values ('gflickerka', 'Giovanni Flicker', 33);
insert into CareTaker (username, carerName, age) values ('cconnuekb', 'Chaunce Connue', 61);
insert into CareTaker (username, carerName, age) values ('raustwickkc', 'Rowland Austwick', 66);
insert into CareTaker (username, carerName, age) values ('bofogertykd', 'Bessy O''Fogerty', 54);
insert into CareTaker (username, carerName, age) values ('hkneaphseyke', 'Harlene Kneaphsey', 73);
insert into CareTaker (username, carerName, age) values ('dcoughlinkf', 'Diarmid Coughlin', 63);
insert into CareTaker (username, carerName, age) values ('mpitfordkg', 'Mikkel Pitford', 64);
insert into CareTaker (username, carerName, age) values ('dcagekh', 'Dorene Cage', 39);
insert into CareTaker (username, carerName, age) values ('rflayki', 'Roslyn Flay', 68);
insert into CareTaker (username, carerName, age) values ('cricartkj', 'Corinne Ricart', 35);
insert into CareTaker (username, carerName, age) values ('obastinkk', 'Otho Bastin', 37);
insert into CareTaker (username, carerName, age) values ('kchurmskl', 'Karen Churms', 74);
insert into CareTaker (username, carerName, age) values ('jjaquetkm', 'Jania Jaquet', 46);
insert into CareTaker (username, carerName, age) values ('kcockingkn', 'Kelley Cocking', 15);
insert into CareTaker (username, carerName, age) values ('rnewlandsko', 'Raynell Newlands', 62);
insert into CareTaker (username, carerName, age) values ('sastkp', 'Sarena Ast', 21);
insert into CareTaker (username, carerName, age) values ('apleadenkq', 'Arney Pleaden', 47);
insert into CareTaker (username, carerName, age) values ('jshurmankr', 'Jacquetta Shurman', 71);
insert into CareTaker (username, carerName, age) values ('amaddisonks', 'Amberly Maddison', 53);
insert into CareTaker (username, carerName, age) values ('cellinghamkt', 'Cristie Ellingham', 36);


-- -- Fulltimer --

insert into Fulltimer (username) values ('clampkin0');
insert into Fulltimer (username) values ('msquier1');
insert into Fulltimer (username) values ('gmonnelly2');
insert into Fulltimer (username) values ('hglasbey3');
insert into Fulltimer (username) values ('sbagge4');
insert into Fulltimer (username) values ('lcornelleau5');
insert into Fulltimer (username) values ('fnewitt6');
insert into Fulltimer (username) values ('estoggell7');
insert into Fulltimer (username) values ('tgwilliam8');
insert into Fulltimer (username) values ('gle9');
insert into Fulltimer (username) values ('slafonta');
insert into Fulltimer (username) values ('rbirraneb');
insert into Fulltimer (username) values ('escardifieldc');
insert into Fulltimer (username) values ('gcogleyd');
insert into Fulltimer (username) values ('pdumbaree');
insert into Fulltimer (username) values ('kvelldenf');
insert into Fulltimer (username) values ('jpinkg');
insert into Fulltimer (username) values ('jgallonh');
insert into Fulltimer (username) values ('sstokeyi');
insert into Fulltimer (username) values ('tdraiseyj');
insert into Fulltimer (username) values ('tshillabeark');
insert into Fulltimer (username) values ('gpriddisl');
insert into Fulltimer (username) values ('jmoodycliffem');
insert into Fulltimer (username) values ('sspirrittn');
insert into Fulltimer (username) values ('giwaszkiewiczo');
insert into Fulltimer (username) values ('lromainep');
insert into Fulltimer (username) values ('sferraoq');
insert into Fulltimer (username) values ('koleyr');
insert into Fulltimer (username) values ('sscowns');
insert into Fulltimer (username) values ('dklousnert');
insert into Fulltimer (username) values ('gsimminsu');
insert into Fulltimer (username) values ('jhawkeridgev');
insert into Fulltimer (username) values ('jstainfieldw');
insert into Fulltimer (username) values ('cchasemorex');
insert into Fulltimer (username) values ('lfinlany');
insert into Fulltimer (username) values ('mvankinz');
insert into Fulltimer (username) values ('mcockings10');
insert into Fulltimer (username) values ('wclemenza11');
insert into Fulltimer (username) values ('sdeakes12');
insert into Fulltimer (username) values ('fbischof13');
insert into Fulltimer (username) values ('hchalice14');
insert into Fulltimer (username) values ('cmeiklem15');
insert into Fulltimer (username) values ('cpeabody16');
insert into Fulltimer (username) values ('adalgarno17');
insert into Fulltimer (username) values ('wsesons18');
insert into Fulltimer (username) values ('ebon19');
insert into Fulltimer (username) values ('rfollows1a');
insert into Fulltimer (username) values ('gblasiak1b');
insert into Fulltimer (username) values ('sspink1c');
insert into Fulltimer (username) values ('nriggey1d');
insert into Fulltimer (username) values ('rgirke1e');
insert into Fulltimer (username) values ('zdelafoy1f');
insert into Fulltimer (username) values ('kleavens1g');
insert into Fulltimer (username) values ('tpetrie1h');
insert into Fulltimer (username) values ('dpascoe1i');
insert into Fulltimer (username) values ('cjimmison1j');
insert into Fulltimer (username) values ('mrubinov1k');
insert into Fulltimer (username) values ('akarmel1l');
insert into Fulltimer (username) values ('bcathie1m');
insert into Fulltimer (username) values ('bstoppard1n');
insert into Fulltimer (username) values ('ccheavin1o');
insert into Fulltimer (username) values ('qtiron1p');
insert into Fulltimer (username) values ('sgarioch1q');
insert into Fulltimer (username) values ('mconnors1r');
insert into Fulltimer (username) values ('fmacilhargy1s');
insert into Fulltimer (username) values ('hdellabbate1t');
insert into Fulltimer (username) values ('lsantino1u');
insert into Fulltimer (username) values ('kodd1v');
insert into Fulltimer (username) values ('mwehner1w');
insert into Fulltimer (username) values ('skitchingman1x');
insert into Fulltimer (username) values ('lharmour1y');
insert into Fulltimer (username) values ('rtarquinio1z');
insert into Fulltimer (username) values ('vloomes20');
insert into Fulltimer (username) values ('gvogel21');
insert into Fulltimer (username) values ('ddignon22');
insert into Fulltimer (username) values ('mwetheril23');
insert into Fulltimer (username) values ('chale24');
insert into Fulltimer (username) values ('dde25');
insert into Fulltimer (username) values ('ehillum26');
insert into Fulltimer (username) values ('jtrelevan27');
insert into Fulltimer (username) values ('kteodoro28');
insert into Fulltimer (username) values ('bsteventon29');
insert into Fulltimer (username) values ('asummerson2a');
insert into Fulltimer (username) values ('aellington2b');
insert into Fulltimer (username) values ('rpourveer2c');
insert into Fulltimer (username) values ('cdenington2d');
insert into Fulltimer (username) values ('pzamorrano2e');
insert into Fulltimer (username) values ('gbrownrigg2f');
insert into Fulltimer (username) values ('bbeardsley2g');
insert into Fulltimer (username) values ('gstorms2h');
insert into Fulltimer (username) values ('jandresser2i');
insert into Fulltimer (username) values ('zfowlston2j');
insert into Fulltimer (username) values ('cbaack2k');
insert into Fulltimer (username) values ('hphin2l');
insert into Fulltimer (username) values ('podowne2m');
insert into Fulltimer (username) values ('vpethick2n');
insert into Fulltimer (username) values ('kbouchier2o');
insert into Fulltimer (username) values ('hdorgan2p');
insert into Fulltimer (username) values ('kpetherick2q');
insert into Fulltimer (username) values ('smuir2r');
insert into Fulltimer (username) values ('lchristaeas2s');
insert into Fulltimer (username) values ('tjoire2t');
insert into Fulltimer (username) values ('lpichmann2u');
insert into Fulltimer (username) values ('ndozdill2v');
insert into Fulltimer (username) values ('aaudus2w');
insert into Fulltimer (username) values ('dtschierse2x');
insert into Fulltimer (username) values ('gmathon2y');
insert into Fulltimer (username) values ('pthomkins2z');
insert into Fulltimer (username) values ('mniezen30');
insert into Fulltimer (username) values ('shaydock31');
insert into Fulltimer (username) values ('cstickels32');
insert into Fulltimer (username) values ('cfilan33');
insert into Fulltimer (username) values ('bcovendon34');
insert into Fulltimer (username) values ('cjanousek35');
insert into Fulltimer (username) values ('nmowbray36');
insert into Fulltimer (username) values ('amilmo37');
insert into Fulltimer (username) values ('lgerkens38');
insert into Fulltimer (username) values ('aduplan39');
insert into Fulltimer (username) values ('zbroggio3a');
insert into Fulltimer (username) values ('bphilpault3b');
insert into Fulltimer (username) values ('rgerber3c');
insert into Fulltimer (username) values ('rsheaf3d');
insert into Fulltimer (username) values ('ikingwell3e');
insert into Fulltimer (username) values ('ltregea3f');
insert into Fulltimer (username) values ('mde3g');
insert into Fulltimer (username) values ('igorrissen3h');
insert into Fulltimer (username) values ('bivanin3i');
insert into Fulltimer (username) values ('ekaplan3j');
insert into Fulltimer (username) values ('lsapauton3k');
insert into Fulltimer (username) values ('tobern3l');
insert into Fulltimer (username) values ('tgreenhaugh3m');
insert into Fulltimer (username) values ('jalmond3n');
insert into Fulltimer (username) values ('yjakoviljevic3o');
insert into Fulltimer (username) values ('rwragg3p');
insert into Fulltimer (username) values ('achoake3q');
insert into Fulltimer (username) values ('smetcalf3r');
insert into Fulltimer (username) values ('rshapera3s');
insert into Fulltimer (username) values ('dgittings3t');
insert into Fulltimer (username) values ('jsteddall3u');
insert into Fulltimer (username) values ('lgiacaponi3v');
insert into Fulltimer (username) values ('ybruffell3w');
insert into Fulltimer (username) values ('edorman3x');
insert into Fulltimer (username) values ('msonier3y');
insert into Fulltimer (username) values ('fbleiman3z');
insert into Fulltimer (username) values ('mlanfere40');
insert into Fulltimer (username) values ('cgaucher41');
insert into Fulltimer (username) values ('tbrunner42');
insert into Fulltimer (username) values ('ahartridge43');
insert into Fulltimer (username) values ('sgowanson44');
insert into Fulltimer (username) values ('lmusgrove45');
insert into Fulltimer (username) values ('dmacturlough46');
insert into Fulltimer (username) values ('ccassella47');
insert into Fulltimer (username) values ('mfransemai48');
insert into Fulltimer (username) values ('vbirth49');
insert into Fulltimer (username) values ('osimmen4a');
insert into Fulltimer (username) values ('sruscoe4b');
insert into Fulltimer (username) values ('triddich4c');
insert into Fulltimer (username) values ('dle4d');
insert into Fulltimer (username) values ('fdainter4e');
insert into Fulltimer (username) values ('ssaphir4f');
insert into Fulltimer (username) values ('aaveyard4g');
insert into Fulltimer (username) values ('squainton4h');
insert into Fulltimer (username) values ('spresser4i');
insert into Fulltimer (username) values ('aabrahamian4j');
insert into Fulltimer (username) values ('mllewhellin4k');
insert into Fulltimer (username) values ('abiever4l');
insert into Fulltimer (username) values ('ndunkerley4m');
insert into Fulltimer (username) values ('dde4n');
insert into Fulltimer (username) values ('peckly4o');
insert into Fulltimer (username) values ('daxtens4p');
insert into Fulltimer (username) values ('rtrunkfield4q');
insert into Fulltimer (username) values ('mkuschel4r');
insert into Fulltimer (username) values ('ccamel4s');
insert into Fulltimer (username) values ('emacgarrity4t');
insert into Fulltimer (username) values ('lvashchenko4u');
insert into Fulltimer (username) values ('mde4v');
insert into Fulltimer (username) values ('kleary4w');
insert into Fulltimer (username) values ('ede4x');
insert into Fulltimer (username) values ('gblanche4y');
insert into Fulltimer (username) values ('lskrzynski4z');
insert into Fulltimer (username) values ('cturbern50');
insert into Fulltimer (username) values ('mtwentyman51');
insert into Fulltimer (username) values ('kschach52');
insert into Fulltimer (username) values ('cince53');
insert into Fulltimer (username) values ('omeeland54');
insert into Fulltimer (username) values ('echittock55');
insert into Fulltimer (username) values ('emenguy56');
insert into Fulltimer (username) values ('gbarks57');
insert into Fulltimer (username) values ('aalliband58');
insert into Fulltimer (username) values ('ebonnette59');
insert into Fulltimer (username) values ('apadell5a');
insert into Fulltimer (username) values ('eobbard5b');
insert into Fulltimer (username) values ('rbamford5c');
insert into Fulltimer (username) values ('hbranchet5d');
insert into Fulltimer (username) values ('cpenswick5e');
insert into Fulltimer (username) values ('sbiford5f');
insert into Fulltimer (username) values ('atout5g');
insert into Fulltimer (username) values ('mheskins5h');
insert into Fulltimer (username) values ('ksycamore5i');
insert into Fulltimer (username) values ('methridge5j');
insert into Fulltimer (username) values ('jde5k');
insert into Fulltimer (username) values ('do5l');
insert into Fulltimer (username) values ('smcgillivrie5m');
insert into Fulltimer (username) values ('lixor5n');
insert into Fulltimer (username) values ('jkimbury5o');
insert into Fulltimer (username) values ('npirrie5p');
insert into Fulltimer (username) values ('glainge5q');
insert into Fulltimer (username) values ('ugreenman5r');
insert into Fulltimer (username) values ('aabramowitch5s');
insert into Fulltimer (username) values ('ibretherick5t');
insert into Fulltimer (username) values ('ejeynes5u');
insert into Fulltimer (username) values ('odunge5v');
insert into Fulltimer (username) values ('dhaselhurst5w');
insert into Fulltimer (username) values ('aduxbarry5x');
insert into Fulltimer (username) values ('jcaltun5y');
insert into Fulltimer (username) values ('sgirardez5z');
insert into Fulltimer (username) values ('dlovitt60');
insert into Fulltimer (username) values ('mmarcq61');
insert into Fulltimer (username) values ('wmeininking62');
insert into Fulltimer (username) values ('iclines63');
insert into Fulltimer (username) values ('jblinde64');
insert into Fulltimer (username) values ('tsears65');
insert into Fulltimer (username) values ('ashakespeare66');
insert into Fulltimer (username) values ('cbeardsley67');
insert into Fulltimer (username) values ('gten68');
insert into Fulltimer (username) values ('rstrathe69');
insert into Fulltimer (username) values ('wcuckson6a');
insert into Fulltimer (username) values ('nsearle6b');
insert into Fulltimer (username) values ('epieche6c');
insert into Fulltimer (username) values ('crioch6d');
insert into Fulltimer (username) values ('bhasker6e');
insert into Fulltimer (username) values ('amelson6f');
insert into Fulltimer (username) values ('achazette6g');
insert into Fulltimer (username) values ('cdally6h');
insert into Fulltimer (username) values ('hmcartan6i');
insert into Fulltimer (username) values ('eberkley6j');
insert into Fulltimer (username) values ('dfurniss6k');
insert into Fulltimer (username) values ('kstaddart6l');
insert into Fulltimer (username) values ('rbowkett6m');
insert into Fulltimer (username) values ('jzecchinii6n');
insert into Fulltimer (username) values ('fmackett6o');
insert into Fulltimer (username) values ('aabry6p');
insert into Fulltimer (username) values ('bschulz6q');
insert into Fulltimer (username) values ('bhanaford6r');
insert into Fulltimer (username) values ('iaguirre6s');
insert into Fulltimer (username) values ('hmapledorum6t');
insert into Fulltimer (username) values ('jmarzele6u');
insert into Fulltimer (username) values ('mbarhem6v');
insert into Fulltimer (username) values ('batger6w');
insert into Fulltimer (username) values ('ostoffels6x');
insert into Fulltimer (username) values ('cgatus6y');
insert into Fulltimer (username) values ('hvasentsov6z');
insert into Fulltimer (username) values ('lgerner70');
insert into Fulltimer (username) values ('bfalks71');
insert into Fulltimer (username) values ('geplett72');
insert into Fulltimer (username) values ('mgontier73');
insert into Fulltimer (username) values ('breardon74');
insert into Fulltimer (username) values ('mbewlay75');
insert into Fulltimer (username) values ('bapperley76');
insert into Fulltimer (username) values ('mdurand77');
insert into Fulltimer (username) values ('scleaver78');
insert into Fulltimer (username) values ('rmaffi79');
insert into Fulltimer (username) values ('ehardcastle7a');
insert into Fulltimer (username) values ('tbridel7b');
insert into Fulltimer (username) values ('aarchard7c');
insert into Fulltimer (username) values ('mkerans7d');
insert into Fulltimer (username) values ('dtuxell7e');
insert into Fulltimer (username) values ('kmccoughan7f');
insert into Fulltimer (username) values ('rgarratty7g');
insert into Fulltimer (username) values ('pholbury7h');
insert into Fulltimer (username) values ('wfarnan7i');
insert into Fulltimer (username) values ('atrayton7j');
insert into Fulltimer (username) values ('sdrance7k');
insert into Fulltimer (username) values ('legginson7l');
insert into Fulltimer (username) values ('cgemnett7m');
insert into Fulltimer (username) values ('gshearsby7n');
insert into Fulltimer (username) values ('lbeiderbecke7o');
insert into Fulltimer (username) values ('mtwining7p');
insert into Fulltimer (username) values ('kcortes7q');
insert into Fulltimer (username) values ('klaurens7r');
insert into Fulltimer (username) values ('reburah7s');
insert into Fulltimer (username) values ('ltidy7t');
insert into Fulltimer (username) values ('blindman7u');
insert into Fulltimer (username) values ('rfearney7v');
insert into Fulltimer (username) values ('gpickerell7w');
insert into Fulltimer (username) values ('lcroxon7x');
insert into Fulltimer (username) values ('tedgeller7y');
insert into Fulltimer (username) values ('vpickavant7z');
insert into Fulltimer (username) values ('cswadlinge80');
insert into Fulltimer (username) values ('amoralee81');
insert into Fulltimer (username) values ('wbisiker82');
insert into Fulltimer (username) values ('dfernehough83');
insert into Fulltimer (username) values ('vdayce84');
insert into Fulltimer (username) values ('hgunthorpe85');
insert into Fulltimer (username) values ('kdillaway86');
insert into Fulltimer (username) values ('mfirebrace87');
insert into Fulltimer (username) values ('ngoly88');
insert into Fulltimer (username) values ('oclipston89');
insert into Fulltimer (username) values ('bfilipczak8a');
insert into Fulltimer (username) values ('dmcgriffin8b');
insert into Fulltimer (username) values ('pclutterham8c');
insert into Fulltimer (username) values ('blittlechild8d');
insert into Fulltimer (username) values ('othornham8e');
insert into Fulltimer (username) values ('elangelaan8f');
insert into Fulltimer (username) values ('mmerrigan8g');
insert into Fulltimer (username) values ('sheppner8h');
insert into Fulltimer (username) values ('rocahill8i');
insert into Fulltimer (username) values ('hsenussi8j');
insert into Fulltimer (username) values ('fjerrold8k');
insert into Fulltimer (username) values ('ybury8l');
insert into Fulltimer (username) values ('lsanders8m');
insert into Fulltimer (username) values ('ncano8n');
insert into Fulltimer (username) values ('obaversor8o');
insert into Fulltimer (username) values ('aredish8p');
insert into Fulltimer (username) values ('jverrall8q');
insert into Fulltimer (username) values ('iseaking8r');
insert into Fulltimer (username) values ('vspreag8s');
insert into Fulltimer (username) values ('jcavy8t');
insert into Fulltimer (username) values ('cvicar8u');
insert into Fulltimer (username) values ('ebakey8v');
insert into Fulltimer (username) values ('bpellamont8w');
insert into Fulltimer (username) values ('rpattullo8x');
insert into Fulltimer (username) values ('bbaynes8y');
insert into Fulltimer (username) values ('dkobiera8z');
insert into Fulltimer (username) values ('rfudge90');
insert into Fulltimer (username) values ('kthexton91');
insert into Fulltimer (username) values ('dbaffin92');
insert into Fulltimer (username) values ('gfolonin93');
insert into Fulltimer (username) values ('vdesborough94');
insert into Fulltimer (username) values ('vaspinwall95');
insert into Fulltimer (username) values ('dphillpotts96');
insert into Fulltimer (username) values ('bhurworth97');
insert into Fulltimer (username) values ('gdi98');
insert into Fulltimer (username) values ('aschankel99');
insert into Fulltimer (username) values ('tgyngyll9a');
insert into Fulltimer (username) values ('agiovannardi9b');
insert into Fulltimer (username) values ('fsimenel9c');
insert into Fulltimer (username) values ('cisoldi9d');
insert into Fulltimer (username) values ('cbeernt9e');
insert into Fulltimer (username) values ('sgrowden9f');
insert into Fulltimer (username) values ('rbovingdon9g');
insert into Fulltimer (username) values ('cgillard9h');
insert into Fulltimer (username) values ('hgrumley9i');
insert into Fulltimer (username) values ('pevill9j');
insert into Fulltimer (username) values ('lmcindrew9k');
insert into Fulltimer (username) values ('mcayette9l');
insert into Fulltimer (username) values ('tscoggans9m');
insert into Fulltimer (username) values ('aknevet9n');
insert into Fulltimer (username) values ('lsalzen9o');
insert into Fulltimer (username) values ('nkyffin9p');
insert into Fulltimer (username) values ('kbatterton9q');
insert into Fulltimer (username) values ('dbrauns9r');
insert into Fulltimer (username) values ('dreach9s');
insert into Fulltimer (username) values ('rosborne9t');
insert into Fulltimer (username) values ('fnelmes9u');
insert into Fulltimer (username) values ('jjarrell9v');
insert into Fulltimer (username) values ('bgerrell9w');
insert into Fulltimer (username) values ('wtodeo9x');
insert into Fulltimer (username) values ('csustin9y');
insert into Fulltimer (username) values ('amullinder9z');
insert into Fulltimer (username) values ('kmalecka0');
insert into Fulltimer (username) values ('ahallicka1');
insert into Fulltimer (username) values ('abennoea2');
insert into Fulltimer (username) values ('ptruggiana3');
insert into Fulltimer (username) values ('aschwanta4');
insert into Fulltimer (username) values ('kflighta5');
insert into Fulltimer (username) values ('dskowcrafta6');
insert into Fulltimer (username) values ('hjeskea7');
insert into Fulltimer (username) values ('tfidgea8');
insert into Fulltimer (username) values ('edaintera9');
insert into Fulltimer (username) values ('jannaa');
insert into Fulltimer (username) values ('mayreab');
insert into Fulltimer (username) values ('lketcherac');
insert into Fulltimer (username) values ('gcossonsad');
insert into Fulltimer (username) values ('gdanielae');


-- Parttimer --

insert into Parttimer (username) values ('cbarenskieaf');
insert into Parttimer (username) values ('lailmerag');
insert into Parttimer (username) values ('fwoodwingah');
insert into Parttimer (username) values ('bgillionai');
insert into Parttimer (username) values ('jwestcotaj');
insert into Parttimer (username) values ('rrosengartenak');
insert into Parttimer (username) values ('agerretsenal');
insert into Parttimer (username) values ('gbrunkeam');
insert into Parttimer (username) values ('wcouvesan');
insert into Parttimer (username) values ('pfattoriniao');
insert into Parttimer (username) values ('cbaptistaap');
insert into Parttimer (username) values ('gcracieaq');
insert into Parttimer (username) values ('ochadneyar');
insert into Parttimer (username) values ('mquinetas');
insert into Parttimer (username) values ('nweightat');
insert into Parttimer (username) values ('okeetleyau');
insert into Parttimer (username) values ('omcphilipav');
insert into Parttimer (username) values ('lbrafertonaw');
insert into Parttimer (username) values ('anylesax');
insert into Parttimer (username) values ('cpendreyay');
insert into Parttimer (username) values ('rmaryetaz');
insert into Parttimer (username) values ('draubenheimb0');
insert into Parttimer (username) values ('rcurrumb1');
insert into Parttimer (username) values ('ksimkissb2');
insert into Parttimer (username) values ('mfolinib3');
insert into Parttimer (username) values ('epavelkab4');
insert into Parttimer (username) values ('ejearumb5');
insert into Parttimer (username) values ('bsmailb6');
insert into Parttimer (username) values ('kibbersonb7');
insert into Parttimer (username) values ('zhubbardb8');
insert into Parttimer (username) values ('mfitzroyb9');
insert into Parttimer (username) values ('eschwanderba');
insert into Parttimer (username) values ('mgandleybb');
insert into Parttimer (username) values ('agarritbc');
insert into Parttimer (username) values ('hborgarsbd');
insert into Parttimer (username) values ('nganforthbe');
insert into Parttimer (username) values ('telsleybf');
insert into Parttimer (username) values ('rsheavillsbg');
insert into Parttimer (username) values ('clamckenbh');
insert into Parttimer (username) values ('trubinowbi');
insert into Parttimer (username) values ('bbatterhambj');
insert into Parttimer (username) values ('pnysbk');
insert into Parttimer (username) values ('mbolderobl');
insert into Parttimer (username) values ('vhartburnbm');
insert into Parttimer (username) values ('hdacresbn');
insert into Parttimer (username) values ('ecarssbo');
insert into Parttimer (username) values ('pmcgerraghtybp');
insert into Parttimer (username) values ('lpozzibq');
insert into Parttimer (username) values ('hzanucioliibr');
insert into Parttimer (username) values ('nmullissbs');
insert into Parttimer (username) values ('ewardallbt');
insert into Parttimer (username) values ('lbenkhebu');
insert into Parttimer (username) values ('ecrohanbv');
insert into Parttimer (username) values ('jmorrottbw');
insert into Parttimer (username) values ('ahollowbx');
insert into Parttimer (username) values ('omckeighanby');
insert into Parttimer (username) values ('fmackibbonbz');
insert into Parttimer (username) values ('jnuddsc0');
insert into Parttimer (username) values ('cbaisec1');
insert into Parttimer (username) values ('rmewburnc2');
insert into Parttimer (username) values ('sedworthiec3');
insert into Parttimer (username) values ('dlittlemorec4');
insert into Parttimer (username) values ('kfetherstonc5');
insert into Parttimer (username) values ('kfundellc6');
insert into Parttimer (username) values ('dhullc7');
insert into Parttimer (username) values ('mjannc8');
insert into Parttimer (username) values ('mtrudgionc9');
insert into Parttimer (username) values ('msawca');
insert into Parttimer (username) values ('brumsbycb');
insert into Parttimer (username) values ('wdaleycc');
insert into Parttimer (username) values ('asmewincd');
insert into Parttimer (username) values ('amcgebenayce');
insert into Parttimer (username) values ('nmcbeithcf');
insert into Parttimer (username) values ('jhustingscg');
insert into Parttimer (username) values ('gvinckch');
insert into Parttimer (username) values ('mscardefieldci');
insert into Parttimer (username) values ('btoynbeecj');
insert into Parttimer (username) values ('cpechack');
insert into Parttimer (username) values ('vkirbycl');
insert into Parttimer (username) values ('pclarkincm');
insert into Parttimer (username) values ('lkrysztofiakcn');
insert into Parttimer (username) values ('jobbardco');
insert into Parttimer (username) values ('atoothillcp');
insert into Parttimer (username) values ('sstobbescq');
insert into Parttimer (username) values ('vderbycr');
insert into Parttimer (username) values ('torrocs');
insert into Parttimer (username) values ('ekoenraadct');
insert into Parttimer (username) values ('anewartcu');
insert into Parttimer (username) values ('ledisoncv');
insert into Parttimer (username) values ('kprovercw');
insert into Parttimer (username) values ('hshemmingcx');
insert into Parttimer (username) values ('klecointecy');
insert into Parttimer (username) values ('mklemmtcz');
insert into Parttimer (username) values ('mrenderd0');
insert into Parttimer (username) values ('rhamblettd1');
insert into Parttimer (username) values ('rambrozd2');
insert into Parttimer (username) values ('rbutchardd3');
insert into Parttimer (username) values ('lissacsond4');
insert into Parttimer (username) values ('akeelind5');
insert into Parttimer (username) values ('astutted6');
insert into Parttimer (username) values ('whucknalld7');
insert into Parttimer (username) values ('aeried8');
insert into Parttimer (username) values ('ddoored9');
insert into Parttimer (username) values ('ahankinsonda');
insert into Parttimer (username) values ('wsmartmandb');
insert into Parttimer (username) values ('ljeedc');
insert into Parttimer (username) values ('dbenarddd');
insert into Parttimer (username) values ('ldonide');
insert into Parttimer (username) values ('lcradocdf');
insert into Parttimer (username) values ('gcraigmyledg');
insert into Parttimer (username) values ('fnowakowskadh');
insert into Parttimer (username) values ('mfinlowdi');
insert into Parttimer (username) values ('agepsondj');
insert into Parttimer (username) values ('gathelstandk');
insert into Parttimer (username) values ('hmccurtdl');
insert into Parttimer (username) values ('vmackrielldm');
insert into Parttimer (username) values ('rdignalldn');
insert into Parttimer (username) values ('qtatlockdo');
insert into Parttimer (username) values ('rcorterdp');
insert into Parttimer (username) values ('nshelpdq');
insert into Parttimer (username) values ('bdunforddr');
insert into Parttimer (username) values ('tatlingds');
insert into Parttimer (username) values ('mmartschkedt');
insert into Parttimer (username) values ('torringdu');
insert into Parttimer (username) values ('gfletcherdv');
insert into Parttimer (username) values ('dsuggeydw');
insert into Parttimer (username) values ('ctendx');
insert into Parttimer (username) values ('ghumbeedy');
insert into Parttimer (username) values ('jbeavendz');
insert into Parttimer (username) values ('lnewartee0');
insert into Parttimer (username) values ('leville1');
insert into Parttimer (username) values ('ewilkinsone2');
insert into Parttimer (username) values ('rsmurfitte3');
insert into Parttimer (username) values ('tbatone4');
insert into Parttimer (username) values ('sassitere5');
insert into Parttimer (username) values ('fangersteine6');
insert into Parttimer (username) values ('mfiste7');
insert into Parttimer (username) values ('cconnicke8');
insert into Parttimer (username) values ('fhazemane9');
insert into Parttimer (username) values ('whounsomea');
insert into Parttimer (username) values ('gkerneb');
insert into Parttimer (username) values ('lmehargec');
insert into Parttimer (username) values ('cwadduped');
insert into Parttimer (username) values ('cgoslinee');
insert into Parttimer (username) values ('ybwyeef');
insert into Parttimer (username) values ('lportingaleeg');
insert into Parttimer (username) values ('ystiegerseh');
insert into Parttimer (username) values ('binchcombei');
insert into Parttimer (username) values ('kwinsonej');
insert into Parttimer (username) values ('edurbynek');
insert into Parttimer (username) values ('edemicoliel');
insert into Parttimer (username) values ('tdenneyem');
insert into Parttimer (username) values ('dwoodhallen');
insert into Parttimer (username) values ('sboullineo');
insert into Parttimer (username) values ('rloverockep');
insert into Parttimer (username) values ('rdummereq');
insert into Parttimer (username) values ('smerrickser');
insert into Parttimer (username) values ('droutes');
insert into Parttimer (username) values ('jbauduccioet');
insert into Parttimer (username) values ('zlambleeu');
insert into Parttimer (username) values ('btaplowev');
insert into Parttimer (username) values ('akornalikew');
insert into Parttimer (username) values ('snorthleighex');
insert into Parttimer (username) values ('flamertoney');
insert into Parttimer (username) values ('nbouslerez');
insert into Parttimer (username) values ('keldertonf0');
insert into Parttimer (username) values ('tcattemullf1');
insert into Parttimer (username) values ('tfianderf2');
insert into Parttimer (username) values ('mallpressf3');
insert into Parttimer (username) values ('uvanf4');
insert into Parttimer (username) values ('ldef5');
insert into Parttimer (username) values ('swesonf6');
insert into Parttimer (username) values ('ridiensf7');
insert into Parttimer (username) values ('gscamerdenf8');
insert into Parttimer (username) values ('wrothertf9');
insert into Parttimer (username) values ('nviscofa');
insert into Parttimer (username) values ('pworsnupfb');
insert into Parttimer (username) values ('heagletonfc');
insert into Parttimer (username) values ('gmclainefd');
insert into Parttimer (username) values ('kalflatfe');
insert into Parttimer (username) values ('fayreeff');
insert into Parttimer (username) values ('cdewhirstfg');
insert into Parttimer (username) values ('gberefh');
insert into Parttimer (username) values ('mcornhillfi');
insert into Parttimer (username) values ('kfibbensfj');
insert into Parttimer (username) values ('lwhitemanfk');
insert into Parttimer (username) values ('rrichlyfl');
insert into Parttimer (username) values ('rbarbiefm');
insert into Parttimer (username) values ('mswatradgefn');
insert into Parttimer (username) values ('hstainerfo');
insert into Parttimer (username) values ('awillimotfp');
insert into Parttimer (username) values ('bheinofq');
insert into Parttimer (username) values ('lfalshawfr');
insert into Parttimer (username) values ('nblackbournfs');
insert into Parttimer (username) values ('atolcherft');
insert into Parttimer (username) values ('scompfortfu');
insert into Parttimer (username) values ('acastellifv');
insert into Parttimer (username) values ('lchristofefw');
insert into Parttimer (username) values ('hsandesonfx');
insert into Parttimer (username) values ('rpriestnerfy');
insert into Parttimer (username) values ('oboothebiefz');
insert into Parttimer (username) values ('lglentong0');
insert into Parttimer (username) values ('teratg1');
insert into Parttimer (username) values ('gpenhaleurackg2');
insert into Parttimer (username) values ('twreakg3');
insert into Parttimer (username) values ('srobinetteg4');
insert into Parttimer (username) values ('cgiraudelg5');
insert into Parttimer (username) values ('nfogartyg6');
insert into Parttimer (username) values ('dcharding7');
insert into Parttimer (username) values ('cfollandg8');
insert into Parttimer (username) values ('agynng9');
insert into Parttimer (username) values ('cbardega');
insert into Parttimer (username) values ('lfollingb');
insert into Parttimer (username) values ('bvongc');
insert into Parttimer (username) values ('klegendregd');
insert into Parttimer (username) values ('koakshottge');
insert into Parttimer (username) values ('kockendengf');
insert into Parttimer (username) values ('jisenorgg');
insert into Parttimer (username) values ('sloblegh');
insert into Parttimer (username) values ('kdaingi');
insert into Parttimer (username) values ('sslimongj');
insert into Parttimer (username) values ('hdayegk');
insert into Parttimer (username) values ('mlinkletergl');
insert into Parttimer (username) values ('dnorthamgm');
insert into Parttimer (username) values ('zwileygn');
insert into Parttimer (username) values ('ttrelevengo');
insert into Parttimer (username) values ('gcranmorgp');
insert into Parttimer (username) values ('denosgq');
insert into Parttimer (username) values ('lmerwedegr');
insert into Parttimer (username) values ('fdarleygs');
insert into Parttimer (username) values ('amaiorgt');
insert into Parttimer (username) values ('sclemendotgu');
insert into Parttimer (username) values ('gjouannissongv');
insert into Parttimer (username) values ('lheinemanngw');
insert into Parttimer (username) values ('mhaxbiegx');
insert into Parttimer (username) values ('bjakobssongy');
insert into Parttimer (username) values ('kgoodlipgz');
insert into Parttimer (username) values ('tsparroweh0');
insert into Parttimer (username) values ('cdevilh1');
insert into Parttimer (username) values ('mforsytheh2');
insert into Parttimer (username) values ('lgiacobinih3');
insert into Parttimer (username) values ('cvaulsh4');
insert into Parttimer (username) values ('jwesonh5');
insert into Parttimer (username) values ('ggrisedaleh6');
insert into Parttimer (username) values ('nhardageh7');
insert into Parttimer (username) values ('dwardinglyh8');
insert into Parttimer (username) values ('vwalasikh9');
insert into Parttimer (username) values ('hcheneha');
insert into Parttimer (username) values ('eaddamshb');
insert into Parttimer (username) values ('dwynnehc');
insert into Parttimer (username) values ('ssutterbyhd');
insert into Parttimer (username) values ('lblackfordhe');
insert into Parttimer (username) values ('lshropshirehf');
insert into Parttimer (username) values ('chebdenhg');
insert into Parttimer (username) values ('fsommervillehh');
insert into Parttimer (username) values ('gcasottihi');
insert into Parttimer (username) values ('haxonhj');
insert into Parttimer (username) values ('adetloffhk');
insert into Parttimer (username) values ('uboundehl');
insert into Parttimer (username) values ('rbergstrandhm');
insert into Parttimer (username) values ('pcristoferihn');
insert into Parttimer (username) values ('mlancastleho');
insert into Parttimer (username) values ('fduckershp');
insert into Parttimer (username) values ('ealmeyhq');
insert into Parttimer (username) values ('ajuetthr');
insert into Parttimer (username) values ('glangstonehs');
insert into Parttimer (username) values ('ncattleht');
insert into Parttimer (username) values ('nlaverenzhu');
insert into Parttimer (username) values ('kandreuttihv');
insert into Parttimer (username) values ('nmacfarlanhw');
insert into Parttimer (username) values ('kvalentellihx');
insert into Parttimer (username) values ('etamletthy');
insert into Parttimer (username) values ('slansdalehz');
insert into Parttimer (username) values ('syanelei0');
insert into Parttimer (username) values ('npenasi1');
insert into Parttimer (username) values ('ucarbonelli2');
insert into Parttimer (username) values ('gumplebyi3');
insert into Parttimer (username) values ('hhugonneti4');
insert into Parttimer (username) values ('bshanei5');
insert into Parttimer (username) values ('rgosticki6');
insert into Parttimer (username) values ('avani7');
insert into Parttimer (username) values ('fleidli8');
insert into Parttimer (username) values ('canderli9');
insert into Parttimer (username) values ('fgrzeszczakia');
insert into Parttimer (username) values ('sbormanib');
insert into Parttimer (username) values ('bwilshireic');
insert into Parttimer (username) values ('nkoppid');
insert into Parttimer (username) values ('gkachellerie');
insert into Parttimer (username) values ('mcollacombeif');
insert into Parttimer (username) values ('pkellandig');
insert into Parttimer (username) values ('trosternih');
insert into Parttimer (username) values ('ulavissii');
insert into Parttimer (username) values ('cmackessockij');
insert into Parttimer (username) values ('gtendahlik');
insert into Parttimer (username) values ('aabreyil');
insert into Parttimer (username) values ('bdeim');
insert into Parttimer (username) values ('jsealovein');
insert into Parttimer (username) values ('scarlsonio');
insert into Parttimer (username) values ('jvanip');
insert into Parttimer (username) values ('dtickleiq');
insert into Parttimer (username) values ('smacdearmontir');
insert into Parttimer (username) values ('bfrendis');
insert into Parttimer (username) values ('gwilloughleyit');
insert into Parttimer (username) values ('srosenthaleriu');
insert into Parttimer (username) values ('bfippeiv');
insert into Parttimer (username) values ('cbaldoniiw');
insert into Parttimer (username) values ('amarjoribanksix');
insert into Parttimer (username) values ('mvellenderiy');
insert into Parttimer (username) values ('kramsieriz');
insert into Parttimer (username) values ('btolsonj0');
insert into Parttimer (username) values ('nmullarkeyj1');
insert into Parttimer (username) values ('dferej2');
insert into Parttimer (username) values ('snowickj3');
insert into Parttimer (username) values ('eforcadej4');
insert into Parttimer (username) values ('hmelinj5');
insert into Parttimer (username) values ('gnisenj6');
insert into Parttimer (username) values ('mchantillonj7');
insert into Parttimer (username) values ('bmewhirterj8');
insert into Parttimer (username) values ('sdandiej9');
insert into Parttimer (username) values ('sblackallerja');
insert into Parttimer (username) values ('eoddejb');
insert into Parttimer (username) values ('sgatheridgejc');
insert into Parttimer (username) values ('akrebsjd');
insert into Parttimer (username) values ('dspelsburyje');
insert into Parttimer (username) values ('aleetejf');
insert into Parttimer (username) values ('hmccaughenjg');
insert into Parttimer (username) values ('ebuckneyjh');
insert into Parttimer (username) values ('egookesji');
insert into Parttimer (username) values ('wmiddlejj');
insert into Parttimer (username) values ('abiggsjk');
insert into Parttimer (username) values ('ldejl');
insert into Parttimer (username) values ('mbaildonjm');
insert into Parttimer (username) values ('bsorensenjn');
insert into Parttimer (username) values ('tguilfoylejo');
insert into Parttimer (username) values ('mbiddulphjp');
insert into Parttimer (username) values ('lridenjq');
insert into Parttimer (username) values ('bpietrasikjr');
insert into Parttimer (username) values ('lshealsjs');
insert into Parttimer (username) values ('fmaasejt');
insert into Parttimer (username) values ('hmuddimanju');
insert into Parttimer (username) values ('tcapelingjv');
insert into Parttimer (username) values ('hpollandjw');
insert into Parttimer (username) values ('cmatteajx');
insert into Parttimer (username) values ('tlyejy');
insert into Parttimer (username) values ('nmcgillicuddyjz');
insert into Parttimer (username) values ('gpearnk0');
insert into Parttimer (username) values ('anewlank1');
insert into Parttimer (username) values ('nginityk2');
insert into Parttimer (username) values ('agarrisonk3');
insert into Parttimer (username) values ('rdallk4');
insert into Parttimer (username) values ('mdanielskyk5');
insert into Parttimer (username) values ('achelsomk6');
insert into Parttimer (username) values ('eorpynek7');
insert into Parttimer (username) values ('bwoolwardk8');
insert into Parttimer (username) values ('mhayhurstk9');
insert into Parttimer (username) values ('gflickerka');
insert into Parttimer (username) values ('cconnuekb');
insert into Parttimer (username) values ('raustwickkc');
insert into Parttimer (username) values ('bofogertykd');
insert into Parttimer (username) values ('hkneaphseyke');
insert into Parttimer (username) values ('dcoughlinkf');
insert into Parttimer (username) values ('mpitfordkg');
insert into Parttimer (username) values ('dcagekh');
insert into Parttimer (username) values ('rflayki');
insert into Parttimer (username) values ('cricartkj');
insert into Parttimer (username) values ('obastinkk');
insert into Parttimer (username) values ('kchurmskl');
insert into Parttimer (username) values ('jjaquetkm');
insert into Parttimer (username) values ('kcockingkn');
insert into Parttimer (username) values ('rnewlandsko');
insert into Parttimer (username) values ('sastkp');
insert into Parttimer (username) values ('apleadenkq');
insert into Parttimer (username) values ('jshurmankr');
insert into Parttimer (username) values ('amaddisonks');
insert into Parttimer (username) values ('cellinghamkt');






-- Category --

insert into Category (pettype, base_price) values ('Pitbull', 100);
insert into Category (pettype, base_price) values ('Terrier', 80);
insert into Category (pettype, base_price) values ('Chihuahua', 60);
insert into Category (pettype, base_price) values ('Dalmatian', 120);
insert into Category (pettype, base_price) values ('Dachshund', 90);
insert into Category (pettype, base_price) values ('Aquarium Fish', 40);
insert into Category (pettype, base_price) values ('Pond Fish', 60);
insert into Category (pettype, base_price) values ('Small cats', 70);
insert into Category (pettype, base_price) values ('Large cats', 90);
insert into Category (pettype, base_price) values ('Horse', 250);
insert into Category (pettype, base_price) values ('Rabbit', 65);
insert into Category (pettype, base_price) values ('Caged Birds', 50);
insert into Category (pettype, base_price) values ('Free-range Birds', 75);
insert into Category (pettype, base_price) values ('Snake', 135);
insert into Category (pettype, base_price) values ('Tortoise', 45);
insert into Category (pettype, base_price) values ('Caged Insects', 60);
insert into Category (pettype, base_price) values ('Frogs', 65);
insert into Category (pettype, base_price) values ('Hamster', 50);
insert into Category (pettype, base_price) values ('Lizard', 55);
insert into Category (pettype, base_price) values ('Mice', 65);


-- Owned_Pet_belongs --
insert into Owned_Pet_Belongs (pouname, pettype, petname, petage) values ('gpundy8', 'Tortoise', 'Zsa zsa', 15);
insert into Owned_Pet_Belongs (pouname, pettype, petname, petage) values ('mgoom3', 'Free-range Birds', 'Ricard', 5);
insert into Owned_Pet_Belongs (pouname, pettype, petname, petage) values ('eburrass7', 'Terrier', 'Jere', 18);
insert into Owned_Pet_Belongs (pouname, pettype, petname, petage) values ('ljanicijevic5', 'Caged Birds', 'Stanton', 5);
insert into Owned_Pet_Belongs (pouname, pettype, petname, petage) values ('bmcilherran6', 'Rabbit', 'Allie', 16);
insert into Owned_Pet_Belongs (pouname, pettype, petname, petage) values ('joakhill9', 'Dalmatian', 'Cullie', 15);
insert into Owned_Pet_Belongs (pouname, pettype, petname, petage) values ('mgoom3', 'Aquarium Fish', 'Farr', 17);
insert into Owned_Pet_Belongs (pouname, pettype, petname, petage) values ('ygill4', 'Caged Birds', 'Marie-jeanne', 11);
insert into Owned_Pet_Belongs (pouname, pettype, petname, petage) values ('ygill4', 'Frogs', 'Tarra', 17);
insert into Owned_Pet_Belongs (pouname, pettype, petname, petage) values ('gpetrolli1', 'Mice', 'Ingrim', 15);
insert into Owned_Pet_Belongs (pouname, pettype, petname, petage) values ('joakhill9', 'Hamster', 'Leila', 20);
insert into Owned_Pet_Belongs (pouname, pettype, petname, petage) values ('ygill4', 'Frogs', 'Diann', 16);
insert into Owned_Pet_Belongs (pouname, pettype, petname, petage) values ('ygill4', 'Rabbit', 'Talbot', 19);
insert into Owned_Pet_Belongs (pouname, pettype, petname, petage) values ('ygill4', 'Rabbit', 'Dani', 5);
insert into Owned_Pet_Belongs (pouname, pettype, petname, petage) values ('ljanicijevic5', 'Caged Insects', 'Nichol', 4);
insert into Owned_Pet_Belongs (pouname, pettype, petname, petage) values ('joakhill9', 'Pond Fish', 'Carmine', 4);
insert into Owned_Pet_Belongs (pouname, pettype, petname, petage) values ('bmcilherran6', 'Large cats', 'Shellysheldon', 18);
insert into Owned_Pet_Belongs (pouname, pettype, petname, petage) values ('svorley2', 'Snake', 'Bernardina', 14);
insert into Owned_Pet_Belongs (pouname, pettype, petname, petage) values ('ygill4', 'Free-range Birds', 'Jen', 17);
insert into Owned_Pet_Belongs (pouname, pettype, petname, petage) values ('ljanicijevic5', 'Lizard', 'Bessy', 16);

-- Cares --
insert into Cares (ctuname, pettype, price) values ('msquier1', 'Horse', 75);
insert into Cares (ctuname, pettype, price) values ('fwoodwingah', 'Caged Insects', 48);
insert into Cares (ctuname, pettype, price) values ('bgillionai', 'Mice', 52);
insert into Cares (ctuname, pettype, price) values ('msquier1', 'Dalmatian', 83);
insert into Cares (ctuname, pettype, price) values ('sbagge4', 'Lizard', 77);
insert into Cares (ctuname, pettype, price) values ('lailmerag', 'Mice', 76);
insert into Cares (ctuname, pettype, price) values ('fwoodwingah', 'Hamster', 86);
insert into Cares (ctuname, pettype, price) values ('sbagge4', 'Large cats', 45);
insert into Cares (ctuname, pettype, price) values ('msquier1', 'Caged Birds', 82);
insert into Cares (ctuname, pettype, price) values ('cbarenskieaf', 'Tortoise', 76);
insert into Cares (ctuname, pettype, price) values ('hglasbey3', 'Caged Birds', 69);
insert into Cares (ctuname, pettype, price) values ('gmonnelly2', 'Pitbull', 50);
insert into Cares (ctuname, pettype, price) values ('cbarenskieaf', 'Dalmatian', 97);
insert into Cares (ctuname, pettype, price) values ('fwoodwingah', 'Tortoise', 49);
insert into Cares (ctuname, pettype, price) values ('hglasbey3', 'Lizard', 40);
insert into Cares (ctuname, pettype, price) values ('clampkin0', 'Caged Birds', 74);
insert into Cares (ctuname, pettype, price) values ('gmonnelly2', 'Hamster', 86);
insert into Cares (ctuname, pettype, price) values ('msquier1', 'Dachshund', 74);
insert into Cares (ctuname, pettype, price) values ('msquier1', 'Aquarium Fish', 90);
insert into Cares (ctuname, pettype, price) values ('lailmerag', 'Free-range Birds', 40);


-- Bid --
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, cost, is_win, rating, pay_type, pet_pickup, pay_status) values ('gpundy8', 'Zsa zsa', 'Tortoise', 'lailmerag', '2020-06-16', '2020-07-17', 194, 'true', 1, 'cash', 'transfer', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, cost, is_win, rating, pay_type, pet_pickup, pay_status) values ('gpundy8', 'Zsa zsa', 'Tortoise', 'cbarenskieaf', '2020-06-17', '2020-07-13', 102, 'true', 5, 'cash', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, cost, is_win, rating, pay_type, pet_pickup, pay_status) values ('gpundy8', 'Zsa zsa', 'Tortoise', 'lailmerag', '2020-06-08', '2020-07-13', 103, 'true', 2, 'credit card', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, cost, is_win, rating, pay_type, pet_pickup, pay_status) values ('gpundy8', 'Zsa zsa', 'Tortoise', 'fwoodwingah', '2020-06-28', '2020-07-25', 285, 'true', 3, 'credit card', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, cost, is_win, rating, pay_type, pet_pickup, pay_status) values ('gpundy8', 'Zsa zsa', 'Tortoise', 'clampkin0', '2020-06-14', '2020-07-14', 112, 'true', 4, 'credit card', 'ctPickup', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, cost, is_win, rating, pay_type, pet_pickup, pay_status) values ('gpundy8', 'Zsa zsa', 'Tortoise', 'fwoodwingah', '2020-06-07', '2020-07-03', 142, 'true', 1, 'credit card', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, cost, is_win, rating, pay_type, pet_pickup, pay_status) values ('gpundy8', 'Zsa zsa', 'Tortoise', 'jwestcotaj', '2020-06-11', '2020-07-19', 149, 'true', 4, 'credit card', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, cost, is_win, rating, pay_type, pet_pickup, pay_status) values ('gpundy8', 'Zsa zsa', 'Tortoise', 'fwoodwingah', '2020-06-07', '2020-07-26', 117, 'true', 0, 'credit card', 'ctPickup', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, cost, is_win, rating, pay_type, pet_pickup, pay_status) values ('gpundy8', 'Zsa zsa', 'Tortoise', 'bgillionai', '2020-06-01', '2020-07-30', 210, 'true', 2, 'cash', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, cost, is_win, rating, pay_type, pet_pickup, pay_status) values ('gpundy8', 'Zsa zsa', 'Tortoise', 'hglasbey3', '2020-06-29', '2020-07-21', 134, 'true', 5, 'cash', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, cost, is_win, rating, pay_type, pet_pickup, pay_status) values ('mgoom3', 'Ricard', 'Free-range Birds', 'hglasbey3', '2020-07-28', '2020-08-04', 297, 'true', 2, 'cash', 'ctPickup', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, cost, is_win, rating, pay_type, pet_pickup, pay_status) values ('mgoom3', 'Ricard', 'Free-range Birds', 'jwestcotaj', '2020-07-16', '2020-08-08', 108, 'true', 5, 'cash', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, cost, is_win, rating, pay_type, pet_pickup, pay_status) values ('mgoom3', 'Ricard', 'Free-range Birds', 'fwoodwingah', '2020-07-15', '2020-08-11', 74, 'true', 1, 'cash', 'ctPickup', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, cost, is_win, rating, pay_type, pet_pickup, pay_status) values ('mgoom3', 'Ricard', 'Free-range Birds', 'lailmerag', '2020-07-09', '2020-08-19', 94, 'true', 3, 'cash', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, cost, is_win, rating, pay_type, pet_pickup, pay_status) values ('mgoom3', 'Ricard', 'Free-range Birds', 'msquier1', '2020-07-18', '2020-08-26', 235, 'true', 1, 'cash', 'ctPickup', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, cost, is_win, rating, pay_type, pet_pickup, pay_status) values ('mgoom3', 'Ricard', 'Free-range Birds', 'fwoodwingah', '2020-07-24', '2020-08-02', 168, 'true', 5, 'cash', 'ctPickup', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, cost, is_win, rating, pay_type, pet_pickup, pay_status) values ('mgoom3', 'Ricard', 'Free-range Birds', 'jwestcotaj', '2020-07-21', '2020-08-29', 180, 'true', 5, 'cash', 'ctPickup', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, cost, is_win, rating, pay_type, pet_pickup, pay_status) values ('mgoom3', 'Ricard', 'Free-range Birds', 'jwestcotaj', '2020-07-20', '2020-08-28', 82, 'true', 5, 'cash', 'ctPickup', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, cost, is_win, rating, pay_type, pet_pickup, pay_status) values ('mgoom3', 'Ricard', 'Free-range Birds', 'cbarenskieaf', '2020-07-23', '2020-08-06', 138, 'true', 2, 'cash', 'transfer', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, cost, is_win, rating, pay_type, pet_pickup, pay_status) values ('mgoom3', 'Ricard', 'Free-range Birds', 'hglasbey3', '2020-07-28', '2020-08-20', 277, 'true', 3, 'credit card', 'poDeliver', 'true');
