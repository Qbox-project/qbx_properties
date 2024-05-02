CREATE TABLE IF NOT EXISTS `properties` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`property_name` VARCHAR(255) NOT NULL, /* simple label that can be used to identify which property it is. I.e. used for spawn list */
	`coords` JSON NOT NULL, /* vec3 world coords for the entry position */
	`price` INT NOT NULL DEFAULT 0,
	`owner` VARCHAR(255), /* citizen ID of the owner */
	`interior` VARCHAR(255) NOT NULL, /* the interior name, can range from IPL name to a shell hash that needs to spawn in */
	`keyholders` JSON NOT NULL DEFAULT (JSON_OBJECT()), /* citizen IDs of other people that have access */
	`rent_interval` INT DEFAULT NULL, /* the rent interval in hours */
	`interact_options` JSON NOT NULL DEFAULT (JSON_OBJECT()), /* clothing and exit points */
	`stash_options` JSON NOT NULL DEFAULT (JSON_OBJECT()), /* multiple stash support */
	`decorations` JSON NOT NULL DEFAULT (JSON_OBJECT()), /* the model name with its corresponding coords that needs to be placed */
	FOREIGN KEY (owner) REFERENCES `players` (`citizenid`),
	PRIMARY KEY (id)
);
