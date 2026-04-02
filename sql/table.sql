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

PRAGMA foreign_keys = ON;

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
    race_id INTEGER PRIMARY KEY AUTOINCREMENT,
    year INTEGER NOT NULL,
    round INTEGER, 
    circuit_id INTEGER,
    name TEXT,
    date DATE,
    FOREIGN KEY (circuit_id) REFERENCES circuits(circuit_id)
);


CREATE TABLE drivers (
    driver_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT,
    last_name TEXT,
    code TEXT UNIQUE,
    nationality TEXT,
    team_id INTEGER, 
    FOREIGN KEY (team_id) REFERENCES teams(team_id)
);



CREATE TABLE results (
    race_id INTEGER,
    driver_id INTEGER,
    team_id INTEGER, 
    grid_position INTEGER,
    final_position INTEGER,
    points REAL,
    total_time_ms INTEGER,
    status TEXT,
    PRIMARY KEY (race_id, driver_id),
    FOREIGN KEY (race_id) REFERENCES races(race_id),
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id),
    FOREIGN KEY (team_id) REFERENCES teams(team_id)
);


CREATE TABLE pit_stops (
    race_id INTEGER,
    driver_id INTEGER,
    stop_number INTEGER,
    lap INTEGER,
    duration_seconds REAL,
    FOREIGN KEY (race_id, driver_id) REFERENCES results(race_id, driver_id)
);


CREATE TABLE penalties (
    penalty_id INTEGER PRIMARY KEY AUTOINCREMENT,
    race_id INTEGER,
    driver_id INTEGER,
    infraction TEXT,
    seconds_added INTEGER,
    is_served BOOLEAN,
    FOREIGN KEY (race_id, driver_id) REFERENCES results(race_id, driver_id)
);

CREATE VIEW v_driver_standings AS
SELECT 
    d.code AS Pilot,
    t.name AS Team,
    SUM(res.points) AS Total_Points,
    COUNT(CASE WHEN res.final_position <= 3 THEN 1 END) AS Podiums
FROM drivers d
JOIN results res ON d.driver_id = res.driver_id
JOIN teams t ON res.team_id = t.team_id
GROUP BY d.driver_id
ORDER BY Total_Points DESC;


CREATE VIEW v_team_standings AS
SELECT 
    t.name AS Team,
    SUM(res.points) AS Total_Points,
    t.nationality AS Origin
FROM teams t
JOIN results res ON t.team_id = res.team_id
GROUP BY t.team_id
ORDER BY Total_Points DESC;


CREATE VIEW v_pit_stop_performance AS
SELECT 
    t.name AS Team,
    ROUND(AVG(p.duration_seconds), 3) AS Avg_Pit_Time,
    MIN(p.duration_seconds) AS Best_Stop,
    COUNT(p.stop_number) AS Total_Stops_Executed
FROM pit_stops p
JOIN results res ON p.race_id = res.race_id AND p.driver_id = res.driver_id
JOIN teams t ON res.team_id = t.team_id
GROUP BY t.team_id
ORDER BY Avg_Pit_Time ASC; 


CREATE VIEW v_Driver_Penalized_ranking AS
SELECT 
    d.first_name || ' ' || d.last_name AS Driver,
    t.name AS Team,
    COUNT(pen.penalty_id) AS Total_Infractions,
    SUM(pen.seconds_added) AS Total_Seconds_Penalized
FROM drivers d
JOIN teams t ON d.team_id = t.team_id
JOIN penalties pen ON d.driver_id = pen.driver_id
GROUP BY d.driver_id
ORDER BY Total_Seconds_Penalized DESC;


CREATE VIEW v_team_penalties_ranking AS
SELECT 
    t.name AS Team,
    COUNT(pen.penalty_id) AS Total_Infractions,
    SUM(pen.seconds_added) AS Total_Seconds_Penalized,
    GROUP_CONCAT(DISTINCT pen.infraction) AS Common_Infractions 
FROM teams t
JOIN results res ON t.team_id = res.team_id
JOIN penalties pen ON res.race_id = pen.race_id AND res.driver_id = pen.driver_id
GROUP BY t.team_id
ORDER BY Total_Seconds_Penalized DESC; 
