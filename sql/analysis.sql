-- ANALYSE 1 : Top 5 des pilotes avec le plus de podiums
-- Objectif : identifier les pilotes les plus réguliers


SELECT 
    d.full_name AS Driver,
    COUNT(*) AS Podiums
FROM drivers d
JOIN results r ON d.driver_id = r.driver_id
WHERE r.final_position <= 3
GROUP BY d.driver_id, d.full_name
ORDER BY Podiums DESC
LIMIT 5;


-- ANALYSE 2: Top 5 Pilotes les plus pénalisés
-- Objectif : identifier les pilotes à risque


SELECT 
    d.full_name AS Driver,
    t.name AS Team,
    COUNT(p.penalty_id) AS Total_Penalties
FROM drivers d
JOIN penalties p ON d.driver_id = p.driver_id
JOIN teams t ON d.team_id = t.team_id
GROUP BY d.driver_id, d.full_name, t.name
ORDER BY Total_Penalties DESC
LIMIT 5;


-- ANALYSE 3: Top 5 courses avec le plus de  pénalisés
-- Objectif : identifier les courses à risque

SELECT r.session_key, COUNT(*) AS nb_penalties
FROM temp_penalties_2024 p
JOIN temp_races_2024 r
    ON p.session_key = r.session_key
GROUP BY r.session_key
ORDER BY nb_penalties DESC
LIMIT 5;


-- Analyse 4: TOP 5 des meilleurs pit stops par pilote (meilleur temps uniquement)

SELECT 
    d.full_name AS Driver,
    t.name AS Team,
    MIN(p.duration_seconds) AS Best_Pit_Stop
FROM pit_stops p
JOIN drivers d ON p.driver_id = d.driver_id
JOIN results r ON p.session_key = r.session_key AND p.driver_id = r.driver_id
JOIN teams t ON r.team_id = t.team_id
WHERE p.duration_seconds < 60
GROUP BY d.driver_id, d.full_name, t.name
ORDER BY Best_Pit_Stop ASC
LIMIT 5;
