-- INSERTIONS
-- Ajouter une nouvelle écurie
INSERT INTO teams (name)
VALUES ('Audi F1 Team');

-- Ajouter un circuit
INSERT INTO circuits (name, country)
VALUES ('Las Vegas Street Circuit', 'USA');

-- Ajouter une course
INSERT INTO races (session_key, year, circuit_id, name, date)
VALUES (2026001, 2026, 1, 'Australian Grand Prix', '2026-03-15');

-- Ajouter un pilote
INSERT INTO drivers (driver_number, full_name, team_id, team_colour)
VALUES (99, 'Theo Martin', 1, '00D2BE');

-- Ajouter un résultat de course
INSERT INTO results (session_key, driver_number, position)
VALUES (2026001, 99, 3);

-- Ajouter un arrêt au stand
INSERT INTO pit_stops (session_key, driver_number, lap_number, duration)
VALUES (2026001, 99, 22, 2.45);


-- MISES À JOUR
-- Mettre à jour l’écurie d’un pilote (transfert)
UPDATE drivers
SET team_id = (SELECT team_id FROM teams WHERE name = 'Audi F1 Team')
WHERE driver_number = 99;

-- Modifier la position finale après pénalité
UPDATE results
SET position = position + 1
WHERE session_key = 2026001 AND driver_number = 99;

-- Recalculer les points après modification
UPDATE results
SET points = CASE 
    WHEN position = 1 THEN 25
    WHEN position = 2 THEN 18
    WHEN position = 3 THEN 15
    WHEN position = 4 THEN 12
    WHEN position = 5 THEN 10
    WHEN position = 6 THEN 8
    WHEN position = 7 THEN 6
    WHEN position = 8 THEN 4
    WHEN position = 9 THEN 2
    WHEN position = 10 THEN 1
    ELSE 0
END
WHERE session_key = 2026001;


-- SUPPRESSIONS
-- Supprimer une pénalité
DELETE FROM penalties
WHERE driver_number = 99 AND session_key = 2026001;
