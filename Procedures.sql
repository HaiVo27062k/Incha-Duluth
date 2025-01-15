/*ADD new figure
Req: 
+ ID (unique)  
+ Details
+ Price (Int)
+ Quantity (Int)
+ Quantity Sold (Int)
*/
Use Figure_Database;
drop procedure if exists create_new_figure;
delimiter //
create procedure create_new_figure (in ip_figure_id varchar(3),
							in ip_Details VARCHAR (100),
                            in ip_Price  INT,
                            in ip_Quantity INT,
                            in ip_Quantity_Sold INT)
sp_main: begin
    -- ensure new figure has a unique ID
    if (ip_figure_id in (select figure_id from figure_general))  
	then leave sp_main; end if;
    -- Adding the new figure
    insert into figure_general(figure_id, details, Price, Quantity, Quantity_Sold) values (ip_figure_id, ip_Details, ip_Price, ip_Quantity, ip_Quantity_Sold);
end //
delimiter ;


/*SELL figure
Req: 
+ ID (unique)  
+ Quantity (Int)
*/
drop procedure if exists sell_figure;
delimiter //
create procedure sell_figure (in ip_figure_id varchar(3),
                            in ip_Quantity INT)
sp_main: begin
    DECLARE currTime DATETIME; -- Declare a variable to store the current datetime
	DECLARE ip_price INT; -- Declare a variable to store the current datetime
    
    SET currTime = NOW();      -- Assign the current datetime to the variable
	SELECT Price INTO ip_price FROM figure_general WHERE figure_id = ip_figure_id;
    
    -- ENSURE THAT WE HAVE THAT FIGURE TO SELL
    -- NEED TO CHECK FOR DECIMAL
    if (ip_figure_id NOT IN (select figure_id from figure_general)) OR
		(ip_quantity < 0) 
	then leave sp_main; end if;
    
    -- SUBTRACT the number of figure
    UPDATE figure_general
    SET Quantity = Quantity - ip_Quantity
    WHERE figure_id = ip_figure_id;
    
    -- ADDING To quantity sold
    UPDATE figure_general
    SET quantity_sold = quantity_sold + ip_Quantity
    WHERE figure_id = ip_figure_id;
    
    -- Update sale to accounting table
    insert into figure_accounting(figure_id, Price, Quantity_Changed, Date_Changed) values (ip_figure_id, ip_Price, ip_Quantity, currTime);
end //
delimiter ;


/*RESTOCK figure
Req: 
+ ID (unique)  
+ Quantity (Int)
*/
drop procedure if exists restock_figure;
delimiter //
create procedure restock_figure (in ip_figure_id varchar(3),
                            in ip_Quantity INT,
                            in u_action TEXT
                            )
sp_main: begin
    -- NEED TO CHECK FOR DECIMAL
    if (ip_figure_id NOT IN (select figure_id from figure_general)) OR
		(ip_quantity < 0) 
	then leave sp_main; end if;
    
    if u_action = 'add' then
		-- ADD the number of figure
		UPDATE figure_general
		SET Quantity = Quantity + ip_Quantity
		WHERE figure_id = ip_figure_id;
    
    ELSEIF u_action = 'update' then
		-- UPDATE the number of figure
		UPDATE figure_general
		SET Quantity = ip_Quantity
		WHERE figure_id = ip_figure_id;
	end if;
end //
delimiter ;

/*SEARCH figure
Req: 
+ ID (unique)  
*/
drop procedure if exists search_figure;
delimiter //
create procedure search_figure (in ip_figure_id varchar(3))
sp_main: begin
    -- ENSURE THAT WE HAVE THAT FIGURE TO SEARCH
    if (ip_figure_id NOT IN (select figure_id from figure_general))
	then leave sp_main; end if;
	SELECT * from figure_database.figure_general WHERE figure_id = ip.figure_id;
end //
delimiter //

