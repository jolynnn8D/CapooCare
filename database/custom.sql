DROP TABLE IF EXISTS Bid CASCADE;

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

CREATE OR REPLACE PROCEDURE add_bid_TEMP (
    _pouname VARCHAR(50),
    _petname VARCHAR(20),
    _pettype VARCHAR(20),
    _ctuname VARCHAR(50),
    _s_time DATE,
    _e_time DATE,
    _is_win BOOLEAN,
    _rating INTEGER,
    _pay_type VARCHAR(20),
    _pet_pickup VARCHAR(20),
    _pay_status BOOLEAN
    ) AS
        $$
        DECLARE cost NUMERIC;
        BEGIN
            -- Calculate cost
            SELECT (Cares.price * (_e_time - _s_time + 1)) INTO cost
                FROM Cares
                WHERE Cares.ctuname = _ctuname AND Cares.pettype = _pettype;
            INSERT INTO Bid(pouname, petname, pettype, ctuname, s_time, e_time, cost, is_win, rating, pay_type, pet_pickup, pay_status) 
               VALUES (_pouname, _petname, _pettype, _ctuname, _s_time, _e_time, cost, _is_win, _rating, _pay_type, _pet_pickup, _pay_status);
        END;
        $$
    LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE add_bid_TEMP_w_review (
    _pouname VARCHAR(50),
    _petname VARCHAR(20),
    _pettype VARCHAR(20),
    _ctuname VARCHAR(50),
    _s_time DATE,
    _e_time DATE,
    _is_win BOOLEAN,
    _rating INTEGER,
    _review VARCHAR(200),
    _pay_type VARCHAR(20),
    _pet_pickup VARCHAR(20),
    _pay_status BOOLEAN
    ) AS
        $$
        DECLARE cost NUMERIC;
        BEGIN
            -- Calculate cost
            SELECT (Cares.price * (_e_time - _s_time + 1)) INTO cost
                FROM Cares
                WHERE Cares.ctuname = _ctuname AND Cares.pettype = _pettype;
            INSERT INTO Bid(pouname, petname, pettype, ctuname, s_time, e_time, cost, is_win, rating, review, pay_type, pet_pickup, pay_status)
               VALUES (_pouname, _petname, _pettype, _ctuname, _s_time, _e_time, cost, _is_win, _rating, _review, _pay_type, _pet_pickup, _pay_status);
        END;
        $$
    LANGUAGE plpgsql;


-- Successful Bids for parttimer: Dustion
CALL add_bid_TEMP_w_review('nightDreamers','Kermit', 'Aquarium Fish', 'Dustion','2020-04-05' , '2020-04-07', 'true', 3, 'Good service', 'cash', 'poDeliver', 'true');
CALL add_bid_TEMP_w_review('zxcher','lil green', 'Snake', 'Dustion','2020-08-02' , '2020-08-06', 'true', 3, 'Caretaker was very nice. Took good care of my snake.', 'credit card', 'poDeliver', 'true');
CALL add_bid_TEMP('zxcher','Ed', 'Hamster', 'Dustion','2020-08-05' , '2020-08-10', 'true', 3, 'cash', 'ctPickup', 'true');


-- Successful Bids for fulltimer: purpleAbi, AVAIL: '2020-03-01', '2020-07-30' AND '2020-08-01', '2020-12-30'
CALL add_bid_TEMP_w_review('nightDreamers','Peach', 'Pitbull', 'purpleAbi','2020-05-16' , '2020-05-20', 'true', 2, 'Did take my dog out on walks regularly', 'credit card', 'ctPickup', 'true');
CALL add_bid_TEMP_w_review('battyBat','tweet', 'Free-range Birds', 'purpleAbi','2020-07-01' , '2020-07-02', 'true', 3, 'Did not feed my bird with appropriate seeds. Bad service.', 'cash', 'poDeliver', 'true');



-- Successful Bids for fulltimer: littleJohn, AVAIL: '2020-02-01', '2020-06-30' AND '2020-07-01', '2020-11-30'
CALL add_bid_TEMP_w_review('zxcher','lil green', 'Snake', 'littleJohn','2020-03-01', '2020-03-15', 'true', 5, 'Great services! Very impressed with his thoughtfulness', 'credit card', 'poDeliver', 'true');
CALL add_bid_TEMP_w_review('nightDreamers','Marbles', 'Chihuahua', 'littleJohn','2020-04-20' , '2020-04-25', 'true', 5, 'Very accommodating caretaker!','credit card', 'ctPickup', 'true');
CALL add_bid_TEMP('battyBat','Andrea', 'Caged Insects', 'littleJohn','2020-08-01' , '2020-08-10', 'true', 5, 'credit card', 'poDeliver', 'true');

-- making > 60 pet days for cartaker littleJohn on month Septemeber
CALL add_bid_TEMP('nightDreamers','Peach', 'Pitbull', 'littleJohn','2020-09-01' , '2020-09-02', 'true', 3, 'credit card', 'ctPickup', 'true');
CALL add_bid_TEMP('battyBat','tweet', 'Free-range Birds', 'littleJohn','2020-09-01' , '2020-09-02', 'true', 3, 'cash', 'poDeliver', 'true');
CALL add_bid_TEMP('zxcher','Cookies', 'Rabbit', 'littleJohn','2020-09-01' , '2020-09-02', 'true', 4, 'cash', 'poDeliver', 'true');
CALL add_bid_TEMP('zxcher','lil green', 'Snake', 'littleJohn','2020-09-01', '2020-09-02', 'true', 5, 'credit card', 'poDeliver', 'true');
--4
CALL add_bid_TEMP('nightDreamers','Marbles', 'Chihuahua', 'littleJohn','2020-09-03' , '2020-09-04', 'true', 5, 'credit card', 'ctPickup', 'true');
CALL add_bid_TEMP('battyBat','Andrea', 'Caged Insects', 'littleJohn','2020-09-03' , '2020-09-04', 'true', 5, 'credit card', 'poDeliver', 'true');
CALL add_bid_TEMP('nightDreamers','Kermit', 'Aquarium Fish', 'littleJohn','2020-09-03' , '2020-09-04', 'true', 3, 'cash', 'poDeliver', 'true');
CALL add_bid_TEMP('zxcher','lil green', 'Snake', 'littleJohn','2020-09-03' , '2020-09-04', 'true', 3, 'credit card', 'poDeliver', 'true');
CALL add_bid_TEMP('zxcher','Ed', 'Hamster', 'littleJohn','2020-09-03' , '2020-09-04', 'true', 3, 'cash', 'ctPickup', 'true');
--9
CALL add_bid_TEMP('nightDreamers','Peach', 'Pitbull', 'littleJohn','2020-09-03' , '2020-09-04', 'true', 3, 'credit card', 'ctPickup', 'true');
CALL add_bid_TEMP('battyBat','tweet', 'Free-range Birds', 'littleJohn','2020-09-03' , '2020-09-04', 'true', 3, 'cash', 'poDeliver', 'true');
CALL add_bid_TEMP('zxcher','Cookies', 'Rabbit', 'littleJohn','2020-09-03' , '2020-09-04', 'true', 4, 'cash', 'poDeliver', 'true');
--12
CALL add_bid_TEMP('nightDreamers','Marbles', 'Chihuahua', 'littleJohn','2020-09-05' , '2020-09-06', 'true', 5, 'credit card', 'ctPickup', 'true');
CALL add_bid_TEMP('battyBat','Andrea', 'Caged Insects', 'littleJohn','2020-09-05' , '2020-09-06', 'true', 5, 'credit card', 'poDeliver', 'true');
CALL add_bid_TEMP('nightDreamers','Kermit', 'Aquarium Fish', 'littleJohn','2020-09-05' , '2020-09-06', 'true', 3, 'cash', 'poDeliver', 'true');
CALL add_bid_TEMP('zxcher','lil green', 'Snake', 'littleJohn','2020-09-05' , '2020-09-06', 'true', 3, 'credit card', 'poDeliver', 'true');
CALL add_bid_TEMP('zxcher','Ed', 'Hamster', 'littleJohn','2020-09-05' , '2020-09-06', 'true', 3, 'cash', 'ctPickup', 'true');
--17
CALL add_bid_TEMP('nightDreamers','Peach', 'Pitbull', 'littleJohn','2020-09-05' , '2020-09-06', 'true', 3, 'credit card', 'ctPickup', 'true');
CALL add_bid_TEMP('battyBat','tweet', 'Free-range Birds', 'littleJohn','2020-09-05' , '2020-09-06', 'true', 3, 'cash', 'poDeliver', 'true');
CALL add_bid_TEMP('zxcher','Cookies', 'Rabbit', 'littleJohn','2020-09-05' , '2020-09-06', 'true', 4, 'cash', 'poDeliver', 'true');
--20
CALL add_bid_TEMP('nightDreamers','Marbles', 'Chihuahua', 'littleJohn','2020-09-07' , '2020-09-08', 'true', 5, 'credit card', 'ctPickup', 'true');
CALL add_bid_TEMP('battyBat','Andrea', 'Caged Insects', 'littleJohn','2020-09-07' , '2020-09-08', 'true', 5, 'credit card', 'poDeliver', 'true');
CALL add_bid_TEMP('nightDreamers','Kermit', 'Aquarium Fish', 'littleJohn','2020-09-07' , '2020-09-08', 'true', 3, 'cash', 'poDeliver', 'true');
CALL add_bid_TEMP('zxcher','lil green', 'Snake', 'littleJohn','2020-09-07' , '2020-09-08', 'true', 3, 'credit card', 'poDeliver', 'true');
CALL add_bid_TEMP('zxcher','Ed', 'Hamster', 'littleJohn','2020-09-07' , '2020-09-08', 'true', 3, 'cash', 'ctPickup', 'true');
--25
CALL add_bid_TEMP('nightDreamers','Peach', 'Pitbull', 'littleJohn','2020-09-07' , '2020-09-08', 'true', 3, 'credit card', 'ctPickup', 'true');
CALL add_bid_TEMP('battyBat','tweet', 'Free-range Birds', 'littleJohn','2020-09-07' , '2020-09-08', 'true', 3, 'cash', 'poDeliver', 'true');
CALL add_bid_TEMP('zxcher','Cookies', 'Rabbit', 'littleJohn','2020-09-07' , '2020-09-08', 'true', 4, 'cash', 'poDeliver', 'true');
--28
CALL add_bid_TEMP('nightDreamers','Marbles', 'Chihuahua', 'littleJohn','2020-09-09' , '2020-09-10', 'true', 5, 'credit card', 'ctPickup', 'true');
CALL add_bid_TEMP('battyBat','Andrea', 'Caged Insects', 'littleJohn','2020-09-09' , '2020-09-10', 'true', 5, 'credit card', 'poDeliver', 'true');
CALL add_bid_TEMP('nightDreamers','Kermit', 'Aquarium Fish', 'littleJohn','2020-09-09' , '2020-09-10', 'true', 3, 'cash', 'poDeliver', 'true');
CALL add_bid_TEMP('zxcher','lil green', 'Snake', 'littleJohn','2020-09-09' , '2020-09-10', 'true', 3, 'credit card', 'poDeliver', 'true');
CALL add_bid_TEMP('zxcher','Ed', 'Hamster', 'littleJohn','2020-09-09' , '2020-09-10', 'true', 3, 'cash', 'ctPickup', 'true');
--33
CALL add_bid_TEMP('nightDreamers','Peach', 'Pitbull', 'littleJohn','2020-09-09' , '2020-09-10', 'true', 3, 'credit card', 'ctPickup', 'true');
CALL add_bid_TEMP('battyBat','tweet', 'Free-range Birds', 'littleJohn','2020-09-09' , '2020-09-10', 'true', 3, 'cash', 'poDeliver', 'true');
CALL add_bid_TEMP('zxcher','Cookies', 'Rabbit', 'littleJohn','2020-09-09' , '2020-09-10', 'true', 4, 'cash', 'poDeliver', 'true');
--36
CALL add_bid_TEMP('nightDreamers','Marbles', 'Chihuahua', 'littleJohn','2020-09-11' , '2020-09-12', 'true', 5, 'credit card', 'ctPickup', 'true');
CALL add_bid_TEMP('battyBat','Andrea', 'Caged Insects', 'littleJohn','2020-09-11' , '2020-09-12', 'true', 5, 'credit card', 'poDeliver', 'true');
CALL add_bid_TEMP('nightDreamers','Kermit', 'Aquarium Fish', 'littleJohn','2020-09-11' , '2020-09-12', 'true', 3, 'cash', 'poDeliver', 'true');
CALL add_bid_TEMP('zxcher','lil green', 'Snake', 'littleJohn','2020-09-11' , '2020-09-12', 'true', 3, 'credit card', 'poDeliver', 'true');
CALL add_bid_TEMP('zxcher','Ed', 'Hamster', 'littleJohn','2020-09-11' , '2020-09-12', 'true', 3, 'cash', 'ctPickup', 'true');
--41
CALL add_bid_TEMP('nightDreamers','Peach', 'Pitbull', 'littleJohn','2020-09-11' , '2020-09-12', 'true', 3, 'credit card', 'ctPickup', 'true');
CALL add_bid_TEMP('battyBat','tweet', 'Free-range Birds', 'littleJohn','2020-09-11' , '2020-09-12', 'true', 3, 'cash', 'poDeliver', 'true');
CALL add_bid_TEMP('zxcher','Cookies', 'Rabbit', 'littleJohn','2020-09-11' , '2020-09-12', 'true', 4, 'cash', 'poDeliver', 'true');
--44
CALL add_bid_TEMP('nightDreamers','Marbles', 'Chihuahua', 'littleJohn','2020-09-13' , '2020-09-14', 'true', 5, 'credit card', 'ctPickup', 'true');
CALL add_bid_TEMP('battyBat','Andrea', 'Caged Insects', 'littleJohn','2020-09-13' , '2020-09-14', 'true', 5, 'credit card', 'poDeliver', 'true');
CALL add_bid_TEMP('nightDreamers','Kermit', 'Aquarium Fish', 'littleJohn','2020-09-13' , '2020-09-14', 'true', 3, 'cash', 'poDeliver', 'true');
CALL add_bid_TEMP('zxcher','lil green', 'Snake', 'littleJohn','2020-09-13' , '2020-09-14', 'true', 3, 'credit card', 'poDeliver', 'true');
CALL add_bid_TEMP('zxcher','Ed', 'Hamster', 'littleJohn','2020-09-13' , '2020-09-14', 'true', 3, 'cash', 'ctPickup', 'true');
--49
CALL add_bid_TEMP('nightDreamers','Peach', 'Pitbull', 'littleJohn','2020-09-13' , '2020-09-14', 'true', 3, 'credit card', 'ctPickup', 'true');
CALL add_bid_TEMP('battyBat','tweet', 'Free-range Birds', 'littleJohn','2020-09-13' , '2020-09-14', 'true', 3, 'cash', 'poDeliver', 'true');
CALL add_bid_TEMP('zxcher','Cookies', 'Rabbit', 'littleJohn','2020-09-13' , '2020-09-14', 'true', 4, 'cash', 'poDeliver', 'true');
--52 
CALL add_bid_TEMP('nightDreamers','Marbles', 'Chihuahua', 'littleJohn','2020-09-15' , '2020-09-16', 'true', 5, 'credit card', 'ctPickup', 'true');
CALL add_bid_TEMP('battyBat','Andrea', 'Caged Insects', 'littleJohn','2020-09-15' , '2020-09-16', 'true', 5, 'credit card', 'poDeliver', 'true');
CALL add_bid_TEMP('nightDreamers','Kermit', 'Aquarium Fish', 'littleJohn','2020-09-15' , '2020-09-16', 'true', 3, 'cash', 'poDeliver', 'true');
CALL add_bid_TEMP('zxcher','lil green', 'Snake', 'littleJohn','2020-09-15' , '2020-09-16', 'true', 3, 'credit card', 'poDeliver', 'true');
CALL add_bid_TEMP('zxcher','Ed', 'Hamster', 'littleJohn','2020-09-15' , '2020-09-16', 'true', 3, 'cash', 'ctPickup', 'true');
--57
CALL add_bid_TEMP('nightDreamers','Peach', 'Pitbull', 'littleJohn','2020-09-15' , '2020-09-16', 'true', 3, 'credit card', 'ctPickup', 'true');
CALL add_bid_TEMP('battyBat','tweet', 'Free-range Birds', 'littleJohn','2020-09-15' , '2020-09-16', 'true', 3, 'cash', 'poDeliver', 'true');
CALL add_bid_TEMP('zxcher','Cookies', 'Rabbit', 'littleJohn','2020-09-15' , '2020-09-16', 'true', 4, 'cash', 'poDeliver', 'true');
--60
CALL add_bid_TEMP('nightDreamers','Marbles', 'Chihuahua', 'littleJohn','2020-09-17' , '2020-09-18', 'true', 5, 'credit card', 'ctPickup', 'true');
CALL add_bid_TEMP('battyBat','Andrea', 'Caged Insects', 'littleJohn','2020-09-17' , '2020-09-18', 'true', 5, 'credit card', 'poDeliver', 'true');
CALL add_bid_TEMP('nightDreamers','Kermit', 'Aquarium Fish', 'littleJohn','2020-09-17' , '2020-09-18', 'true', 3, 'cash', 'poDeliver', 'true');
CALL add_bid_TEMP('zxcher','lil green', 'Snake', 'littleJohn','2020-09-17' , '2020-09-18', 'true', 3, 'credit card', 'poDeliver', 'true');
CALL add_bid_TEMP('zxcher','Ed', 'Hamster', 'littleJohn','2020-09-17' , '2020-09-18', 'true', 3, 'cash', 'ctPickup', 'true');
--65
CALL add_bid_TEMP('nightDreamers','Peach', 'Pitbull', 'littleJohn','2020-09-17' , '2020-09-18', 'true', 3, 'credit card', 'ctPickup', 'true');
CALL add_bid_TEMP('battyBat','tweet', 'Free-range Birds', 'littleJohn','2020-09-17' , '2020-09-18', 'true', 3, 'cash', 'poDeliver', 'true');
CALL add_bid_TEMP('zxcher','Cookies', 'Rabbit', 'littleJohn','2020-09-17' , '2020-09-18', 'true', 4, 'cash', 'poDeliver', 'true');
--68
