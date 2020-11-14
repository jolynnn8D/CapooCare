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




CALL add_bid('johnthebest', 'Bloop', 'fish', 'ameliaCareServices', '2021-01-05', '2021-02-20', 'cash', 'poDeliver');
CALL add_bid('johnthebest', 'Hiss', 'snake', 'ameliaCareServices', '2021-01-05', '2021-02-20', 'cash', 'poDeliver');
--UPDATE Bid SET is_win = False WHERE ctuname = 'ameliaCareServices' AND pouname = 'johnthebest' AND petname = 'Hiss' AND pettype = 'snake' AND s_time = to_date('20210105','YYYYMMDD') AND e_time = to_date('20210220','YYYYMMDD');
CALL add_bid('marythemess', 'Ruff', 'big dog', 'supercaretaker', '2021-01-05', '2021-02-20', 'cash', 'poDeliver');
CALL add_bid('marythemess', 'Champ', 'big dog', 'supercaretaker', '2021-01-05', '2021-01-20', 'cash', 'poDeliver');
UPDATE Bid SET is_win = True WHERE ctuname = 'supercaretaker' AND pouname = 'marythemess' AND petname = 'Ruff' AND pettype = 'big dog' AND s_time = to_date('20210105','YYYYMMDD') AND e_time = to_date('20210220','YYYYMMDD');
UPDATE Bid SET is_win = True WHERE ctuname = 'supercaretaker' AND pouname = 'marythemess' AND petname = 'Champ' AND pettype = 'big dog' AND s_time = to_date('20210105','YYYYMMDD') AND e_time = to_date('20210120','YYYYMMDD');

-- The following test case overloads 'marythemess' with more bids than she can accept
CALL add_bid('marythemess', 'Meow', 'cat', 'mary_caretaker', '2021-01-01', '2021-02-28', NULL, NULL);
CALL add_bid('marythemess', 'Bark', 'big dog', 'mary_caretaker', '2021-01-01', '2021-02-28', NULL, NULL);
--CALL add_bid('marythemess', 'Champ', 'big dog', 'bob_lovesdogs', '2021-02-01', '2021-02-23', 'cash', 'poDeliver');
CALL add_bid('marythemess', 'Purr', 'cat', 'bob_lovesdogs', '2021-02-03', '2021-02-22', 'cash', 'ctPickup');
CALL add_bid('marythemess', 'Champ', 'big dog', 'mary_caretaker', '2021-02-24', '2021-02-28', 'cash', 'poDeliver');
CALL add_bid('marythemess', 'Ruff', 'big dog', 'mary_caretaker', '2021-02-25', '2021-02-28', 'cash', 'ctPickup');
CALL add_bid('marythemess', 'Purr', 'cat', 'mary_caretaker', '2021-02-26', '2021-02-28', 'cash', 'poDeliver');
CALL add_bid('marythemess', 'Sneak', 'cat', 'mary_caretaker', '2021-02-27', '2021-02-28', 'cash', 'poDeliver');
CALL add_bid('marythemess', 'Sneak', 'cat', 'supercaretaker', '2020-08-08', '2020-08-09', 'cash', 'poDeliver');

-- The following test case sets up a completed Bid
-- CALL add_bid('marythemess', 'Champ', 'big dog', 'mary_caretaker', '2020-02-05', '2020-02-20', 'credit card', 'ctPickup');
-- UPDATE Bid SET is_win = true WHERE ctuname = 'mary_caretaker' AND pouname = 'marythemess' AND petname = 'Champ'
--    AND pettype = 'big dog' AND s_time = to_date('20200205','YYYYMMDD') AND e_time = to_date('20200220','YYYYMMDD');
-- UPDATE Bid SET pay_type = 'cash', pet_pickup = 'poDeliver', rating = '3', review = 'sample review', pay_status = true
--    WHERE ctuname = 'mary_caretaker' AND pouname = 'marythemess' AND petname = 'Champ' AND pettype = 'big dog'
--    AND s_time = to_date('20200205','YYYYMMDD') AND e_time = to_date('20200220','YYYYMMDD') AND is_win = true;

 /* Expected outcome: 'marythemess' wins both bids at timestamp 1-4 and 2-4. This causes 'johnthebest' to lose the 2-4		
     bid. The 1-4 bid by 'johnthebest' that is inserted afterwards immediately loses as well, since 'supercaretaker' has		
     reached their maximum capacity already.*/		
--  INSERT INTO Bid VALUES ('marythemess', 'Fido', 'dog', 'supercaretaker', to_timestamp('1000000'), to_timestamp('4000000'));		
--  INSERT INTO Bid VALUES ('marythemess', 'Champ', 'big dog', 'supercaretaker', to_timestamp('2000000'), to_timestamp('4000000'));		
--  INSERT INTO Bid VALUES ('johnthebest', 'Fido', 'dog', 'supercaretaker', to_timestamp('2000000'), to_timestamp('4000000'));		
--  INSERT INTO Bid VALUES ('marythemess', 'Meow', 'cat', 'supercaretaker', to_timestamp('3000000'), to_timestamp('4000000'));

--  UPDATE Bid SET is_win = True WHERE ctuname = 'supercaretaker' AND pouname = 'marythemess' AND petname = 'Fido' AND pettype = 'dog' AND s_time = to_timestamp('1000000') AND e_time = to_timestamp('4000000');		
--  UPDATE Bid SET is_win = True WHERE ctuname = 'supercaretaker' AND pouname = 'marythemess' AND petname = 'Champ' AND pettype = 'big dog' AND s_time = to_timestamp('2000000') AND e_time = to_timestamp('4000000');

--  INSERT INTO Bid VALUES ('johnthebest', 'Fido', 'dog', 'supercaretaker', to_timestamp('1000000'), to_timestamp('4000000'));

--------------- TEST all_ct query, testing with 'marythemess' at time period 2020-06-01 to 2020-06-06 ---------------------

-- These are to set the ratings for following cts
-- mary_caretaker
CALL add_bid('marythemess', 'Champ', 'big dog', 'mary_caretaker', '2020-02-24', '2020-02-28', 'cash', 'poDeliver');
UPDATE Bid SET is_win = true WHERE ctuname = 'mary_caretaker' AND pouname = 'marythemess' AND petname = 'Champ'
   AND pettype = 'big dog' AND s_time = to_date('20200224','YYYYMMDD') AND e_time = to_date('20200228','YYYYMMDD');
UPDATE Bid SET pay_type = 'cash', pet_pickup = 'poDeliver', rating = '5', review = 'Great services, recommended.', pay_status = true
   WHERE ctuname = 'mary_caretaker' AND pouname = 'marythemess' AND petname = 'Champ' AND pettype = 'big dog'
   AND s_time = to_date('20200224','YYYYMMDD') AND e_time = to_date('20200228','YYYYMMDD') AND is_win = true;
-- supercaretaker
INSERT INTO Has_Availability VALUES ('supercaretaker', '2020-01-05', '2020-01-20');
CALL add_bid('marythemess', 'Champ', 'big dog', 'supercaretaker', '2020-01-05', '2020-01-10', 'cash', 'poDeliver');
UPDATE Bid SET is_win = true WHERE ctuname = 'supercaretaker' AND pouname = 'marythemess' AND petname = 'Champ'
   AND pettype = 'big dog' AND s_time = to_date('20200105','YYYYMMDD') AND e_time = to_date('20200110','YYYYMMDD');
UPDATE Bid SET pay_type = 'cash', pet_pickup = 'poDeliver', rating = '5', review = 'sample review', pay_status = true
    WHERE ctuname = 'supercaretaker' AND pouname = 'marythemess' AND petname = 'Champ' AND pettype = 'big dog' 
    AND s_time = to_date('20200105','YYYYMMDD') AND e_time = to_date('20200110','YYYYMMDD');
-- Bobddog
CALL add_bid('marythemess', 'Purr', 'cat', 'bob_lovesdogs', '2020-02-03', '2020-02-22', 'cash', 'poDeliver');
UPDATE Bid SET is_win = true WHERE ctuname = 'bob_lovesdogs' AND pouname = 'marythemess' AND petname = 'Purr'
   AND pettype = 'cat' AND s_time = to_date('20200203','YYYYMMDD') AND e_time = to_date('20200222','YYYYMMDD');
UPDATE Bid SET pay_type = 'cash', pet_pickup = 'poDeliver', rating = '3', review = 'sample review', pay_status = true
   WHERE ctuname = 'bob_lovesdogs' AND pouname = 'marythemess' AND petname = 'Purr' AND pettype = 'cat'
   AND s_time = to_date('20200203','YYYYMMDD') AND e_time = to_date('20200222','YYYYMMDD') AND is_win = true;


-- INSERT INTO Has_Availability VALUES ('supercaretaker', '2020-06-01', '2020-06-06');
-- INSERT INTO Has_Availability VALUES ('mary_caretaker', '2020-06-01', '2020-06-06');
-- INSERT INTO Has_Availability VALUES ('bob_lovesdogs', '2020-06-01', '2020-06-06');

-- saturation of PT capacity --
CALL add_bid('marythemess', 'Champ', 'big dog', 'supercaretaker', '2020-06-01', '2020-06-06', 'cash', 'poDeliver');
UPDATE Bid SET is_win = true WHERE ctuname = 'supercaretaker' AND pouname = 'marythemess' AND petname = 'Champ'
   AND pettype = 'big dog' AND s_time = to_date('20200601','YYYYMMDD') AND e_time = to_date('20200606','YYYYMMDD');
CALL add_bid('marythemess', 'Meow', 'cat', 'supercaretaker', '2020-06-01', '2020-06-06', 'cash', 'poDeliver');
UPDATE Bid SET is_win = true WHERE ctuname = 'supercaretaker' AND pouname = 'marythemess' AND petname = 'Meow'
   AND pettype = 'cat' AND s_time = to_date('20200601','YYYYMMDD') AND e_time = to_date('20200606','YYYYMMDD');


CALL add_bid('petownerdavid', 'Meow', 'cat', 'caretaker_amy', '2020-01-01', '2020-01-30','cash', 'poDeliver');
CALL add_bid('petownerdavid', 'Meow', 'cat', 'caretaker_amy', '2020-03-02', '2020-03-25','cash', 'poDeliver');
CALL add_bid('petownerdavid', 'Brownie', 'big dog', 'caretaker_amy', '2020-03-02', '2020-03-25','cash', 'poDeliver');
CALL add_bid('petownerdavid', 'Snowy', 'cat', 'johnhammington', '2021-03-02', '2021-03-25','cash', 'poDeliver');


CALL add_bid('petownerdavid', 'Snowy', 'cat', 'new_caretaker', '2020-01-17', '2020-01-19', 'cash', 'poDeliver');
CALL add_bid('marythemess', 'Champ', 'big dog', 'new_caretaker', '2020-04-17', '2020-04-19', 'cash', 'poDeliver');
CALL add_bid('johnthebest', 'Fido', 'dog', 'new_caretaker', '2020-05-01', '2020-05-03', 'credit card', 'poDeliver');
CALL add_bid('johnthebest', 'Fido', 'dog', 'new_caretaker', '2020-05-06', '2020-05-07', 'cash', 'poDeliver');
CALL add_bid('marythemess', 'Champ', 'big dog', 'new_caretaker', '2020-07-09', '2020-07-10', 'cash', 'poDeliver');
CALL add_bid('petownerdavid', 'Snowy', 'cat', 'new_caretaker', '2020-09-01', '2020-09-02', 'cash', 'poDeliver');
CALL add_bid('petownerdavid', 'Woof', 'dog', 'new_caretaker', '2020-02-01', '2020-02-03', 'cash', 'poDeliver');
CALL add_bid('petownerdavid', 'Woof', 'dog', 'new_caretaker', '2020-11-01', '2020-11-03', 'cash', 'poDeliver');
CALL add_bid('petownerdavid', 'Brownie', 'big dog', 'new_caretaker', '2020-08-02', '2020-08-25','cash', 'ctPickup');

