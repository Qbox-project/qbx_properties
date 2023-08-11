CREATE TABLE IF NOT EXISTS `properties` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`name` VARCHAR(255) NOT NULL,
	`interior` VARCHAR(255) NOT NULL,
	`property_type` ENUM('shell', 'ipl', 'garage') NOT NULL,
	`coords` JSON NOT NULL,
	`price` INT NOT NULL,
	`rent` INT NOT NULL,
	`rent_expiration` TIMESTAMP DEFAULT NULL,
	`stash` JSON,
	`outfit` JSON,
	`logout` JSON,
	`decorationsid` INT,
	`appliedtaxes` JSON,
	`maxweight` INT,
	`slots` INT,
	`garage_slots` JSON,
	PRIMARY KEY (id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS `property_owners` (
	`property_id` INT NOT NULL,
	`citizenid` VARCHAR(50) NOT NULL, /* CHANGE WHEN DB REFACTOR GOES THROUGH (cmon illenium it's time) */
	`role` ENUM('owner', 'co_owner', 'tenant') NOT NULL,
	PRIMARY KEY (property_id, citizenid),
	FOREIGN KEY (property_id) REFERENCES `properties` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
	FOREIGN KEY (citizenid) REFERENCES `players` (`citizenid`) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS `property_decorations` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`name` VARCHAR(255) NOT NULL,
	`price` INT NOT NULL,
	`decorations` JSON NOT NULL,
	PRIMARY KEY (`id`)
);