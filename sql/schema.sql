DROP TABLE IF EXISTS penalties;
DROP TABLE IF EXISTS pit_stops;
DROP TABLE IF EXISTS results;
DROP TABLE IF EXISTS drivers;
DROP TABLE IF EXISTS races;
DROP TABLE IF EXISTS teams;
DROP TABLE IF EXISTS circuits;

DROP VIEW IF EXISTS v_driver_standings;
DROP VIEW IF EXISTS v_team_standings;
DROP VIEW IF EXISTS v_pit_stop_performance;
DROP VIEW IF EXISTS v_Driver_Penalized_ranking;
DROP VIEW IF EXISTS v_team_penalties_ranking;

CREATE TABLE teams (
    team_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    nationality TEXT,
    base_city TEXT
);

CREATE TABLE circuits (
    circuit_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    location TEXT,
    country TEXT,
    length_km REAL
);

CREATE TABLE races (
    session_key INTEGER PRIMARY KEY,
    year INTEGER NOT NULL,
    round INTEGER, 
    circuit_id INTEGER,
    name TEXT,
    date DATE,
    FOREIGN KEY (circuit_id) REFERENCES circuits(circuit_id)
);

CREATE TABLE drivers (
    driver_id INTEGER PRIMARY KEY, 
    first_name TEXT,
    last_name TEXT,
    full_name TEXT,
    code TEXT UNIQUE,
    nationality TEXT,
    team_id INTEGER, 
    FOREIGN KEY (team_id) REFERENCES teams(team_id)
);

CREATE TABLE results (
    session_key INTEGER,
    driver_id INTEGER,
    team_id INTEGER, 
    grid_position INTEGER,
    final_position INTEGER,
    points REAL,
    status TEXT,
    PRIMARY KEY (session_key, driver_id),
    FOREIGN KEY (session_key) REFERENCES races(session_key),
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id),
    FOREIGN KEY (team_id) REFERENCES teams(team_id)
);

CREATE TABLE pit_stops (
    session_key INTEGER,
    driver_id INTEGER,
    lap INTEGER,
    duration_seconds REAL,
    FOREIGN KEY (session_key, driver_id) REFERENCES results(session_key, driver_id)
);

CREATE TABLE penalties (
    penalty_id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_key INTEGER, 
    driver_id INTEGER,
    infraction TEXT,
    seconds_added INTEGER,
    is_served BOOLEAN,
    FOREIGN KEY (session_key, driver_id) REFERENCES results(session_key, driver_id)
);


-- 1. Classement des Pilotes
CREATE VIEW v_driver_standings AS
SELECT 
    d.full_name AS Pilot,
    t.name AS Team,
    SUM(res.points) AS Total_Points,
    COUNT(CASE WHEN res.final_position <= 3 THEN 1 END) AS Podiums
FROM drivers d
JOIN results res ON d.driver_id = res.driver_id
JOIN teams t ON res.team_id = t.team_id
GROUP BY d.driver_id
ORDER BY Total_Points DESC;

-- 2. Classement des Écuries
CREATE VIEW v_team_standings AS
SELECT 
    t.name AS Team,
    SUM(res.points) AS Total_Points,
    t.nationality AS Origin
FROM teams t
JOIN results res ON t.team_id = res.team_id
GROUP BY t.team_id
ORDER BY Total_Points DESC;

-- 3. Performance des Arrêts aux Stands (Nettoyée des Drapeaux Rouges > 60s)
CREATE VIEW v_pit_stop_performance AS
SELECT 
    t.name AS Team,
    ROUND(AVG(p.duration_seconds), 3) AS Avg_Pit_Time,
    MIN(p.duration_seconds) AS Best_Stop,
    COUNT(*) AS Total_Stops_Executed
FROM pit_stops p
JOIN results res ON p.session_key = res.session_key AND p.driver_id = res.driver_id
JOIN teams t ON res.team_id = t.team_id
WHERE p.duration_seconds < 60
GROUP BY t.team_id
ORDER BY Avg_Pit_Time ASC; 

-- 4. Classement des Pilotes les plus pénalisés
CREATE VIEW v_Driver_Penalized_ranking AS
SELECT 
    d.full_name AS Driver,
    t.name AS Team,
    COUNT(pen.penalty_id) AS Total_Infractions
FROM drivers d
JOIN teams t ON d.team_id = t.team_id
JOIN penalties pen ON d.driver_id = pen.driver_id
GROUP BY d.driver_id
ORDER BY Total_Infractions DESC;

-- 5. Classement des Écuries les plus pénalisées
CREATE VIEW v_team_penalties_ranking AS
SELECT 
    t.name AS Team,
    COUNT(pen.penalty_id) AS Total_Infractions,
    GROUP_CONCAT(DISTINCT pen.infraction) AS Common_Infractions 
FROM teams t
JOIN results res ON t.team_id = res.team_id
JOIN penalties pen ON res.session_key = pen.session_key AND res.driver_id = pen.driver_id
GROUP BY t.team_id
ORDER BY Total_Infractions DESC;

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
END;
