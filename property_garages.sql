ALTER TABLE `properties` ADD COLUMN IF NOT EXISTS `garage` JSON DEFAULT NULL AFTER `stash_options`;