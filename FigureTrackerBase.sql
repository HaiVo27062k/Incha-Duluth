# Create the Figure_Database
CREATE DATABASE IF NOT EXISTS Figure_Database;

# Points to the Figure_Database
Use Figure_Database;

# Create the table Figure_General
CREATE TABLE IF NOT EXISTS Figure_General (
	figure_id VARCHAR(3),
    Details VARCHAR (100),
    Price  INT,
    Quantity INT,
    Quantity_Sold INT,
    PRIMARY KEY (figure_id)
);

# Create the table Figure_General
CREATE TABLE IF NOT EXISTS Figure_Accounting (
	figure_id VARCHAR(3),
    Price INT,
    Quantity_Changed INT,
    Date_Changed TIMESTAMP
);