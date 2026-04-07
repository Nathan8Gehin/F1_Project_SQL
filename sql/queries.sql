
-- INSERTIONS : Ajouter de nouvelles données


-- Ajouter une nouvelle écurie 
INSERT INTO teams (name, nationality, base_city)
VALUES ('Audi F1 Team', 'Germany', 'Neuburg');

-- Ajouter un circuit 
INSERT INTO circuits (name, location, country, length_km)
VALUES ('Las Vegas Street Circuit', 'Las Vegas', 'USA', 6.12);

-- Ajouter une course 
INSERT INTO races (session_key, year, round, circuit_id, name, date)
VALUES (2026001, 2026, 1, 1, 'Australian Grand Prix', '2026-03-15');

-- Ajouter un pilote 
INSERT INTO drivers (driver_id, first_name, last_name, full_name, code, nationality, team_id)
VALUES (99, 'Theo', 'Martin', 'Theo Martin', 'MAR', 'French', 1);

-- Ajouter un résultat de course 
INSERT INTO results (session_key, driver_id, team_id, grid_position, final_position, points, status)
VALUES (2026001, 99, 1, 5, 3, 15, 'Finished');

-- Ajouter un arrêt au stand 
INSERT INTO pit_stops (session_key, driver_id, lap, duration_seconds)
VALUES (2026001, 99, 22, 2.45);

-- Ajouter une pénalité 
INSERT INTO penalties (session_key, driver_id, infraction, seconds_added, is_served)
VALUES (2026001, 99, 'Track limits', 5, 1);


-- MISES À JOUR : Modifier des données existantes
 

-- Mettre à jour l’écurie d’un pilote (transfert) 
UPDATE drivers
SET team_id = 2
WHERE driver_id = 99;

-- Modifier la position finale après pénalité 
UPDATE results
SET final_position = final_position + 1
WHERE session_key = 2026001 AND driver_id = 99;

-- Recalculer les points après modification 
UPDATE results
SET points = CASE 
    WHEN final_position = 1 THEN 25
    WHEN final_position = 2 THEN 18
    WHEN final_position = 3 THEN 15
    WHEN final_position = 4 THEN 12
    WHEN final_position = 5 THEN 10
    WHEN final_position = 6 THEN 8
    WHEN final_position = 7 THEN 6
    WHEN final_position = 8 THEN 4
    WHEN final_position = 9 THEN 2
    WHEN final_position = 10 THEN 1
    ELSE 0
END
WHERE session_key = 2026001;

-- Marquer une pénalité comme non servie 
UPDATE penalties
SET is_served = 0
WHERE driver_id = 99 AND session_key = 2026001;

-- SUPPRESSIONS : Retirer des données
 

-- Supprimer une pénalité 
DELETE FROM penalties
WHERE driver_id = 99 AND session_key = 2026001;

-- Supprimer un arrêt au stand erroné 
DELETE FROM pit_stops
WHERE driver_id = 99 AND session_key = 2026001 AND lap = 22;

-- Supprimer un résultat (ex : disqualification complète) 
DELETE FROM results
WHERE driver_id = 99 AND session_key = 2026001;

-- Supprimer un pilote 
DELETE FROM drivers
WHERE driver_id = 99;

-- Supprimer une écurie (si plus utilisée) 
DELETE FROM teams
WHERE name = 'Audi F1 Team';
