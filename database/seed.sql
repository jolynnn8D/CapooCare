/* SEED */
INSERT INTO PCSAdmin(username, adminName) VALUES ('Red', 'red');
INSERT INTO PCSAdmin(username, adminName) VALUES ('White', 'white');

/* Setting categories and their base price */
INSERT INTO Category(pettype, base_price) VALUES ('dog', 60),('cat', 60),('rabbit', 50),('big dog', 70),('lizard', 60),('bird', 60),('snake', 70),('fish',30);

CALL add_fulltimer('mary_caretaker', 'Mary', 22, 'bird', 60, '2020-01-01', '2020-05-30', '2020-06-01', '2020-12-20');
CALL add_fulltimer('bob_lovesdogs', 'Bob', 25, 'dog', 60, '2020-01-01', '2020-05-30', '2020-06-01', '2020-12-20');
CALL add_fulltimer('ameliaCareServices', 'Amelia', 20, 'rabbit', 50, '2020-01-01', '2020-05-30', '2020-06-01', '2020-12-20');
/* add next year periods for ameliaCareServices FT */
CALL add_fulltimer('ameliaCareServices', NULL, NULL, NULL, NULL, '2021-01-01', '2021-05-30', '2021-06-01', '2021-12-20');

CALL add_parttimer('supercaretaker', 'Kenny Goh', 35, 'cat', 60);
CALL add_parttimer('harrylampets', 'Harry', 28, 'cat', 35);
CALL add_parttimer('caretakeriam', 'Jessica', 35, 'cat', 60);

CALL add_petOwner('johnthebest', 'John', 50, 'dog', 'Fido', 10, NULL);
CALL add_petOwner('marythemess', 'Mary', 25, 'dog', 'Fido', 10, NULL);
CALL add_petOwner('thomasthetank', 'Tom', 15, 'cat', 'Claw', 10, NULL);

INSERT INTO Owned_Pet_Belongs VALUES ('marythemess', 'big dog', 'Champ', 10, NULL);
INSERT INTO Owned_Pet_Belongs VALUES ('marythemess', 'big dog', 'Ruff', 12, 'Hates cats');
INSERT INTO Owned_Pet_Belongs VALUES ('marythemess', 'big dog', 'Bark', 14, 'Can be very loud');
INSERT INTO Owned_Pet_Belongs VALUES ('marythemess', 'cat', 'Meow', 10, NULL);
INSERT INTO Owned_Pet_Belongs VALUES ('marythemess', 'cat', 'Purr', 15, 'Hates dogs');
INSERT INTO Owned_Pet_Belongs VALUES ('marythemess', 'cat', 'Sneak', 20, 'Needs to go outside a lot');
INSERT INTO Owned_Pet_Belongs VALUES ('johnthebest', 'fish', 'Bloop', 1, 'Needs to be fed thrice a day');
INSERT INTO Owned_Pet_Belongs VALUES ('johnthebest', 'snake', 'Hiss', 5, 'Just keep an eye on him');

/* Fulltimers' cares */
INSERT INTO Cares VALUES ('mary_caretaker', 'rabbit', 50);
INSERT INTO Cares VALUES ('mary_caretaker', 'dog', 60);
INSERT INTO Cares VALUES ('mary_caretaker', 'big dog', 70);
INSERT INTO Cares VALUES ('mary_caretaker', 'cat', 60);
INSERT INTO Cares VALUES ('ameliaCareServices', 'big dog', 70);
INSERT INTO Cares VALUES ('ameliaCareServices', 'snake', 70);
INSERT INTO Cares VALUES ('ameliaCareServices', 'fish', 30);
--INSERT INTO Cares VALUES ('bob_lovesdogs', 'big dog', 70);
INSERT INTO Cares VALUES ('bob_lovesdogs', 'cat', 60);

/* Parttimers' Cares */
INSERT INTO Cares VALUES ('supercaretaker', 'dog', 60);
/* Remove the following line to encounter pet type error */
INSERT INTO Cares VALUES ('supercaretaker', 'big dog', 90);

INSERT INTO Has_Availability VALUES ('mary_caretaker', '2020-01-01', '2020-03-04');
INSERT INTO Has_Availability VALUES ('mary_caretaker', '2021-01-01', '2021-03-04');
INSERT INTO Has_Availability VALUES ('bob_lovesdogs', '2021-01-01', '2021-03-04');
INSERT INTO Has_Availability VALUES ('ameliaCareServices', '2021-01-01', '2021-03-04');
INSERT INTO Has_Availability VALUES ('supercaretaker', '2021-01-01', '2021-03-04');
INSERT INTO Has_Availability VALUES ('supercaretaker', '2020-06-02', '2020-06-08');
INSERT INTO Has_Availability VALUES ('supercaretaker', '2020-12-04', '2020-12-20');
INSERT INTO Has_Availability VALUES ('supercaretaker', '2020-08-08', '2020-08-10');


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


INSERT INTO Has_Availability VALUES ('supercaretaker', '2020-06-01', '2020-06-06');
INSERT INTO Has_Availability VALUES ('mary_caretaker', '2020-06-01', '2020-06-06');
INSERT INTO Has_Availability VALUES ('bob_lovesdogs', '2020-06-01', '2020-06-06');

-- saturation of PT capacity --
CALL add_bid('marythemess', 'Champ', 'big dog', 'supercaretaker', '2020-06-01', '2020-06-06', 'cash', 'poDeliver');
UPDATE Bid SET is_win = true WHERE ctuname = 'supercaretaker' AND pouname = 'marythemess' AND petname = 'Champ'
   AND pettype = 'big dog' AND s_time = to_date('20200601','YYYYMMDD') AND e_time = to_date('20200606','YYYYMMDD');
CALL add_bid('marythemess', 'Meow', 'cat', 'supercaretaker', '2020-06-01', '2020-06-06', 'cash', 'poDeliver');
UPDATE Bid SET is_win = true WHERE ctuname = 'supercaretaker' AND pouname = 'marythemess' AND petname = 'Meow'
   AND pettype = 'cat' AND s_time = to_date('20200601','YYYYMMDD') AND e_time = to_date('20200606','YYYYMMDD');

--Frontend mock data--
CALL add_petOwner('petownerdavid', 'David', 35, 'cat', 'Capoo', 1, 'Needs to be walked everyday');
INSERT INTO Owned_Pet_Belongs VALUES ('petownerdavid', 'big dog', 'Brownie', 8, NULL);
INSERT INTO Owned_Pet_Belongs VALUES ('petownerdavid', 'cat', 'Meow', 2, NULL);
INSERT INTO Owned_Pet_Belongs VALUES ('petownerdavid', 'fish', 'Torpedo', 1, NULL);
INSERT INTO Owned_Pet_Belongs VALUES ('petownerdavid', 'cat', 'Snowy', 1, NULL);
INSERT INTO Owned_Pet_Belongs VALUES ('petownerdavid', 'dog', 'Woof', 2, NULL);

CALL add_fulltimer('caretaker_amy', 'Amy', 22, 'cat', 60, '2020-01-01', '2020-05-30', '2020-06-01', '2020-12-20');
CALL add_fulltimer('new_caretaker', 'Sebastian', 50, 'big dog', 70, '2021-01-01', '2021-06-01', '2021-06-02', '2021-12-30');
CALL add_fulltimer('new_caretaker', NULL, NULL,  NULL, NULL, '2020-01-01', '2020-06-01', '2020-06-02', '2020-12-30');


CALL add_parttimer('johnhammington', 'John', 28, 'cat', 35);

INSERT INTO Has_Availability VALUES ('johnhammington', '2021-02-01', '2021-04-30');
INSERT INTO Cares VALUES ('caretaker_amy', 'big dog', 70);
INSERT INTO Cares VALUES ('new_caretaker', 'cat', 60);
INSERT INTO Cares VALUES ('new_caretaker', 'dog', 60);




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


-- --SPECIFIC EXAMPLES

-- --Category
-- insert into Category (pettype, base_price) values ('Pitbull', 100);
-- insert into Category (pettype, base_price) values ('Chihuahua', 60);
-- insert into Category (pettype, base_price) values ('Aquarium Fish', 40);
-- insert into Category (pettype, base_price) values ('Rabbit', 65);
-- insert into Category (pettype, base_price) values ('Free-range Birds', 75);
-- insert into Category (pettype, base_price) values ('Snake', 135);
-- insert into Category (pettype, base_price) values ('Caged Insects', 60);
-- insert into Category (pettype, base_price) values ('Hamster', 50);

-- -- PetOwner 
-- INSERT INTO PetOwner VALUES ('zxcher', 'Reshvena', 28);
-- INSERT INTO Owned_Pet_Belongs VALUES ('zxcher', 'Snake', 'lil green', 5);
-- INSERT INTO Owned_Pet_Belongs VALUES ('zxcher', 'Rabbit', 'Cookies', 6);
-- INSERT INTO Owned_Pet_Belongs VALUES ('zxcher', 'Hamster', 'Ed', 2, 'Aggressive towards other animals');

-- -- PetOwner 
-- INSERT INTO PetOwner VALUES ('nightDreamers', 'Colt', 34);
-- INSERT INTO Owned_Pet_Belongs VALUES ('nightDreamers', 'Chihuahua', 'Marbles', 5);
-- INSERT INTO Owned_Pet_Belongs VALUES ('nightDreamers', 'Pitbull', 'Peach', 4, 'Has a hearing disability');
-- INSERT INTO Owned_Pet_Belongs VALUES ('nightDreamers', 'Aquarium Fish', 'Kermit', 2);

-- -- PetOwner 
-- INSERT INTO PetOwner VALUES ('battyBat', 'Betty', 21);
-- INSERT INTO Owned_Pet_Belongs VALUES ('battyBat', 'Caged Insects', 'Andrea', 1);
-- INSERT INTO Owned_Pet_Belongs VALUES ('battyBat', 'Free-range Birds', 'tweet', 4, 'Has a hearing disability');
-- INSERT INTO Owned_Pet_Belongs VALUES ('battyBat', 'Chihuahua', 'Mango', 2);

-- -- fulltimer : Good rating
-- insert into CareTaker values ('littleJohn', 'Terrence', 30);
-- insert into FullTimer values ('littleJohn');
-- insert into Has_Availability values ('littleJohn', '2020-02-01', '2020-06-30');
-- insert into Has_Availability values ('littleJohn', '2020-07-01', '2020-11-30');
-- insert into Cares values ('littleJohn', 'Chihuahua', 60);
-- insert into Cares values ('littleJohn', 'Snake', 135);
-- insert into Cares values ('littleJohn', 'Caged Insects', 60);
-- insert into Cares values ('littleJohn', 'Pitbull', 100);
-- insert into Cares values ('littleJohn', 'Free-range Birds', 75);
-- insert into Cares values ('littleJohn', 'Rabbit', 65);
-- insert into Cares values ('littleJohn', 'Aquarium Fish', 40);
-- insert into Cares values ('littleJohn', 'Hamster', 50);

-- -- fulltimer : Bad rating
-- insert into CareTaker values ('purpleAbi', 'Abigail', 20);
-- insert into FullTimer values ('purpleAbi');
-- insert into Has_Availability values ('purpleAbi', '2020-03-01', '2020-07-30');
-- insert into Has_Availability values ('purpleAbi', '2020-08-01', '2020-12-30');
-- insert into Cares values ('purpleAbi', 'Pitbull', 100);
-- insert into Cares values ('purpleAbi', 'Free-range Birds', 75);
-- insert into Cares values ('purpleAbi', 'Rabbit', 65);

-- -- parttimer: ok rating
-- insert into CareTaker values ('Dustion', 'Dalton', 25);
-- insert into PartTimer values ('Dustion');
-- insert into Cares values ('Dustion', 'Snake', 130);
-- insert into Cares values ('Dustion', 'Aquarium Fish', 35);
-- insert into Cares values ('Dustion', 'Hamster', 55);
-- insert into Has_Availability values ('Dustion', '2020-04-01', '2020-04-30');
-- insert into Has_Availability values ('Dustion', '2020-05-15', '2020-06-25');
-- insert into Has_Availability values ('Dustion', '2020-07-01', '2020-09-30');
-- insert into Has_Availability values ('Dustion', '2020-10-01', '2020-12-31');

-- -- Successful Bids for parttimer: Dustion
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, review, pay_type, pet_pickup, pay_status) values ('nightDreamers','Kermit', 'Aquarium Fish', 'Dustion','2020-04-05' , '2020-04-07', 'true', 3, 'Good service', 'cash', 'poDeliver', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, review, pay_type, pet_pickup, pay_status) values ('zxcher','lil green', 'Snake', 'Dustion','2020-08-02' , '2020-08-06', 'true', 3, 'Caretaker was very nice. Took good care of my snake.', 'credit card', 'poDeliver', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status)values ('zxcher','Ed', 'Hamster', 'Dustion','2020-08-05' , '2020-08-10', 'true', 3, 'cash', 'ctPickup', 'true');


-- -- Successful Bids for fulltimer: purpleAbi, AVAIL: '2020-03-01', '2020-07-30' AND '2020-08-01', '2020-12-30'
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, review, pay_type, pet_pickup, pay_status) values ('nightDreamers','Peach', 'Pitbull', 'purpleAbi','2020-05-16' , '2020-05-20', 'true', 2, 'Did take my dog out on walks regularly', 'credit card', 'ctPickup', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, review, pay_type, pet_pickup, pay_status) values ('battyBat','tweet', 'Free-range Birds', 'purpleAbi','2020-07-01' , '2020-07-02', 'true', 3, 'Did not feed my bird with appropriate seeds. Bad service.', 'cash', 'poDeliver', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, review, pay_type, pet_pickup, pay_status) values ('zxcher','Cookies', 'Rabbit', 'purpleAbi','2020-09-20' , '2020-09-25', 'true', 2, 'Bad mannered caretaker', 'cash', 'poDeliver', 'true');


-- -- Successful Bids for fulltimer: littleJohn, AVAIL: '2020-02-01', '2020-06-30' AND '2020-07-01', '2020-11-30'
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, review, pay_type, pet_pickup, pay_status) values ('zxcher','lil green', 'Snake', 'littleJohn','2020-03-01', '2020-03-15', 'true', 5, 'Great services! Very impressed with his thoughtfulness', 'credit card', 'poDeliver', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, review, pay_type, pet_pickup, pay_status) values ('nightDreamers','Marbles', 'Chihuahua', 'littleJohn','2020-04-20' , '2020-04-25', 'true', 5, 'Very accommodating caretaker!','credit card', 'ctPickup', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('battyBat','Andrea', 'Caged Insects', 'littleJohn','2020-08-01' , '2020-08-10', 'true', 5, 'credit card', 'poDeliver', 'true');

-- -- making > 60 pet days for cartaker littleJohn on month Septemeber
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Peach', 'Pitbull', 'littleJohn','2020-09-01' , '2020-09-02', 'true', 3, 'credit card', 'ctPickup', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('battyBat','tweet', 'Free-range Birds', 'littleJohn','2020-09-01' , '2020-09-02', 'true', 3, 'cash', 'poDeliver', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','Cookies', 'Rabbit', 'littleJohn','2020-09-01' , '2020-09-02', 'true', 4, 'cash', 'poDeliver', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','lil green', 'Snake', 'littleJohn','2020-09-01', '2020-09-02', 'true', 5, 'credit card', 'poDeliver', 'true');
-- --4
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Marbles', 'Chihuahua', 'littleJohn','2020-09-03' , '2020-09-04', 'true', 5, 'credit card', 'ctPickup', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('battyBat','Andrea', 'Caged Insects', 'littleJohn','2020-09-03' , '2020-09-04', 'true', 5, 'credit card', 'poDeliver', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Kermit', 'Aquarium Fish', 'littleJohn','2020-09-03' , '2020-09-04', 'true', 3, 'cash', 'poDeliver', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','lil green', 'Snake', 'littleJohn','2020-09-03' , '2020-09-04', 'true', 3, 'credit card', 'poDeliver', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','Ed', 'Hamster', 'littleJohn','2020-09-03' , '2020-09-04', 'true', 3, 'cash', 'ctPickup', 'true');
-- --9
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Peach', 'Pitbull', 'littleJohn','2020-09-03' , '2020-09-04', 'true', 3, 'credit card', 'ctPickup', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('battyBat','tweet', 'Free-range Birds', 'littleJohn','2020-09-03' , '2020-09-04', 'true', 3, 'cash', 'poDeliver', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','Cookies', 'Rabbit', 'littleJohn','2020-09-03' , '2020-09-04', 'true', 4, 'cash', 'poDeliver', 'true');
-- --12
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Marbles', 'Chihuahua', 'littleJohn','2020-09-05' , '2020-09-06', 'true', 5, 'credit card', 'ctPickup', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('battyBat','Andrea', 'Caged Insects', 'littleJohn','2020-09-05' , '2020-09-06', 'true', 5, 'credit card', 'poDeliver', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Kermit', 'Aquarium Fish', 'littleJohn','2020-09-05' , '2020-09-06', 'true', 3, 'cash', 'poDeliver', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','lil green', 'Snake', 'littleJohn','2020-09-05' , '2020-09-06', 'true', 3, 'credit card', 'poDeliver', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','Ed', 'Hamster', 'littleJohn','2020-09-05' , '2020-09-06', 'true', 3, 'cash', 'ctPickup', 'true');
-- --17
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Peach', 'Pitbull', 'littleJohn','2020-09-05' , '2020-09-06', 'true', 3, 'credit card', 'ctPickup', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('battyBat','tweet', 'Free-range Birds', 'littleJohn','2020-09-05' , '2020-09-06', 'true', 3, 'cash', 'poDeliver', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','Cookies', 'Rabbit', 'littleJohn','2020-09-05' , '2020-09-06', 'true', 4, 'cash', 'poDeliver', 'true');
-- --20
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Marbles', 'Chihuahua', 'littleJohn','2020-09-07' , '2020-09-08', 'true', 5, 'credit card', 'ctPickup', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('battyBat','Andrea', 'Caged Insects', 'littleJohn','2020-09-07' , '2020-09-08', 'true', 5, 'credit card', 'poDeliver', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Kermit', 'Aquarium Fish', 'littleJohn','2020-09-07' , '2020-09-08', 'true', 3, 'cash', 'poDeliver', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','lil green', 'Snake', 'littleJohn','2020-09-07' , '2020-09-08', 'true', 3, 'credit card', 'poDeliver', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','Ed', 'Hamster', 'littleJohn','2020-09-07' , '2020-09-08', 'true', 3, 'cash', 'ctPickup', 'true');
-- --25
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Peach', 'Pitbull', 'littleJohn','2020-09-07' , '2020-09-08', 'true', 3, 'credit card', 'ctPickup', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('battyBat','tweet', 'Free-range Birds', 'littleJohn','2020-09-07' , '2020-09-08', 'true', 3, 'cash', 'poDeliver', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','Cookies', 'Rabbit', 'littleJohn','2020-09-07' , '2020-09-08', 'true', 4, 'cash', 'poDeliver', 'true');
-- --28
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Marbles', 'Chihuahua', 'littleJohn','2020-09-09' , '2020-09-10', 'true', 5, 'credit card', 'ctPickup', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('battyBat','Andrea', 'Caged Insects', 'littleJohn','2020-09-09' , '2020-09-10', 'true', 5, 'credit card', 'poDeliver', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Kermit', 'Aquarium Fish', 'littleJohn','2020-09-09' , '2020-09-10', 'true', 3, 'cash', 'poDeliver', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','lil green', 'Snake', 'littleJohn','2020-09-09' , '2020-09-10', 'true', 3, 'credit card', 'poDeliver', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','Ed', 'Hamster', 'littleJohn','2020-09-09' , '2020-09-10', 'true', 3, 'cash', 'ctPickup', 'true');
-- --33
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Peach', 'Pitbull', 'littleJohn','2020-09-09' , '2020-09-10', 'true', 3, 'credit card', 'ctPickup', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('battyBat','tweet', 'Free-range Birds', 'littleJohn','2020-09-09' , '2020-09-10', 'true', 3, 'cash', 'poDeliver', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','Cookies', 'Rabbit', 'littleJohn','2020-09-09' , '2020-09-10', 'true', 4, 'cash', 'poDeliver', 'true');
-- --36
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Marbles', 'Chihuahua', 'littleJohn','2020-09-11' , '2020-09-12', 'true', 5, 'credit card', 'ctPickup', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('battyBat','Andrea', 'Caged Insects', 'littleJohn','2020-09-11' , '2020-09-12', 'true', 5, 'credit card', 'poDeliver', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Kermit', 'Aquarium Fish', 'littleJohn','2020-09-11' , '2020-09-12', 'true', 3, 'cash', 'poDeliver', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','lil green', 'Snake', 'littleJohn','2020-09-11' , '2020-09-12', 'true', 3, 'credit card', 'poDeliver', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','Ed', 'Hamster', 'littleJohn','2020-09-11' , '2020-09-12', 'true', 3, 'cash', 'ctPickup', 'true');
-- --41
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Peach', 'Pitbull', 'littleJohn','2020-09-11' , '2020-09-12', 'true', 3, 'credit card', 'ctPickup', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('battyBat','tweet', 'Free-range Birds', 'littleJohn','2020-09-11' , '2020-09-12', 'true', 3, 'cash', 'poDeliver', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','Cookies', 'Rabbit', 'littleJohn','2020-09-11' , '2020-09-12', 'true', 4, 'cash', 'poDeliver', 'true');
-- --44
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Marbles', 'Chihuahua', 'littleJohn','2020-09-13' , '2020-09-14', 'true', 5, 'credit card', 'ctPickup', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('battyBat','Andrea', 'Caged Insects', 'littleJohn','2020-09-13' , '2020-09-14', 'true', 5, 'credit card', 'poDeliver', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Kermit', 'Aquarium Fish', 'littleJohn','2020-09-13' , '2020-09-14', 'true', 3, 'cash', 'poDeliver', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','lil green', 'Snake', 'littleJohn','2020-09-13' , '2020-09-14', 'true', 3, 'credit card', 'poDeliver', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','Ed', 'Hamster', 'littleJohn','2020-09-13' , '2020-09-14', 'true', 3, 'cash', 'ctPickup', 'true');
-- --49
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Peach', 'Pitbull', 'littleJohn','2020-09-13' , '2020-09-14', 'true', 3, 'credit card', 'ctPickup', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('battyBat','tweet', 'Free-range Birds', 'littleJohn','2020-09-13' , '2020-09-14', 'true', 3, 'cash', 'poDeliver', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','Cookies', 'Rabbit', 'littleJohn','2020-09-13' , '2020-09-14', 'true', 4, 'cash', 'poDeliver', 'true');
-- --52 
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Marbles', 'Chihuahua', 'littleJohn','2020-09-15' , '2020-09-16', 'true', 5, 'credit card', 'ctPickup', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('battyBat','Andrea', 'Caged Insects', 'littleJohn','2020-09-15' , '2020-09-16', 'true', 5, 'credit card', 'poDeliver', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Kermit', 'Aquarium Fish', 'littleJohn','2020-09-15' , '2020-09-16', 'true', 3, 'cash', 'poDeliver', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','lil green', 'Snake', 'littleJohn','2020-09-15' , '2020-09-16', 'true', 3, 'credit card', 'poDeliver', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','Ed', 'Hamster', 'littleJohn','2020-09-15' , '2020-09-16', 'true', 3, 'cash', 'ctPickup', 'true');
-- --57
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Peach', 'Pitbull', 'littleJohn','2020-09-15' , '2020-09-16', 'true', 3, 'credit card', 'ctPickup', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('battyBat','tweet', 'Free-range Birds', 'littleJohn','2020-09-15' , '2020-09-16', 'true', 3, 'cash', 'poDeliver', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','Cookies', 'Rabbit', 'littleJohn','2020-09-15' , '2020-09-16', 'true', 4, 'cash', 'poDeliver', 'true');
-- --60
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Marbles', 'Chihuahua', 'littleJohn','2020-09-17' , '2020-09-18', 'true', 5, 'credit card', 'ctPickup', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('battyBat','Andrea', 'Caged Insects', 'littleJohn','2020-09-17' , '2020-09-18', 'true', 5, 'credit card', 'poDeliver', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Kermit', 'Aquarium Fish', 'littleJohn','2020-09-17' , '2020-09-18', 'true', 3, 'cash', 'poDeliver', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','lil green', 'Snake', 'littleJohn','2020-09-17' , '2020-09-18', 'true', 3, 'credit card', 'poDeliver', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','Ed', 'Hamster', 'littleJohn','2020-09-17' , '2020-09-18', 'true', 3, 'cash', 'ctPickup', 'true');
-- --65
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Peach', 'Pitbull', 'littleJohn','2020-09-17' , '2020-09-18', 'true', 3, 'credit card', 'ctPickup', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('battyBat','tweet', 'Free-range Birds', 'littleJohn','2020-09-17' , '2020-09-18', 'true', 3, 'cash', 'poDeliver', 'true');
-- insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','Cookies', 'Rabbit', 'littleJohn','2020-09-17' , '2020-09-18', 'true', 4, 'cash', 'poDeliver', 'true');
-- --68