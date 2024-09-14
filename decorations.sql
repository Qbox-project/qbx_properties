CREATE TABLE IF NOT EXISTS `qbx_properties_decorations` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `property_id` INT NOT NULL,
    `model` VARCHAR(255) NOT NULL,
    `coords` JSON NOT NULL,
    `rotation` JSON NOT NULL,
    FOREIGN KEY (property_id) REFERENCES `qbx_properties` (`id`) ON DELETE CASCADE,
    PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;