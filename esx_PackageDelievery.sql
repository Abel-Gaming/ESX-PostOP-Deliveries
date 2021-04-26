USE `es_extended`;

INSERT INTO `jobs` (name, label) VALUES
	('delivery', 'Delivery')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('delivery', 0, 'driver', 'Driver', 50, '{}', '{}')
;

INSERT INTO `items` (name, label, weight, rare, can_remove) VALUES
    ('package', 'Package', 1, 0, 1)
;