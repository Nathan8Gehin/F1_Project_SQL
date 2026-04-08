-- ================================================================================
-- ANALYSIS.SQL : Requêtes d'analyse de performance
-- ================================================================================

-- ANALYSE 1 : Top 5 des pilotes avec le plus de podiums
-- Objectif : Identifier la régularité des pilotes
SELECT 
    d.full_name AS Driver,
    COUNT(*) AS Podiums
FROM drivers d
JOIN results r ON d.driver_number = r.driver_number
WHERE r.position <= 3
GROUP BY d.driver_number, d.full_name
ORDER BY Podiums DESC
LIMIT 5;

-- ANALYSE 2 : Top 5 des pilotes les plus pénalisés
-- Objectif : Identifier les pilotes les plus sanctionnés
SELECT 
    d.full_name AS Driver,
    t.name AS Team,
    COUNT(p.penalty_id) AS Total_Penalties
FROM drivers d
JOIN penalties p ON d.driver_number = p.driver_number
JOIN teams t ON d.team_id = t.team_id
GROUP BY d.driver_number, d.full_name, t.name
ORDER BY Total_Penalties DESC
LIMIT 5;

-- ANALYSE 3 : Les 5 Grands Prix ayant généré le plus de pénalités
-- Objectif : Identifier les circuits problématiques (ex: limites de piste)
SELECT 
    r.name AS Grand_Prix, 
    r.year, 
    COUNT(p.penalty_id) AS Nb_Penalties
FROM penalties p
JOIN races r ON p.session_key = r.session_key
GROUP BY r.session_key, r.name, r.year
ORDER BY Nb_Penalties DESC
LIMIT 5;

-- ANALYSE 4: TOP 5 des meilleurs pit stops par pilote
-- Objectif : identifier les arrêts les plus rapides en excluant les données aberrantes
SELECT 
    d.full_name AS Driver,
    t.name AS Team,
    MIN(p.duration) AS Best_Pit_Stop
FROM pit_stops p
JOIN drivers d ON p.driver_number = d.driver_number
JOIN teams t ON d.team_id = t.team_id
WHERE p.duration < 60  -- Exclusion des arrêts trop longs (problèmes techniques)
  AND p.duration > 5   -- Exclusion des arrêts trop courts (erreurs de l'API)
GROUP BY d.driver_number, d.full_name, t.name
ORDER BY Best_Pit_Stop ASC
LIMIT 5;
