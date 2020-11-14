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
                    INSERT INTO CareTaker VALUES (ctuname, aname, age);
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
    price INTEGER
    )  AS $$
    DECLARE ctx NUMERIC;
    BEGIN
        SELECT COUNT(*) INTO ctx FROM PartTimer
                WHERE PartTimer.username = ctuname;
        IF ctx = 0 THEN
            INSERT INTO CareTaker VALUES (ctuname, aname, age);
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

---------------------------------------------------------- Category ------------------------------------------------------------

CREATE OR REPLACE FUNCTION check_update_base_price()
RETURNS TRIGGER AS
$$ BEGIN
        --if base price of category changes, update FT cares' prices as well
        IF (NEW.base_price <> OLD.base_price) THEN
            UPDATE Cares SET price = New.base_price WHERE (Cares.ctuname IN (SELECT username FROM FullTimer)) AND Cares.pettype = NEW.pettype;
        END IF;
        RETURN NEW;
    END; $$
LANGUAGE plpgsql;

CREATE TRIGGER check_update_base_price
BEFORE UPDATE ON Category
FOR EACH ROW EXECUTE PROCEDURE check_update_base_price();

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

