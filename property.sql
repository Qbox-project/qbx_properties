CREATE TABLE IF NOT EXISTS `properties` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`name` VARCHAR(255) NOT NULL,
	`interior` VARCHAR(255) NOT NULL,
	`furnished` BOOLEAN NOT NULL,
	`garage` BOOLEAN NOT NULL,
	`coords` JSON NOT NULL,
	`price` INT NOT NULL,
	`rent` INT NOT NULL,
	`rent_date` TIMESTAMP DEFAULT NULL,
	`stash` JSON,
	`outfit` JSON,
	`logout` JSOn,
	`decorationsid` INT,
	`appliedtaxes` JSON,
	`maxweight` INT,
	`slots` INT,
	`garage_slots` JSON,
	PRIMARY KEY (id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS `property_owners` (
	`property_id` INT NOT NULL,
	`citizenid` INT NOT NULL,
	`owner` BOOLEAN,
	`co_owner` BOOLEAN,
	`tenant` BOOLEAN,
	PRIMARY KEY (property_id, citizenid) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS `property_decorations` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`name` varchar(255) NOT NULL,
	`price` int(12) NOT NULL,
	`decorations` JSON NOT NULL,
	PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;