-- CS4400: Introduction to Database Systems (Fall 2022)
-- Phase II: Create Table & Insert Statements [v0] Monday, October 31, 2022 @ 
-- 11:00 pm (Local/EDT)
-- Team 80
-- Ton Quoc Bao Ngo (tngo67)
-- Xuan Vui Diep (xdiep3)
-- Hai Vo (hvo37)

-- Directions:
-- Please follow all instructions for Phase II as listed on Canvas.
-- Fill in the team number and names and GT usernames for all members above.
-- Create Table statements must be manually written, not taken from an SQL Dump 
-- file.
-- This file must run without error for credit.
-- ------------------------------------------------------
-- CREATE TABLE STATEMENTS AND INSERT STATEMENTS BELOW
-- ------------------------------------------------------

DROP DATABASE IF EXISTS delivery; 
CREATE DATABASE IF NOT EXISTS delivery; 
USE delivery; 

-- Section 1: Create Table Statements

-- Table structure for table user  
DROP TABLE IF EXISTS sys_user; 
CREATE TABLE sys_user (
	username varchar(40) NOT NULL,
    first_name varchar(100) NOT NULL, 
    last_name varchar(100) NOT NULL, 
    address varchar(500) NOT NULl,
    birthdate date NOT NULL, 
    primary key (username)
);

-- Table structure for table employee 
DROP TABLE IF EXISTS employee;
CREATE TABLE employee (
	username varchar(40) NOT NULL,
    taxID varchar(11), 
    hired date, 
    salary decimal(5,0),
    experience decimal(2,0), 
    primary key (username), 
    constraint owner_employee foreign key (username) references sys_user(username) 
);  

-- Table structure for table owner
DROP TABLE IF EXISTS sys_owner;
CREATE TABLE sys_owner (
	username varchar(40) NOT NULL,
	primary key (username), 
    constraint owner_user foreign key (username) references sys_user(username)
); 

-- Table structure for table location
DROP TABLE IF EXISTS location;
CREATE TABLE location (
	label varchar(40) NOT NULL, 
    x_coord decimal(2,0) NOT NULL, 
    y_coord decimal(2,0) NOT NULL, 
    space decimal(2,0), 
    locationID decimal(1,0) NOT NULL, 
    primary key (locationID)
);

-- Table structure for table restaurant
DROP TABLE IF EXISTS restaurant;
CREATE TABLE restaurant (
	res_name varchar(100) NOT NULL, 
    spent decimal(2,0) NOT NULL, 
    rating decimal(1,0) NOT NULL 
    check(rating >= 0 AND rating <= 5), 
    locationID decimal(1,0) NOT NULL, 
	primary key (res_name),
    constraint restaurant_location foreign key (locationID) references location(locationID)
);

-- Table structure for table service 
DROP TABLE IF EXISTS service;
CREATE TABLE service (
	id char(10), 
    service_name varchar(100) NOT NULL, 
	locationID decimal(1,0) NOT NULL,
    constraint service_location foreign key (locationID) references location(locationID),
    primary key (id)
); 

-- Table structure for table pilot
DROP TABLE IF EXISTS pilot; 
CREATE TABLE pilot (
	employee_username varchar(40) NOT NULL,
    license_type decimal(6,0), 
    experience decimal(2,0),
    primary key (employee_username), 
	constraint pilot_employee foreign key (employee_username) references employee(username)
); 

-- Table structure for table drone
DROP TABLE IF EXISTS drone;
CREATE TABLE drone (
	locationID decimal(1,0) NOT NULL, 
    employee_username varchar(40) NOT NULL, 
    serviceID char(10), 
    tag decimal(2,0),
    fuel decimal(3,0) NOT NULL, 
    capacity decimal(2,0) NOT NULL, 
    sale decimal(3,0) NOT NULL, 
    primary key (serviceID, tag), 
    constraint drone_location foreign key (locationID) references location(locationID), 
    constraint drone_pilot foreign key (employee_username) references pilot(employee_username), 
    constraint drone_service foreign key (serviceID) references service(id)
);

-- Table structure for table worker
DROP TABLE IF EXISTS worker;
CREATE TABLE worker (
	worker_username varchar(40) NOT NULL, 
    primary key (worker_username), 
    constraint worker_employee foreign key (worker_username) references employee(username)
); 


-- Table structure for table ingredient
DROP TABLE IF EXISTS ingredient;
CREATE TABLE ingredient (
	barcode varchar(20), 
    ingredient_name varchar(50),
    weight decimal(1,0), 
    primary key (barcode)
);

-- Table structure for table contain
DROP TABLE IF EXISTS contain; 
CREATE TABLE contain (
	ingredient_barcode varchar(50), 
    drone_tag decimal(2,0),
    drone_serviceID char(3),
    price decimal(2,0),
    quantity decimal(1,0),
    primary key (ingredient_barcode, drone_tag, drone_serviceID),
    constraint contain_ingredient foreign key (ingredient_barcode) references ingredient(barcode),
    constraint contain_drone foreign key (drone_serviceID, drone_tag) references drone(serviceID, tag) 
);

-- Table structure for table work_for
DROP TABLE IF EXISTS work_for; 
CREATE TABLE work_for (
	employee_username varchar(40) NOT NULL,
    serviceID char(10),
    constraint workFor_worker foreign key (employee_username) references worker(worker_username), 
    constraint workFor_service foreign key (serviceID) references service(id),
    primary key (employee_username,  serviceID)
); 

-- Table structure for table fund
DROP TABLE IF EXISTS fund;
CREATE TABLE fund (
	owner_username varchar(40) NOT NULL, 
    restaurant_name varchar(100) NOT NULL,
    invested decimal(2,0),
    dt_made date, 
    constraint fund_owner foreign key (owner_username) references sys_owner(username), 
    constraint fund_restaurant foreign key (restaurant_name) references restaurant(res_name),
    primary key (owner_username, restaurant_name)
); 

-- Table structure for table manage
DROP TABLE IF EXISTS manage;
CREATE TABLE manage (
	employee_username varchar(40) NOT NULL, 
    serviceID char(10), 
    constraint manage_worker foreign key (employee_username) references worker(worker_username), 
    constraint manage_service foreign key (serviceID) references service(id),
    primary key (employee_username, serviceID)
);

-- END OF CREATE STATEMENTS 
-- BEGIN INSERT STATEMENTS 

-- Insert data to table sys_user
INSERT INTO sys_user
	(username, first_name, last_name, address, birthdate)
VALUES 
	('agarcia7','Alejandro','Garcia','710 Living Water Drive','1966-10-29'),
	('awilson5','Aaron','Wilson','220 Peachtree Street','1963-11-11'),
	('bsummers4','Brie','Summers','5105 Dragon Star Circle','1976-02-09'),
	('cjordan5','Clark','Jordan','77 Infinite Stars Road','1966-06-05'),
	('ckann5','Carrot','Kann','64 Knights Square Trail','1972-09-01'),
	('csoares8','Claire','Soares','706 Living Stone Way','1965-09-03'),
	('echarles19','Ella','Charles','22 Peachtree Street','1974-05-06'),
	('eross10','Erica','Ross','22 Peachtree Street','1975-04-02'),
	('fprefontaine6','Ford','Prefontaine','10 Hitch Hikers Lane','1961-01-28'),
	('hstark16','Harmon','Stark','53 Tanker Top Lane','1971-10-27'),
	('jstone5','Jared','Stone','101 Five Finger Way','1961-01-06'),
	('lrodriguez5','Lina','Rodriguez','360 Corkscrew Circle','1975-04-02'),
	('mrobot1','Mister','Robot','10 Autonomy Trace','1988-11-02'),
	('mrobot2','Mister','Robot','10 Clone Me Circle','1988-11-02'),
	('rlopez6','Radish','Lopez','8 Queens Route','1999-09-03'),
	('sprince6','Sarah','Prince','22 Peachtree Street','1968-06-15'),
	('tmccall5','Trey','McCall','360 Corkscrew Circle','1973-03-19');
  
-- Insert data to table employee
INSERT INTO employee
	(username, taxID, hired, salary, experience)
VALUES 
	('agarcia7',999-99-9999,'2019-03-17',41000,24),
	('awilson5',111-11-1111,'2020-03-15',46000,9),
	('bsummers4',000-00-0000,'2018-12-06',35000,17),
	('cjordan5',NULL,NULL,NULL,NULL),
	('ckann5',640-81-2357,'2019-08-03',46000,27),
	('csoares8',888-88-8888,'2019-02-25',57000,26),
	('echarles19',777-77-7777,'2021-01-02',27000,3),
	('eross10',444-44-4444,'2020-04-17',61000,10),
	('fprefontaine6',121-21-2121,'2020-04-19',20000,5),
	('hstark16',555-55-5555,'2018-07-23',59000,20),
	('jstone5',NULL,NULL,NULL,NULL),
	('lrodriguez5',222-22-2222,'2019-04-15',58000,20),
	('mrobot1',101-01-0101,'2015-05-27',38000,8),
	('mrobot2',010-10-1010,'2015-05-27',38000,8),
	('rlopez6',123-58-1321,'2017-02-05',64000,51),
	('sprince6',NULL,NULL,NULL,NULL),
	('tmccall5',333-33-3333,'2018-10-17',33000,29);


-- Insert data to table sys_owner
INSERT INTO sys_owner
	(username)
VALUES 
	('agarcia7'),
	('awilson5'),
	('bsummers4'),
	('cjordan5'),
	('ckann5'),
	('csoares8'),
	('echarles19'),
	('eross10'),
	('fprefontaine6'),
	('hstark16'),
	('jstone5'),
	('lrodriguez5'),
	('mrobot1'),
	('mrobot2'),
	('rlopez6'),
	('sprince6'),
	('tmccall5');
    
-- Insert data to table location
INSERT INTO location
	(label, x_coord, y_coord, space, locationID)
VALUES 
	('airport', 5, -6, 15, 1),
    ('avalon', 2, 15, NULL, 2),
    ('buckhead', 7, 10, 8, 3),
    ('highpoint', 11, 3, 4, 4),
    ('mercedes', -8, 5, NULL, 5),
    ('midtown', 2, 1, 7, 6),
    ('plaza', -4, -3, 10, 7),
    ('southside', 1, -16, 5, 8);
    
-- Insert data to table restaurant
INSERT INTO restaurant
	(res_name, spent, rating, locationID)
VALUES 
	('Bishoku',10,5,7),
	('Casi Cielo',30,5,7),
	('Ecco',0,3,3),
	('Fogo de Chao',30,4,3),
	('Hearth',0,4,2),
	('Il Giallo',10,4,5),
	('Lure',20,5,6),
	('Micks',0,2,8),
	('South City Kitchen',30,5,6),
	('Tre Vele',10,4,7);
    

-- Insert data to table service
INSERT INTO service
	(id, service_name, locationID)
VALUES     
	('hf','Herban Feast', 8),
	('osf','On Safari Foods', 8),
	('rr','Ravishing Radish', 2);
    
-- Insert data to table pilot
INSERT INTO pilot
	(employee_username, license_type, experience)
VALUES  
	('agarcia7',610623,38),
	('awilson5',314159,41),
	('bsummers4',411911,35),
	('csoares8',343563,7),
	('echarles19',236001,10),
	('fprefontaine6',657483,2),
	('lrodriguez5',287182,67),
	('mrobot1',101010,18),
	('rlopez6',235711,58),
	('tmccall5',181633,10);
    
-- Insert data to table drone 
INSERT INTO drone
	(locationID, employee_username, serviceID, tag, fuel, capacity, sale)
VALUES
	(8, 'fprefontaine6','hf',1,100,6,0),
	(8, 'fprefontaine6','hf',5,27,7,100),
	(8, 'bsummers4','hf',8,100,8,0),
	(8, 'fprefontaine6','hf',16,17,5,40),
	(8, 'awilson5','osf',1,100,9,0),
	(2, 'agarcia7','rr',3,100,5,50),
	(2, 'agarcia7','rr',7,53,5,100),
	(2, 'agarcia7','rr',8,100,6,0); 

-- Insert data to table worker
INSERT INTO worker
	(worker_username)
VALUES  
	('ckann5'),
	('csoares8'),
	('echarles19'),
	('eross10'),
	('fprefontaine6'),
	('hstark16'),
	('jstone5'),
	('lrodriguez5'),
	('mrobot1'),
	('mrobot2'),
	('rlopez6'),
	('sprince6'),
	('tmccall5');

-- Insert data to table ingredient 
INSERT INTO ingredient
	(barcode, ingredient_name, weight)
VALUES  
	('bv_4U5L7M','balsamic vinegar',4),
	('clc_4T9U25X','caviar',5),
	('ap_9T25E36L','foie gras',4),
	('pr_3C6A9R','prosciutto',6),
	('ss_2D4E6L','saffron',3),
	('hs_5E7L23M','truffles',3);

-- Insert data to table contain 
INSERT INTO contain
	(ingredient_barcode, drone_tag, drone_serviceID, price, quantity)
VALUES
	('clc_4T9U25X',3,'rr',28,2),
	('clc_4T9U25X',5,'hf',30,1),
	('pr_3C6A9R',1,'osf',20,5),
	('pr_3C6A9R',8,'hf',18,4),
	('ss_2D4E6L',1,'osf',23,3),
	('ss_2D4E6L',1,'hf',27,6),
	('hs_5E7L23M',3,'rr',15,2),
	('hs_5E7L23M',5,'hf',17,4);

-- Insert data to table work_for
INSERT INTO work_for
	(employee_username, serviceID)
VALUES  
	('ckann5','osf'),
	('echarles19','rr'),
	('eross10','osf'),
	('fprefontaine6','hf'),
	('hstark16','hf'),
    ('mrobot1', 'osf'),
    ('mrobot1', 'rr'), 
	('rlopez6','rr'),
	('tmccall5','hf');

-- Insert data to table fund
INSERT INTO fund
	(owner_username, restaurant_name, invested, dt_made)
VALUES  
	('jstone5','Ecco',20,'2022-10-25'),
	('sprince6','Il Giallo',10,'2022-03-06'),
	('jstone5','Lure',30,'2022-09-08'),
	('jstone5','South City Kitchen',5,'2022-07-25');

-- Insert data to table manage
INSERT INTO manage
	(employee_username, serviceID)
VALUES  
	('ckann5','osf'),
	('echarles19','rr'),
	('eross10','osf'),
	('fprefontaine6','hf'),
	('hstark16','hf'),
    ('mrobot1', 'osf'),
    ('mrobot1', 'rr'),
	('rlopez6','rr'),
	('tmccall5','hf');













    





 








