/* ================================================================================
  DATABASE SCHEMA: Formula 1 Analysis (For any season already available on OpenF1)
  =================================================================================
*/

PRAGMA foreign_keys = ON;

-- -----------------------------------------------------
-- TABLE: teams
-- -----------------------------------------------------
CREATE TABLE teams (
    team_id INTEGER PRIMARY KEY AUTOINCREMENT, -- Unique team ID (AUTOINCREMENT)
    name TEXT NOT NULL UNIQUE                  -- Official team name
);

-- -----------------------------------------------------
-- TABLE: circuits
-- -----------------------------------------------------
CREATE TABLE circuits (
    circuit_id INTEGER PRIMARY KEY AUTOINCREMENT, -- Unique track ID (AUTOINCREMENT)
    name TEXT NOT NULL UNIQUE,                    -- Grand Prix location name
    country TEXT                                  -- Host nation
);

-- -----------------------------------------------------
-- TABLE: races
-- -----------------------------------------------------
CREATE TABLE races (
    session_key INTEGER PRIMARY KEY, -- Unique session ID (API)
    year INTEGER NOT NULL,           -- Racing season 
    circuit_id INTEGER,              -- Links to the circuits table
    name TEXT,                       -- Display name of the event
    date DATETIME,                   -- Date of the race 
    FOREIGN KEY (circuit_id) REFERENCES circuits(circuit_id) -- Link to others tables 
);

-- -----------------------------------------------------
-- TABLE: drivers
-- -----------------------------------------------------
CREATE TABLE drivers (
    driver_number INTEGER PRIMARY KEY, -- Official FIA car number (API)
    full_name TEXT NOT NULL,           -- Driver's full name
    team_id INTEGER,                   -- Links to the constructor (teams table)
    team_colour TEXT,                  -- Hexadecimal code for UI/Charts
    FOREIGN KEY (team_id) REFERENCES teams(team_id) -- Link to others tables 
);

-- -----------------------------------------------------
-- TABLE: results
-- -----------------------------------------------------
CREATE TABLE results (
    session_key INTEGER,                -- Reference to the specific race (API)
    driver_number INTEGER,              -- Reference to the driver
    position INTEGER,                   -- Final classification
    points REAL DEFAULT 0,              -- Computed F1 points 
    PRIMARY KEY (session_key, driver_number), -- One result per race
    FOREIGN KEY (session_key) REFERENCES races(session_key),
    FOREIGN KEY (driver_number) REFERENCES drivers(driver_number) -- Link to others tables 
);

-- -----------------------------------------------------
-- TABLE: pit_stops
-- -----------------------------------------------------
CREATE TABLE pit_stops (
    session_key INTEGER,     -- Race event reference
    driver_number INTEGER,   -- Driver involved in the pit stop
    lap_number INTEGER,      -- Lap when the stop occurred
    duration REAL,           -- Time spent in the pit lane in seconds
    FOREIGN KEY (session_key, driver_number) REFERENCES results(session_key, driver_number) -- Link to others tables 
);

-- -----------------------------------------------------
-- TABLE: penalties
-- -----------------------------------------------------
CREATE TABLE penalties (
    penalty_id INTEGER PRIMARY KEY AUTOINCREMENT, -- Unique log ID (AUTOINCREMENT)
    session_key INTEGER,                          -- Race event reference
    driver_number INTEGER,                        -- Infringing driver
    lap_number INTEGER,                           -- Lap of the incident
    infraction TEXT,                              -- Official description of the foul
    FOREIGN KEY (session_key, driver_number) REFERENCES results(session_key, driver_number) -- Link to others tables 
);

-- -----------------------------------------------------
-- INDEXES for Performance
-- -----------------------------------------------------
-- Accelerates searches by driver name
CREATE INDEX idx_driver_name ON drivers(full_name); 
-- Accelerates performance analysis by constructor
CREATE INDEX idx_team_name ON teams(name); 

-- ================================================================================
-- SQL VIEWS
-- ================================================================================

-- -----------------------------------------------------
-- VIEW: v_driver_standings (Corrigée pour séparer les années)
-- -----------------------------------------------------
CREATE VIEW v_driver_standings AS
SELECT 
    ra.year AS Season,
    d.full_name AS Driver,
    t.name AS Constructor,
    SUM(res.points) AS Total_Points
FROM results res
JOIN races ra ON res.session_key = ra.session_key -- Lien indispensable pour l'année
JOIN drivers d ON res.driver_number = d.driver_number
JOIN teams t ON d.team_id = t.team_id
GROUP BY ra.year, d.driver_number -- On groupe par année ET par pilote
ORDER BY ra.year DESC, Total_Points DESC;

-- -----------------------------------------------------
-- VIEW: v_team_standings (Corrigée pour séparer les années)
-- -----------------------------------------------------
DROP VIEW IF EXISTS v_team_standings;
CREATE VIEW v_team_standings AS
SELECT 
    ra.year AS Season,
    CASE 
        WHEN d.full_name = 'Lewis HAMILTON' AND ra.year = 2024 THEN 'Mercedes'
        WHEN d.full_name = 'Carlos SAINZ' AND ra.year = 2024 THEN 'Ferrari'
        WHEN d.full_name = 'Carlos SAINZ' AND ra.year = 2025 THEN 'Williams'
        WHEN t.name = 'RB' OR t.name LIKE '%Racing Bulls%' THEN 'Racing Bulls'
        WHEN t.name LIKE '%Kick Sauber%' THEN 'Sauber'
        ELSE t.name 
    END AS Constructor,
    SUM(res.points) AS Total_Points
FROM results res
JOIN races ra ON res.session_key = ra.session_key
JOIN drivers d ON res.driver_number = d.driver_number
JOIN teams t ON d.team_id = t.team_id
GROUP BY Season, Constructor
ORDER BY Season DESC, Total_Points DESC;

-- -----------------------------------------------------
-- VIEW: v_race_results_detailed
-- Role: Displays the full classification for every Grand Prix.
-- Links the race, circuit, and country info for a complete history.
-- -----------------------------------------------------
CREATE VIEW v_race_results_detailed AS
SELECT 
    r.year AS Season,
    r.name AS Grand_Prix,
    c.country AS Country,
    d.full_name AS Driver,
    res.position AS Rank,
    res.points AS Points_Earned
FROM results res
JOIN races r ON res.session_key = r.session_key
JOIN circuits c ON r.circuit_id = c.circuit_id
JOIN drivers d ON res.driver_number = d.driver_number
ORDER BY r.date DESC, res.position ASC;

-- -----------------------------------------------------
-- VIEW: v_pit_performance
-- Role: Analyzes the speed of the pit crews by team.
-- Calculates average time (excluding outliers over 60s like red flags).
-- -----------------------------------------------------
CREATE VIEW v_pit_performance AS
SELECT 
    ra.year AS Season,
    -- On applique le même nettoyage pour fusionner RB/Racing Bulls et Sauber
    CASE 
        WHEN d.full_name = 'Lewis HAMILTON' AND ra.year = 2024 THEN 'Mercedes'
        WHEN d.full_name = 'Carlos SAINZ' AND ra.year = 2024 THEN 'Ferrari'
        WHEN d.full_name = 'Carlos SAINZ' AND ra.year = 2025 THEN 'Williams'
        WHEN t.name = 'RB' OR t.name LIKE '%Racing Bulls%' THEN 'Racing Bulls'
        WHEN t.name LIKE '%Sauber%' THEN 'Sauber'
        ELSE t.name 
    END AS Team,
    ROUND(AVG(ps.duration), 3) AS Avg_Pit_Time,
    COUNT(*) AS Total_Pit_Stops
FROM pit_stops ps
JOIN races ra ON ps.session_key = ra.session_key
JOIN drivers d ON ps.driver_number = d.driver_number
JOIN teams t ON d.team_id = t.team_id
WHERE ps.duration < 60 
-- IMPORTANT : On groupe par l'alias "Team" pour fusionner les lignes
GROUP BY Season, Team
ORDER BY Season DESC, Avg_Pit_Time ASC;


-- -----------------------------------------------------
-- VIEW: v_bad_boys_ranking
-- Role: Ranks drivers by the number of penalties received.
-- Helps identify the most aggressive or error-prone drivers.
-- -----------------------------------------------------
CREATE VIEW v_bad_boys_ranking AS
SELECT 
    ra.year AS Season,
    d.full_name AS Driver,
    t.name AS Team,
    COUNT(p.penalty_id) AS Penalty_Count
FROM penalties p
JOIN races ra ON p.session_key = ra.session_key -- Lien pour l'année
JOIN drivers d ON p.driver_number = d.driver_number
JOIN teams t ON d.team_id = t.team_id
GROUP BY ra.year, d.driver_number
ORDER BY ra.year DESC, Penalty_Count DESC;
