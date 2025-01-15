-- CS4400: Introduction to Database Systems (Fall 2022)
-- Project Phase III: Stored Procedures SHELL [v2] Wednesday, November 30, 2022
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;

use restaurant_supply_express;
-- -----------------------------------------------------------------------------
-- stored procedures and views
-- -----------------------------------------------------------------------------
/* Standard Procedure: If one or more of the necessary conditions for a procedure to
be executed is false, then simply have the procedure halt execution without changing
the database state. Do NOT display any error messages, etc. */

-- [1] add_owner()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new owner.  A new owner must have a unique
username.  Also, the new owner is not allowed to be an employee. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_owner;
delimiter //
create procedure add_owner (in ip_username varchar(40), in ip_first_name varchar(100),
	in ip_last_name varchar(100), in ip_address varchar(500), in ip_birthdate date)
sp_main: begin
     -- ensure new owner has a unique username
	if (ip_username in (select username from restaurant_owners))  
    then leave sp_main; end if;
	insert into users (username, first_name, last_name, address, birthdate) values (ip_username, ip_first_name, ip_last_name, ip_address, ip_birthdate); 
    insert into restaurant_owners (username) values (ip_username);
end //
delimiter ;

-- [2] add_employee()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new employee without any designated pilot or
worker roles.  A new employee must have a unique username unique tax identifier. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_employee;
delimiter //
create procedure add_employee (in ip_username varchar(40), in ip_first_name varchar(100),
	in ip_last_name varchar(100), in ip_address varchar(500), in ip_birthdate date,
    in ip_taxID varchar(40), in ip_hired date, in ip_employee_experience integer,
    in ip_salary integer)
sp_main: begin
    -- ensure new owner has a unique username
    -- ensure new employee has a unique tax identifier
    if (((ip_username) in (select username from employees)) 
    OR ((ip_taxID) in (select taxID from employees)))
    then leave sp_main; end if; 
    insert into users (username, first_name, last_name, address, birthdate) values (ip_username, ip_first_name, ip_last_name, ip_address, ip_birthdate); 
    insert into employees (username, taxID, hired, experience, salary) values (ip_username, ip_taxID, ip_hired, ip_employee_experience, ip_salary);
end //
delimiter ;

-- [3] add_pilot_role()
-- -----------------------------------------------------------------------------
/* This stored procedure adds the pilot role to an existing employee.  The
employee/new pilot must have a unique license identifier. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_pilot_role;
delimiter //
create procedure add_pilot_role (in ip_username varchar(40), in ip_licenseID varchar(40),
	in ip_pilot_experience integer)
sp_main: begin
     -- ensure new employee exists
    -- ensure new pilot has a unique license identifier
    
    if (((ip_username) not in (select username from employees)) 
    or ((ip_licenseID) in (select licenseID from pilots)))
    then leave sp_main; end if; 
    insert into pilots (username, licenseID, experience) values (ip_username, ip_licenseID, ip_pilot_experience);
end //
delimiter ;

-- [4] add_worker_role()
-- -----------------------------------------------------------------------------
/* This stored procedure adds the worker role to an existing employee. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_worker_role;
delimiter //
create procedure add_worker_role (in ip_username varchar(40))
sp_main: begin
    -- ensure new employee exists
    if ((ip_username) in (select username from employees)) 
    then
    insert into workers (username) values (ip_username); 
    end if;
end //
delimiter ;

-- [5] add_ingredient()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new ingredient.  A new ingredient must have a
unique barcode. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_ingredient;
delimiter //
create procedure add_ingredient (in ip_barcode varchar(40), in ip_iname varchar(100),
	in ip_weight integer)
sp_main: begin
	-- ensure new ingredient doesn't already exist
    if (ip_barcode not in (select barcode from ingredients))
	then 
	insert into ingredients (barcode, iname, weight) values (ip_barcode, ip_iname, ip_weight); 
	end if;
end //
delimiter ;

-- [6] add_drone()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new drone.  A new drone must be assigned 
to a valid delivery service and must have a unique tag.  Also, it must be flown
by a valid pilot initially (i.e., pilot works for the same service), but the pilot
can switch the drone to working as part of a swarm later. And the drone's starting
location will always be the delivery service's home base by default. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_drone;
delimiter //
create procedure add_drone (in ip_id varchar(40), in ip_tag integer, in ip_fuel integer,
	in ip_capacity integer, in ip_sales integer, in ip_flown_by varchar(40))
sp_main: begin
	-- ensure new drone doesn't already exist
    -- ensure that the delivery service exists
    -- ensure that a valid pilot will control the drone
    
	if ((exists (select * from drones where id = ip_id and tag = ip_tag)) 
    OR (ip_id not in (select id from delivery_services)) 
	OR (ip_flown_by not in (select username from pilots)))
    then leave sp_main; end if; 
    
	set @homeLoc = (select home_base from delivery_services where ip_id = id); 
    insert into drones (id, tag, fuel, capacity, sales, flown_by, hover) values (ip_id, ip_tag, ip_fuel, ip_capacity, ip_sales, ip_flown_by, @homeLoc); 
end //
delimiter ;

-- [7] add_restaurant()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new restaurant.  A new restaurant must have a
unique (long) name and must exist at a valid location, and have a valid rating.
And a resturant is initially "independent" (i.e., no owner), but will be assigned
an owner later for funding purposes. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_restaurant;
delimiter //
create procedure add_restaurant (in ip_long_name varchar(40), in ip_rating integer,
	in ip_spent integer, in ip_location varchar(40))
sp_main: begin
	-- ensure new restaurant doesn't already exist
    -- ensure that the location is valid
    -- ensure that the rating is valid (i.e., between 1 and 5 inclusively)
    
    if (((ip_long_name) not in (select long_name from restaurants)) 
    and ((ip_location) in (select label from locations)) 
    and (ip_rating >= 1 and ip_rating <= 5))
    then 
    insert into restaurants (long_name, rating, spent, location) values (ip_long_name, ip_rating, ip_spent, ip_location);
    end if;
end //
delimiter ;

-- [8] add_service()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new delivery service.  A new service must have
a unique identifier, along with a valid home base and manager. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_service;
delimiter //
create procedure add_service (in ip_id varchar(40), in ip_long_name varchar(100),
	in ip_home_base varchar(40), in ip_manager varchar(40))
sp_main: begin
	-- ensure new delivery service doesn't already exist
    -- ensure that the home base location is valid
    -- ensure that the manager is valid
    
    if ((ip_id not in (select id from delivery_services)) 
    and (ip_home_base in (select label from locations))
    and (ip_manager in (select username from workers)))
    then
    insert into delivery_services (id, long_name, home_base, manager) values (ip_id, ip_long_name, ip_home_base, ip_manager); 
    end if;
end //
delimiter ;

-- [9] add_location()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new location that becomes a new valid drone
destination.  A new location must have a unique combination of coordinates.  We
could allow for "aliased locations", but this might cause more confusion that
it's worth for our relatively simple system. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_location;
delimiter //
create procedure add_location (in ip_label varchar(40), in ip_x_coord integer,
	in ip_y_coord integer, in ip_space integer)
sp_main: begin
	-- ensure new location doesn't already exist
    -- ensure that the coordinate combination is distinct
    
    if ((ip_label not in (select label from locations)) 
    and (not exists (select * from locations where x_coord = ip_x_coord and y_coord = ip_y_coord))) 
    then 
    insert into locations (label, x_coord, y_coord, space) values (ip_label, ip_x_coord, ip_y_coord, ip_space);
    end if;
end //
delimiter ;

-- [10] start_funding()
-- -----------------------------------------------------------------------------
/* This stored procedure opens a channel for a restaurant owner to provide funds
to a restaurant. If a different owner is already providing funds, then the current
owner is replaced with the new owner.  The owner and restaurant must be valid. */
-- -----------------------------------------------------------------------------
drop procedure if exists start_funding;
delimiter //
create procedure start_funding (in ip_owner varchar(40), in ip_long_name varchar(40))
sp_main: begin
	-- ensure the owner and restaurant are valid
    if ((ip_long_name not in (select long_name from restaurants))
	or (ip_owner not in (select username from restaurant_owners)))
	then leave sp_main;
	end if; 

	update restaurants 
	set funded_by = ip_owner
	where long_name = ip_long_name;
end //
delimiter ;

-- [11] hire_employee()
-- -----------------------------------------------------------------------------
/* This stored procedure hires an employee to work for a delivery service.
Employees can be combinations of workers and pilots. If an employee is actively
controlling drones or serving as manager for a different service, then they are
not eligible to be hired.  Otherwise, the hiring is permitted. */
-- -----------------------------------------------------------------------------
drop procedure if exists hire_employee;
delimiter //
create procedure hire_employee (in ip_username varchar(40), in ip_id varchar(40))
sp_main: begin
	-- ensure that the employee hasn't already been hired
	-- ensure that the employee and delivery service are valid
    -- ensure that the employee isn't a manager for another service
	-- ensure that the employee isn't actively controlling drones for another service
    
    if ((ip_username in (select username from work_for))
	or (ip_username not in (select username from employees)) 
	or (ip_id not in (select id from delivery_services)) 
	or (ip_username in (select manager from delivery_services))
	or (ip_username in (select flown_by from drones)))
	then leave sp_main; end if; 
	insert into work_for (username, id) values (ip_username, ip_id);
end //
delimiter ;

-- [12] fire_employee()
-- -----------------------------------------------------------------------------
/* This stored procedure fires an employee who is currently working for a delivery
service.  The only restrictions are that the employee must not be: [1] actively
controlling one or more drones; or, [2] serving as a manager for the service.
Otherwise, the firing is permitted. */
-- -----------------------------------------------------------------------------
drop procedure if exists fire_employee;
delimiter //
create procedure fire_employee (in ip_username varchar(40), in ip_id varchar(40))
sp_main: begin
	-- ensure that the employee is currently working for the service
    -- ensure that the employee isn't an active manager
	-- ensure that the employee isn't controlling any drones
    
    if ((ip_username not in (select username from work_for))
	or (ip_username in (select manager from delivery_services))
	or (ip_username in (select flown_by from drones)))
	then leave sp_main; end if; 

	delete from work_for 
	where username = ip_username and id = ip_id;
end //
delimiter ;

-- [13] manage_service()
-- -----------------------------------------------------------------------------
/* This stored procedure appoints an employee who is currently hired by a delivery
service as the new manager for that service.  The only restrictions are that: [1]
the employee must not be working for any other delivery service; and, [2] the
employee can't be flying drones at the time.  Otherwise, the appointment to manager
is permitted.  The current manager is simply replaced.  And the employee must be
granted the worker role if they don't have it already. */
-- -----------------------------------------------------------------------------
drop procedure if exists manage_service;
delimiter //
create procedure manage_service (in ip_username varchar(40), in ip_id varchar(40))
sp_main: begin
	-- ensure that the employee is currently working for the service
	-- ensure that the employee is not flying any drones
    -- ensure that the employee isn't working for any other services
    -- add the worker role if necessary
    
    if (((ip_username not in (select username from work_for where id = ip_id))
	or (ip_username in (select flown_by from drones)))
	or (ip_username in (select username from work_for where id <> ip_id)))
	then leave sp_main; end if; 
	update delivery_services 
	set manager = ip_username
	where id = ip_id; 
	if (ip_username not in (select username from work_for))
	then 
	insert into work_for (username, id) values (ip_username, ip_id);
    end if;
end //
delimiter ;

-- [14] takeover_drone()
-- -----------------------------------------------------------------------------
/* This stored procedure allows a valid pilot to take control of a lead drone owned
by the same delivery service, whether it's a "lone drone" or the leader of a swarm.
The current controller of the drone is simply relieved of those duties. And this
should only be executed if a "leader drone" is selected. */
-- -----------------------------------------------------------------------------
drop procedure if exists takeover_drone;
delimiter //
create procedure takeover_drone (in ip_username varchar(40), in ip_id varchar(40),
	in ip_tag integer)
sp_main: begin
	-- ensure that the employee is currently working for the service
	-- ensure that the selected drone is owned by the same service and is a leader and not follower
	-- ensure that the employee isn't a manager
    -- ensure that the employee is a valid pilot
    if ((ip_username not in (select username from work_for where id = ip_id))
	or (ip_id <> (select id from work_for where username = ip_username))
	or ((ip_id <> (select swarm_id from drones where id = ip_id and tag = ip_tag)))
	or (ip_username in (select manager from delivery_services))
	or (ip_username not in (select username from pilots)))
	then leave sp_main; end if; 
	update drones 
	set flown_by = ip_username 
	where id = ip_id and tag = ip_tag;
end //
delimiter ;

-- [15] join_swarm()
-- -----------------------------------------------------------------------------
/* This stored procedure takes a drone that is currently being directly controlled
by a pilot and has it join a swarm (i.e., group of drones) led by a different
directly controlled drone. A drone that is joining a swarm connot be leading a
different swarm at this time.  Also, the drones must be at the same location, but
they can be controlled by different pilots. */
-- -----------------------------------------------------------------------------
drop procedure if exists join_swarm;
delimiter //
create procedure join_swarm (in ip_id varchar(40), in ip_tag integer,
	in ip_swarm_leader_tag integer)
sp_main: begin
	-- ensure that the swarm leader is a different drone
	-- ensure that the drone joining the swarm is valid and owned by the service
    -- ensure that the drone joining the swarm is not already leading a swarm
	-- ensure that the swarm leader drone is directly controlled
	-- ensure that the drones are at the same location
   if ((ip_tag) != (select tag from drones where swarm_id = ip_swarm_leader_tag))
	 and ((select swarm_tag from drones where id = ip_id and tag = ip_tag) is null)
	 and ((select swarm_id from drones where id = ip_id and tag = ip_tag) is null)
     and ((select flown_by from drones where id = ip_id and tag = ip_tag) is not null)
     and ((ip_id, ip_tag) in (select id, tag from drones))
     and ((ip_id) in (select id from delivery_services))
	 and ((select swarm_tag from drones where id = ip_id and tag = ip_tag) <> ip_tag)
     and ((select flown_by from drones where tag = ip_swarm_leader_tag and id = ip_id) is not null)
     and ((select hover from drones where id = ip_id and tag = ip_tag) = (select hover from drones where id = ip_id and tag = ip_swarm_leader_tag))
	 then
		if ((select swarm_tag from drones where id = ip_id and tag = ip_swarm_leader_tag) is null)
		and ((select swarm_id from drones where id = ip_id and tag = ip_swarm_leader_tag) is null)
		then 
			update drones
			set swarm_id = ip_id, swarm_tag = ip_swarm_leader_tag
			where id = ip_id and tag = ip_swarm_leader_tag;
		end if;
		else 
			set @joining_swarm_id = (select id from drones where id = ip_id and tag = ip_swarm_leader_tag);
			set @joining_swarm_tag = (select tag from drones where id = ip_id and tag = ip_swarm_leader_tag);
			update drones
			set  swarm_id = @joining_swarm_id, swarm_tag = @joining_swarm_tag, flown_by = null
			where id = ip_id  and tag = ip_tag;
    end if;
end //
delimiter ;

-- [16] leave_swarm()
-- -----------------------------------------------------------------------------
/* This stored procedure takes a drone that is currently in a swarm and returns
it to being directly controlled by the same pilot who's controlling the swarm. */
-- -----------------------------------------------------------------------------
drop procedure if exists leave_swarm;
delimiter //
create procedure leave_swarm (in ip_id varchar(40), in ip_swarm_tag integer)
sp_main: begin
	-- ensure that the selected drone is owned by the service and flying in a swarm
--     if ((ip_id not in (select id from drones))
--     or (ip_id in (select swarm_id from drones) and ip_swarm_tag = (select swarm_tag from drones)))
--     then leave sp_main; end if;
--     update drones
--     set ip_swarm_tag = null and flown_by = (select flown_by from drones where id = ip_id);

	if (ip_id in (select id from delivery_services))
and ((select swarm_tag from drones where id = ip_id and tag = ip_swarm_tag) is not null)
and ((select swarm_id from drones where id = ip_id and tag = ip_swarm_tag) is not null)
and ((select flown_by from drones where id = ip_id and tag = ip_swarm_tag) is null)
then 
set @swarmTag = (select swarm_tag from drones where id = ip_id and tag = ip_swarm_tag); 
set @pilot = (select flown_by from drones where id = ip_id and tag = @swarmTag); 
update drones 
set flown_by = @pilot, swarm_tag = null, swarm_id = null 
where id = ip_id and tag = ip_swarm_tag; 
end if;
end //
delimiter ;

-- [17] load_drone()
-- -----------------------------------------------------------------------------
/* This stored procedure allows us to add some quantity of fixed-size packages of
a specific ingredient to a drone's payload so that we can sell them for some
specific price to other restaurants.  The drone can only be loaded if it's located
at its delivery service's home base, and the drone must have enough capacity to
carry the increased number of items.

The change/delta quantity value must be positive, and must be added to the quantity
of the ingredient already loaded onto the drone as applicable.  And if the ingredient
already exists on the drone, then the existing price must not be changed. */
-- -----------------------------------------------------------------------------
drop procedure if exists load_drone;
delimiter //
create procedure load_drone (in ip_id varchar(40), in ip_tag integer, in ip_barcode varchar(40),
	in ip_more_packages integer, in ip_price integer)
sp_main: begin
	-- ensure that the drone being loaded is owned by the service
	-- ensure that the ingredient is valid
    -- ensure that the drone is located at the service home base
	-- ensure that the quantity of new packages is greater than zero
	-- ensure that the drone has sufficient capacity to carry the new packages
    -- add more of the ingredient to the drone
    if (ip_id in (select id from delivery_services)) 
and (ip_barcode in (select barcode from ingredients))
and ((select hover from drones where id = ip_id and tag = ip_tag) = (select home_base from delivery_services where id = ip_id))
and (ip_more_packages >= 0)
and ((select capacity from drones where id = ip_id and tag = ip_tag) >= ip_more_packages)
then 

set @oldCapcity = (select capacity from drones where id = ip_id and tag = ip_tag);  
update drones 
set capacity = @oldCapcity - ip_more_packages
where id = ip_id and tag = ip_tag; 

if (exists (select barcode from payload where id = ip_id and tag = ip_tag and barcode = ip_barcode))
then
set @oldQuant = (select quantity from payload where id = ip_id and tag = ip_tag and barcode = ip_barcode); 
update payload 
set quantity = @oldQuant - ip_more_packages
where id = ip_id and tag = ip_tag and barcode = ip_barcode; 
leave sp_main; 
end if; 

insert into payload (id, tag, barcode, quantity, price)
values (ip_id, ip_tag, ip_barcode, ip_more_packages, ip_price); 
end if;
end //
delimiter ;

-- [18] refuel_drone()
-- -----------------------------------------------------------------------------
/* This stored procedure allows us to add more fuel to a drone. The drone can only
be refueled if it's located at the delivery service's home base. */
-- -----------------------------------------------------------------------------
drop procedure if exists refuel_drone;
delimiter //
create procedure refuel_drone (in ip_id varchar(40), in ip_tag integer, in ip_more_fuel integer)
sp_main: begin
	-- ensure that the drone being switched is valid and owned by the service
    -- ensure that the drone is located at the service home base
    
    IF (ip_id, ip_tag) IN (SELECT id, tag from drones) THEN
		SET @curr_loc = (SELECT hover FROM drones WHERE id = ip_id AND tag = ip_tag);
		IF (@curr_loc IN (SELECT home_base FROM delivery_services)) THEN 
			UPDATE drones SET fuel = fuel + ip_more_fuel WHERE ip_id = id AND ip_tag = tag;
		end if;
    end if;
end //
delimiter ;

-- [19] fly_drone()
-- -----------------------------------------------------------------------------
/* This stored procedure allows us to move a single or swarm of drones to a new
location (i.e., destination). The main constraints on the drone(s) being able to
move to a new location are fuel and space.  A drone can only move to a destination
if it has enough fuel to reach the destination and still move from the destination
back to home base.  And a drone can only move to a destination if there's enough
space remaining at the destination.  For swarms, the flight directions will always
be given to the lead drone, but the swarm must always stay together. */
-- -----------------------------------------------------------------------------
drop function if exists fuel_required;
delimiter //
create function fuel_required (ip_departure varchar(40), ip_arrival varchar(40))
	returns integer reads sql data
begin
	if (ip_departure = ip_arrival) then return 0;
    else return (select 1 + truncate(sqrt(power(arrival.x_coord - departure.x_coord, 2) + power(arrival.y_coord - departure.y_coord, 2)), 0) as fuel
		from (select x_coord, y_coord from locations where label = ip_departure) as departure,
        (select x_coord, y_coord from locations where label = ip_arrival) as arrival);
	end if;
end //
delimiter ;

drop procedure if exists fly_drone;
delimiter //
create procedure fly_drone (in ip_id varchar(40), in ip_tag integer, in ip_destination varchar(40))
sp_main: begin
	-- ensure that the lead drone being flown is directly controlled and owned by the service
    -- ensure that the destination is a valid location
    -- ensure that the drone isn't already at the location
    -- ensure that the drone/swarm has enough fuel to reach the destination and (then) home base
    -- ensure that the drone/swarm has enough space at the destination for the flight
    if (ip_id in (select id from delivery_services))
    and ((select flown_by from drones where id = ip_id and tag = ip_tag) is not null)
    and ((select swarm_id from drones where id = ip_id and tag = ip_tag) is null)
    and ((select swarm_tag from drones where id = ip_id and tag = ip_tag) is null)
    and (ip_destination in (select label from locations))
    and (ip_destination not in (select hover from drones where id = ip_id and tag = ip_tag))
    then
    
		set @drones_location = (select hover from drones where id = ip_id and tag = ip_tag);
        set @home_base = (select home_base from delivery_services where id = ip_id);
		set @fuel1 = fuel_required(@drones_location, ip_destination);
		set @fuel2 = fuel_required(ip_destination, @home_base);
		set @count_drone = 1 + (select count(*) from drones where swarm_id = ip_id and swarm_tag = ip_tag);
        set @min_fuel = (select min(fuel) from drones where (swarm_id = ip_id and swarm_tag = ip_tag) or (id = ip_id and tag = ip_tag));
		if (@fuel1 + @fuel2 <= @min_fuel)
		then
			-- set @numMemn = (select count(*) from drones where swarm_id = ip_id and swarm_tag = ip_tag); 
			if ((select space from locations where label = ip_destination) >= @count_drone) 
			then
				if (@count_drone > 1)
                then
                update drones 
                set hover = ip_destination, fuel = fuel - @fuel1
                where swarm_id = ip_id and swarm_tag = ip_tag;
                update drones 
                set hover = ip_destination, fuel = fuel - @fuel1
                where id = ip_id and tag = ip_tag;
                end if;
                else
                update drones
				set hover = ip_destination, fuel = fuel - @fuel1
				where id = ip_id and tag = ip_tag;
				
				update locations 
				set space = space - @count_drone
				where label = ip_destination; 
			end if; 
		end if; 
    end if;
end //
delimiter ;

-- [20] purchase_ingredient()
-- -----------------------------------------------------------------------------
/* This stored procedure allows a restaurant to purchase ingredients from a drone
at its current location.  The drone must have the desired quantity of the ingredient
being purchased.  And the restaurant must have enough money to purchase the
ingredients.  If the transaction is otherwise valid, then the drone and restaurant
information must be changed appropriately.  Finally, we need to ensure that all
quantities in the payload table (post transaction) are greater than zero. */
-- -----------------------------------------------------------------------------
drop procedure if exists purchase_ingredient;
delimiter //
create procedure purchase_ingredient (in ip_long_name varchar(40), in ip_id varchar(40),
	in ip_tag integer, in ip_barcode varchar(40), in ip_quantity integer)
sp_main: begin
	-- ensure that the restaurant is valid
    -- ensure that the drone is valid and exists at the resturant's location
	-- ensure that the drone has enough of the requested ingredient
	-- update the drone's payload
    -- update the monies spent and gained for the drone and restaurant
    -- ensure all quantities in the payload table are greater than zero
if (ip_long_name not in (select long_name from restaurants)) 
or ((select count(*) from drones where id = ip_id and tag = ip_tag) = 0)
or ((select location from restaurants where long_name = ip_long_name) <> (select hover from drones where id = ip_id and tag = ip_tag))
or ((select quantity from payload where id = ip_id and tag = ip_tag and barcode = ip_barcode) < ip_quantity)
then leave sp_main; end if; 

set @sale = (select price from payload where id = ip_id and tag = ip_tag and barcode = ip_barcode) * ip_quantity; 
set @oldSale = (select sales from drones where id = ip_id and tag = ip_tag); 
set @oldSpent = (select spent from restaurants where long_name = ip_long_name); 
set @oldQuant = (select quantity from payload where id = ip_id and tag = ip_tag and barcode = ip_barcode); 
update drones 
set sales = @oldSale + @sale 
where id = ip_id and tag = ip_tag; 

update restaurants 
set spent = @oldSpent + @sale
where long_name = ip_long_name;

update payload 
set quantity = @oldQuant - ip_quantity
where id = ip_id and tag = ip_tag and barcode = ip_barcode; 

delete from payload 
where quantity <= 0;

end //
delimiter ;

-- [21] remove_ingredient()
-- -----------------------------------------------------------------------------
/* This stored procedure removes an ingredient from the system.  The removal can
occur if, and only if, the ingredient is not being carried by any drones. */
-- -----------------------------------------------------------------------------
drop procedure if exists remove_ingredient;
delimiter //
create procedure remove_ingredient (in ip_barcode varchar(40))
sp_main: begin
	-- ensure that the ingredient exists
    -- ensure that the ingredient is not being carried by any drones
    
     IF (ip_barcode IN (SELECT barcode from ingredients)) AND
		(ip_barcode NOT IN (SELECT barcode from payload)) THEN
		DELETE FROM ingredients where (ip_barcode = barcode);
    end if;
end //
delimiter ;

-- [22] remove_drone()
-- -----------------------------------------------------------------------------
/* This stored procedure removes a drone from the system.  The removal can
occur if, and only if, the drone is not carrying any ingredients, and if it is
not leading a swarm. */
-- -----------------------------------------------------------------------------
drop procedure if exists remove_drone;
delimiter //
create procedure remove_drone (in ip_id varchar(40), in ip_tag integer)
sp_main: begin
	-- ensure that the drone exists
    -- ensure that the drone is not carrying any ingredients
	-- ensure that the drone is not leading a swarm
    if ((ip_id not in (select id from drones)) and (ip_tag not in (select tag from drones))) 
    or ((ip_id in (select id from payload)) and (ip_tag in (select tag from payload)))
    or ((ip_id = (select swarm_id from drones where id = ip_id and tag = ip_tag)) and (ip_tag = (select swarm_tag from drones where id = ip_id and tag = ip_tag)))
    then leave sp_main; end if;
    delete from drones where id = ip_id and tag = ip_tag;
end //
delimiter ;

-- [23] remove_pilot_role()
-- -----------------------------------------------------------------------------
/* This stored procedure removes a pilot from the system.  The removal can
occur if, and only if, the pilot is not controlling any drones.  Also, if the
pilot also has a worker role, then the worker information must be maintained;
otherwise, the pilot's information must be completely removed from the system. */
-- -----------------------------------------------------------------------------
drop procedure if exists remove_pilot_role;
delimiter //
create procedure remove_pilot_role (in ip_username varchar(40))
sp_main: begin
	-- ensure that the pilot exists
    -- ensure that the pilot is not controlling any drones
    -- remove all remaining information unless the pilot is also a worker
    if ((ip_username not in (select username from pilots))
    or (ip_username in (select flown_by from drones)))
    then leave sp_main; end if; 
    if (ip_username in (select username from work_for))
    then 
    delete from pilots where username = ip_username; 
    leave sp_main; 
    end if; 
    delete from pilots where username = ip_username; 
    delete from users where username = ip_username;
end //
delimiter ;

-- [24] display_owner_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of an owner.
For each owner, it includes the owner's information, along with the number of
restaurants for which they provide funds and the number of different places where
those restaurants are located.  It also includes the highest and lowest ratings
for each of those restaurants, as well as the total amount of debt based on the
monies spent purchasing ingredients by all of those restaurants. And if an owner
doesn't fund any restaurants then display zeros for the highs, lows and debt. */
-- -----------------------------------------------------------------------------
create or replace view display_owner_view as
SELECT tmp1.username, first_name, last_name, address,
		num_restaurants,
        num_places,
        high,
        low,
        debt

FROM
(SELECT restaurant_owners.username, first_name, last_name, address
	FROM restaurant_owners
	LEFT JOIN users
	ON restaurant_owners.username = users.username
    GROUP BY restaurant_owners.username) AS tmp1

JOIN

(SELECT restaurant_owners.username, 
		count(funded_by) as num_restaurants, 
		count( DISTINCT location) as num_places, 
        COALESCE(sum(spent),0) as debt,
        COALESCE(max(rating),0) as high,
        COALESCE(min(rating),0) as low
		FROM restaurant_owners 
		LEFT OUTER JOIN restaurants
		ON restaurant_owners.username = restaurants.funded_by
		GROUP BY restaurant_owners.username
		ORDER BY restaurant_owners.username ASC) AS tmp2
        
ON tmp1.username = tmp2.username;

-- [25] display_employee_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of an employee.
For each employee, it includes the username, tax identifier, hiring date and
experience level, along with the license identifer and piloting experience (if
applicable), and a 'yes' or 'no' depending on the manager status of the employee. */
-- -----------------------------------------------------------------------------
create or replace view display_employee_view as
SELECT tmp1.username, taxID, salary, hired,
 			employee_experience,
			licenseID,
			piloting_experience,
			case When tmp_stt != tmp1.username then 'no' else 'yes' end as manager_status
FROM
 (SELECT employees.username, taxID, salary, hired,
 			employees.experience as employee_experience,
         COALESCE(pilots.licenseID,'n/a') as licenseID,
         COALESCE(pilots.experience,'n/a') as piloting_experience
		FROM employees
		LEFT JOIN pilots
		ON employees.username = pilots.username
		WHERE employees.username IS NOT NULL
		ORDER BY employees.username) as tmp1
JOIN
(SELECT employees.username,
		COALESCE(delivery_services.manager,'no') as tmp_stt
		From employees
		LEFT JOIN delivery_services
		ON employees.username = delivery_services.manager
		ORDER BY employees.username) as tmp2
        
ON tmp1.username = tmp2.username
ORDER BY tmp1.username;


-- [26] display_pilot_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of a pilot.
For each pilot, it includes the username, licenseID and piloting experience, along
with the number of drones that they are controlling. */
-- -----------------------------------------------------------------------------
create or replace view display_pilot_view as
SELECT tmp1.username,
		licenseID,
		experience,
        num_drones,
        num_locations
FROM
(SELECT username, licenseID, experience
FROM pilots
ORDER BY username) as tmp1
JOIN
(SELECT pilots.username as username,
		(case 
			when flown_by is null then 0
            when flown_by is not null and flown_by in (SELECT temp2.flown_by
        FROM
		(select drones.id as temp1_id, 
				tag, 
                swarm_id, 
                swarm_tag
			from drones
			where flown_by is null) as temp1 
		join 
		(select drones.id as temp2_id,
				tag, flown_by 
				from drones 
				where flown_by is not null) as temp2 
				on temp1.swarm_id = temp2_id and temp1.swarm_tag = temp2.tag)
            
            then count(flown_by) + 1
            
		when flown_by is not null and flown_by NOT in (SELECT temp2.flown_by
        FROM
		(select drones.id as temp1_id, 
				tag, 
                swarm_id, 
                swarm_tag
			from drones
			where flown_by is null) as temp1 
		join 
		(select drones.id as temp2_id,
				tag, flown_by 
				from drones 
				where flown_by is not null) as temp2 
				on temp1.swarm_id = temp2_id and temp1.swarm_tag = temp2.tag)
            
            then count(flown_by) end) as num_drones,  
			count( Distinct hover) as num_locations
FROM drones
RIGHT OUTER JOIN pilots
ON drones.flown_by = pilots.username
GROUP BY pilots.username
ORDER BY username) as tmp2

ON tmp1.username = tmp2.username;


-- [27] display_location_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of a location.
For each location, it includes the label, x- and y- coordinates, along with the
number of restaurants, delivery services and drones at that location. */
-- -----------------------------------------------------------------------------
create or replace view display_location_view as
	SELECT final_1.label, x_coord, y_coord,
							num_restaurants,
							num_delivery_services,
							num_drones
							FROM (SELECT tmp1.label, x_coord, y_coord,
											num_restaurants,
											num_delivery_services
										FROM (SELECT label, x_coord, y_coord,
													count(distinct long_name) as num_restaurants
													FROM locations
													LEFT JOIN restaurants
													ON locations.label = restaurants.location
													GROUP BY locations.label) as tmp1
							JOIN 
											(SELECT label,
													count(distinct long_name) as num_delivery_services
													FROM locations
													LEFT JOIN delivery_services
													ON locations.label = delivery_services.home_base
													GROUP BY locations.label) as tmp2
							ON tmp1.label = tmp2.label) as final_1
							
	JOIN 
						(SELECT label,
								count(tag) as num_drones
								FROM locations
								LEFT JOIN drones
								ON locations.label = drones.hover
								GROUP BY locations.label) as final_2
	ON final_1.label = final_2.label
    ORDER BY final_1.label;

-- [28] display_ingredient_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of the ingredients.
For each ingredient that is being carried by at least one drone, it includes a list of
the various locations where it can be purchased, along with the total number of packages
that can be purchased and the lowest and highest prices at which the ingredient is being
sold at that location. */
-- -----------------------------------------------------------------------------
create or replace view display_ingredient_view as
select temp1.iname as ingredient_name, temp2.hover as location, temp1.quantity as amount_available, temp1.price as low_price, temp1.price as high_price from
	(Select ingredients.iname, ingredients.barcode, payload.id, payload.tag, payload.quantity, payload.price
	   FROM ingredients
	   LEFT JOIN payload
	   ON ingredients.barcode = payload.barcode
	   WHERE payload.barcode is not null
	   ORDER BY iname) as temp1
join 
	(select barcode, drones.id, drones.tag, hover
		from drones 
		left join payload
		on drones.id = payload.id and drones.tag = payload.tag
		where barcode is not null
		order by barcode) as temp2
on temp1.id = temp2.id and temp1.tag = temp2.tag and temp1.barcode = temp2.barcode
order by ingredient_name asc, location asc;
-- [29] display_service_view()`
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of a delivery
service.  It includes the identifier, name, home base location and manager for the
service, along with the total sales from the drones.  It must also include the number
of unique ingredients along with the total cost and weight of those ingredients being
carried by the drones. */
-- -----------------------------------------------------------------------------
create or replace view display_service_view as
SELECT 	fn1.id, long_name, home_base, manager,
		revenue,
        ingredients_carried,
		fn2.cost_carried,
		fn2.weight_carried
FROM
(SELECT delivery_services.id as id, long_name, home_base, manager,
		sum(sales) as revenue
		FROM delivery_services
		LEFT OUTER JOIN drones
		ON delivery_services.id = drones.id
		GROUP BY delivery_services.id) as fn1

JOIN

(SELECT tmp1.id, cost_carried, weight_carried, ingredients_carried
 FROM
-- THIS IS FOR THE COST CARRIED       
		(SELECT payload.id as id,
				count(distinct barcode) as ingredients_carried,
				sum(payload.quantity * payload.price) as cost_carried 
				FROM payload
				GROUP BY payload.id) as tmp1
		JOIN 

-- THIS IS WEIGHT CARRIED
		(SELECT payload.id,
				sum(ingredients.weight * payload.quantity) as weight_carried
				FROM payload
				LEFT JOIN ingredients
				ON payload.barcode = ingredients.barcode
				GROUP BY payload.id) as tmp2
ON tmp1.id = tmp2.id 
) as fn2	
ON fn1.id = fn2.id;