-- SPECIFIC EXAMPLES

-- Category --
insert into Category (pettype, base_price) values ('Pitbull', 100);
insert into Category (pettype, base_price) values ('Chihuahua', 60);
insert into Category (pettype, base_price) values ('Aquarium Fish', 40);
insert into Category (pettype, base_price) values ('Rabbit', 65);
insert into Category (pettype, base_price) values ('Free-range Birds', 75);
insert into Category (pettype, base_price) values ('Snake', 135);
insert into Category (pettype, base_price) values ('Caged Insects', 60);
insert into Category (pettype, base_price) values ('Hamster', 50);

-- PetOwner 
INSERT INTO PetOwner VALUES ('zxcher', 'Reshvena', 28);
INSERT INTO Owned_Pet_Belongs VALUES ('zxcher', 'Snake', 'lil green', 5);
INSERT INTO Owned_Pet_Belongs VALUES ('zxcher', 'Rabbit', 'Cookies', 6);
INSERT INTO Owned_Pet_Belongs VALUES ('zxcher', 'Hamster', 'Ed', 2, 'Aggressive towards other animals');

-- PetOwner 
INSERT INTO PetOwner VALUES ('nightDreamers', 'Colt', 34);
INSERT INTO Owned_Pet_Belongs VALUES ('nightDreamers', 'Chihuahua', 'Marbles', 5);
INSERT INTO Owned_Pet_Belongs VALUES ('nightDreamers', 'Pitbull', 'Peach', 4, 'Has a hearing disability');
INSERT INTO Owned_Pet_Belongs VALUES ('nightDreamers', 'Aquarium Fish', 'Kermit', 2);

-- PetOwner 
INSERT INTO PetOwner VALUES ('battyBat', 'Betty', 21);
INSERT INTO Owned_Pet_Belongs VALUES ('battyBat', 'Caged Insects', 'Andrea', 1);
INSERT INTO Owned_Pet_Belongs VALUES ('battyBat', 'Free-range Birds', 'tweet', 4, 'Has a hearing disability');
INSERT INTO Owned_Pet_Belongs VALUES ('battyBat', 'Chihuahua', 'Mango' 2);


-- fulltimer : Good rating
insert into CareTaker values ('littleJohn', 'Terrence', 30);
insert into FullTimer values ('littleJohn');
insert into Has_Availability values ('littleJohn', '2020-02-01', '2020-06-30');
insert into Has_Availability values ('littleJohn', '2020-07-01', '2020-11-30');
insert into Cares values ('littleJohn', 'Chihuahua', 60)
insert into Cares values ('littleJohn', 'Snake', 135);
insert into Cares values ('littleJohn', 'Caged Insects', 60);
insert into Cares values ('littleJohn', 'Pitbull', 100)
insert into Cares values ('littleJohn', 'Free-range Birds', 75);
insert into Cares values ('littleJohn', 'Rabbit', 65);
insert into Cares values ('littleJohn', 'Aquarium Fish', 40);
insert into Cares values ('littleJohn', 'Hamster', 50);

-- fulltimer : Bad rating
insert into CareTaker values ('purpleAbi', 'Abigail', 20);
insert into FullTimer values ('purpleAbi');
insert into Has_Availability values ('purpleAbi', '2020-03-01', '2020-07-30');
insert into Has_Availability values ('purpleAbi', '2020-08-01', '2020-12-30');
insert into Cares values ('purpleAbi', 'Pitbull', 100)
insert into Cares values ('purpleAbi', 'Free-range Birds', 75);
insert into Cares values ('purpleAbi', 'Rabbit', 65);

-- parttimer: ok rating
insert into CareTaker values ('Dustion', 'Dalton'. 25);
insert into PartTimer values ('Dustion');
insert into Cares values ('Dustion', 'Snake', 130);
insert into Cares values ('Dustion', 'Aquarium Fish', 35);
insert into Cares values ('Dustion', 'Hamster', 55);
insert into Has_Availability values ('Dustion', '2020-04-01', '2020-04-30');
insert into Has_Availability values ('Dustion', '2020-05-15', '2020-06-25');
insert into Has_Availability values ('Dustion', '2020-07-01', '2020-09-30');
insert into Has_Availability values ('Dustion', '2020-10-01', '2020-12-31');

-- Successful Bids for parttimer: Dustion
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, review, pay_type, pet_pickup, pay_status) values ('nightDreamers','Kermit', 'Aquarium Fish', 'Dustion','2020-04-05' , '2020-04-07', 'true', 3, 'Good service', 'cash', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, review, pay_type, pet_pickup, pay_status) values ('zxcher','lil green', 'Snake', 'Dustion','2020-08-02' , '2020-08-06', 'true', 3, 'Caretaker was very nice. Took good care of my snake.', 'credit card', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status)values ('zxcher','Ed', 'Hamster', 'Dustion','2020-08-05' , '2020-08-10', 'true', 3, 'cash', 'ctPickup', 'true');


-- Successful Bids for fulltimer: purpleAbi, AVAIL: '2020-03-01', '2020-07-30' AND '2020-08-01', '2020-12-30'
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, review, pay_type, pet_pickup, pay_status) values ('nightDreamers','Peach', 'Pitbull', 'purpleAbi','2020-05-16' , '2020-05-20', 'true', 2, 'Did take my dog out on walks regularly', 'credit card', 'ctPickup', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, review, pay_type, pet_pickup, pay_status) values ('battyBat','tweet', 'Free-range Birds', 'purpleAbi','2020-07-01' , '2020-07-02', 'true', 3, 'Did not feed my bird with appropriate seeds. Bad service.', 'cash', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, review, pay_type, pet_pickup, pay_status) values ('zxcher','Cookies', 'Rabbit', 'purpleAbi','2020-09-20' , '2020-09-25', 'true', 2, 'Bad mannered caretaker', 'cash', 'poDeliver', 'true');


-- Successful Bids for fulltimer: littleJohn, AVAIL: '2020-02-01', '2020-06-30' AND '2020-07-01', '2020-11-30'
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, review, pay_type, pet_pickup, pay_status) values ('zxcher','lil green', 'Snake', 'littleJohn','2020-03-01', '2020-03-15', 'true', 5, 'Great services! Very impressed with his thoughtfulness', 'credit card', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, review, pay_type, pet_pickup, pay_status) values ('nightDreamers','Marbles', 'Chihuahua', 'littleJohn','2020-04-20' , '2020-04-25', 'true', 5, 'Very accommodating caretaker!','credit card', 'ctPickup', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('battyBat','Andrea', 'Caged Insects', 'littleJohn','2020-08-01' , '2020-08-10', 'true', 5, 'credit card', 'poDeliver', 'true');

-- making > 60 pet days for cartaker littleJohn on month Septemeber
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Peach', 'Pitbull', 'littleJohn','2020-09-01' , '2020-09-02', 'true', 3, 'credit card', 'ctPickup', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('battyBat','tweet', 'Free-range Birds', 'littleJohn','2020-09-01' , '2020-09-02', 'true', 3, 'cash', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','Cookies', 'Rabbit', 'littleJohn','2020-09-01' , '2020-09-02', 'true', 4, 'cash', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','lil green', 'Snake', 'littleJohn','2020-09-01', '2020-09-02', 'true', 5, 'credit card', 'poDeliver', 'true');
--4
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Marbles', 'Chihuahua', 'littleJohn','2020-09-03' , '2020-09-04', 'true', 5, 'credit card', 'ctPickup', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('battyBat','Andrea', 'Caged Insects', 'littleJohn','2020-09-03' , '2020-09-04', 'true', 5, 'credit card', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Kermit', 'Aquarium Fish', 'littleJohn','2020-09-03' , '2020-09-04', 'true', 3, 'cash', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','lil green', 'Snake', 'littleJohn','2020-09-03' , '2020-09-04', 'true', 3, 'credit card', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','Ed', 'Hamster', 'littleJohn','2020-09-03' , '2020-09-04', 'true', 3, 'cash', 'ctPickup', 'true');
--9
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Peach', 'Pitbull', 'littleJohn','2020-09-03' , '2020-09-04', 'true', 3, 'credit card', 'ctPickup', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('battyBat','tweet', 'Free-range Birds', 'littleJohn','2020-09-03' , '2020-09-04', 'true', 3, 'cash', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','Cookies', 'Rabbit', 'littleJohn','2020-09-03' , '2020-09-04', 'true', 4, 'cash', 'poDeliver', 'true');
--12
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Marbles', 'Chihuahua', 'littleJohn','2020-09-05' , '2020-09-06', 'true', 5, 'credit card', 'ctPickup', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('battyBat','Andrea', 'Caged Insects', 'littleJohn','2020-09-05' , '2020-09-06', 'true', 5, 'credit card', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Kermit', 'Aquarium Fish', 'littleJohn','2020-09-05' , '2020-09-06', 'true', 3, 'cash', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','lil green', 'Snake', 'littleJohn','2020-09-05' , '2020-09-06', 'true', 3, 'credit card', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','Ed', 'Hamster', 'littleJohn','2020-09-05' , '2020-09-06', 'true', 3, 'cash', 'ctPickup', 'true');
--17
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Peach', 'Pitbull', 'littleJohn','2020-09-05' , '2020-09-06', 'true', 3, 'credit card', 'ctPickup', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('battyBat','tweet', 'Free-range Birds', 'littleJohn','2020-09-05' , '2020-09-06', 'true', 3, 'cash', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','Cookies', 'Rabbit', 'littleJohn','2020-09-05' , '2020-09-06', 'true', 4, 'cash', 'poDeliver', 'true');
--20
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Marbles', 'Chihuahua', 'littleJohn','2020-09-07' , '2020-09-08', 'true', 5, 'credit card', 'ctPickup', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('battyBat','Andrea', 'Caged Insects', 'littleJohn','2020-09-07' , '2020-09-08', 'true', 5, 'credit card', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Kermit', 'Aquarium Fish', 'littleJohn','2020-09-07' , '2020-09-08', 'true', 3, 'cash', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','lil green', 'Snake', 'littleJohn','2020-09-07' , '2020-09-08', 'true', 3, 'credit card', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','Ed', 'Hamster', 'littleJohn','2020-09-07' , '2020-09-08', 'true', 3, 'cash', 'ctPickup', 'true');
--25
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Peach', 'Pitbull', 'littleJohn','2020-09-07' , '2020-09-08', 'true', 3, 'credit card', 'ctPickup', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('battyBat','tweet', 'Free-range Birds', 'littleJohn','2020-09-07' , '2020-09-08', 'true', 3, 'cash', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','Cookies', 'Rabbit', 'littleJohn','2020-09-07' , '2020-09-08', 'true', 4, 'cash', 'poDeliver', 'true');
--28
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Marbles', 'Chihuahua', 'littleJohn','2020-09-09' , '2020-09-10', 'true', 5, 'credit card', 'ctPickup', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('battyBat','Andrea', 'Caged Insects', 'littleJohn','2020-09-09' , '2020-09-10', 'true', 5, 'credit card', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Kermit', 'Aquarium Fish', 'littleJohn','2020-09-09' , '2020-09-10', 'true', 3, 'cash', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','lil green', 'Snake', 'littleJohn','2020-09-09' , '2020-09-10', 'true', 3, 'credit card', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','Ed', 'Hamster', 'littleJohn','2020-09-09' , '2020-09-10', 'true', 3, 'cash', 'ctPickup', 'true');
--33
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Peach', 'Pitbull', 'littleJohn','2020-09-09' , '2020-09-10', 'true', 3, 'credit card', 'ctPickup', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('battyBat','tweet', 'Free-range Birds', 'littleJohn','2020-09-09' , '2020-09-10', 'true', 3, 'cash', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','Cookies', 'Rabbit', 'littleJohn','2020-09-09' , '2020-09-10', 'true', 4, 'cash', 'poDeliver', 'true');
--36
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Marbles', 'Chihuahua', 'littleJohn','2020-09-11' , '2020-09-12', 'true', 5, 'credit card', 'ctPickup', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('battyBat','Andrea', 'Caged Insects', 'littleJohn','2020-09-11' , '2020-09-12', 'true', 5, 'credit card', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Kermit', 'Aquarium Fish', 'littleJohn','2020-09-11' , '2020-09-12', 'true', 3, 'cash', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','lil green', 'Snake', 'littleJohn','2020-09-11' , '2020-09-12', 'true', 3, 'credit card', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','Ed', 'Hamster', 'littleJohn','2020-09-11' , '2020-09-12', 'true', 3, 'cash', 'ctPickup', 'true');
--41
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Peach', 'Pitbull', 'littleJohn','2020-09-11' , '2020-09-12', 'true', 3, 'credit card', 'ctPickup', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('battyBat','tweet', 'Free-range Birds', 'littleJohn','2020-09-11' , '2020-09-12', 'true', 3, 'cash', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','Cookies', 'Rabbit', 'littleJohn','2020-09-11' , '2020-09-12', 'true', 4, 'cash', 'poDeliver', 'true');
--44
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Marbles', 'Chihuahua', 'littleJohn','2020-09-13' , '2020-09-14', 'true', 5, 'credit card', 'ctPickup', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('battyBat','Andrea', 'Caged Insects', 'littleJohn','2020-09-13' , '2020-09-14', 'true', 5, 'credit card', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Kermit', 'Aquarium Fish', 'littleJohn','2020-09-13' , '2020-09-14', 'true', 3, 'cash', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','lil green', 'Snake', 'littleJohn','2020-09-13' , '2020-09-14', 'true', 3, 'credit card', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','Ed', 'Hamster', 'littleJohn','2020-09-13' , '2020-09-14', 'true', 3, 'cash', 'ctPickup', 'true');
--49
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Peach', 'Pitbull', 'littleJohn','2020-09-13' , '2020-09-14', 'true', 3, 'credit card', 'ctPickup', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('battyBat','tweet', 'Free-range Birds', 'littleJohn','2020-09-13' , '2020-09-14', 'true', 3, 'cash', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','Cookies', 'Rabbit', 'littleJohn','2020-09-13' , '2020-09-14', 'true', 4, 'cash', 'poDeliver', 'true');
--52 
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Marbles', 'Chihuahua', 'littleJohn','2020-09-15' , '2020-09-16', 'true', 5, 'credit card', 'ctPickup', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('battyBat','Andrea', 'Caged Insects', 'littleJohn','2020-09-15' , '2020-09-16', 'true', 5, 'credit card', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Kermit', 'Aquarium Fish', 'littleJohn','2020-09-15' , '2020-09-16', 'true', 3, 'cash', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','lil green', 'Snake', 'littleJohn','2020-09-15' , '2020-09-16', 'true', 3, 'credit card', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','Ed', 'Hamster', 'littleJohn','2020-09-15' , '2020-09-16', 'true', 3, 'cash', 'ctPickup', 'true');
--57
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Peach', 'Pitbull', 'littleJohn','2020-09-15' , '2020-09-16', 'true', 3, 'credit card', 'ctPickup', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('battyBat','tweet', 'Free-range Birds', 'littleJohn','2020-09-15' , '2020-09-16', 'true', 3, 'cash', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','Cookies', 'Rabbit', 'littleJohn','2020-09-15' , '2020-09-16', 'true', 4, 'cash', 'poDeliver', 'true');
--60
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Marbles', 'Chihuahua', 'littleJohn','2020-09-17' , '2020-09-18', 'true', 5, 'credit card', 'ctPickup', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('battyBat','Andrea', 'Caged Insects', 'littleJohn','2020-09-17' , '2020-09-18', 'true', 5, 'credit card', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Kermit', 'Aquarium Fish', 'littleJohn','2020-09-17' , '2020-09-18', 'true', 3, 'cash', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','lil green', 'Snake', 'littleJohn','2020-09-17' , '2020-09-18', 'true', 3, 'credit card', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','Ed', 'Hamster', 'littleJohn','2020-09-17' , '2020-09-18', 'true', 3, 'cash', 'ctPickup', 'true');
--65
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('nightDreamers','Peach', 'Pitbull', 'littleJohn','2020-09-17' , '2020-09-18', 'true', 3, 'credit card', 'ctPickup', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('battyBat','tweet', 'Free-range Birds', 'littleJohn','2020-09-17' , '2020-09-18', 'true', 3, 'cash', 'poDeliver', 'true');
insert into Bid (pouname, petname, pettype, ctuname, s_time, e_time, is_win, rating, pay_type, pet_pickup, pay_status) values ('zxcher','Cookies', 'Rabbit', 'littleJohn','2020-09-17' , '2020-09-18', 'true', 4, 'cash', 'poDeliver', 'true');
--68