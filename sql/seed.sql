-- ====================================================================
-- TEAMS AND CIRCUITS
-- 2024 + 2025 in order to combine the 2 season
-- ====================================================================

-- Insert unique constructors (avoiding duplicates with IGNORE)
INSERT OR IGNORE INTO teams(name)
SELECT team_name FROM temp_drivers_2024
UNION
SELECT team_name FROM temp_drivers_2025;

-- Insert unique circuits and locations
INSERT OR IGNORE INTO circuits (name, country)
SELECT gp_name, country FROM temp_races_2024
UNION
SELECT gp_name, country FROM temp_races_2025;

-- ====================================================================
-- DRIVERS
-- Link drivers to their respective team_id using a JOIN
-- ====================================================================

-- insert unique drivers
INSERT OR IGNORE INTO drivers (driver_number, full_name, team_id, team_colour)
SELECT td.driver_number, td.full_name, t.team_id, td.team_colour
FROM (SELECT * FROM temp_drivers_2024 UNION SELECT * FROM temp_drivers_2025) td
JOIN teams t ON td.team_name = t.name;

-- ====================================================================
-- RACE CALENDAR
-- Extract year from date and link to circuit_id
-- ====================================================================

INSERT OR IGNORE INTO races (session_key, year, name, date, circuit_id)
SELECT tr.session_key, CAST(SUBSTR(tr.date, 1, 4) AS INTEGER), tr.gp_name, tr.date, c.circuit_id
FROM (SELECT * FROM temp_races_2024 UNION SELECT * FROM temp_races_2025) tr
JOIN circuits c ON tr.gp_name = c.name;

-- ====================================================================
-- RACE RESULTS
-- Apply the official F1 scoring system to the position
-- ====================================================================

-- Import raw position 
INSERT OR IGNORE INTO results (session_key, driver_number, position)
SELECT tr.session_key, tr.driver_number, tr.position 
FROM (
    SELECT session_key, driver_number, position FROM temp_results_2024
    UNION
    SELECT session_key, driver_number, position FROM temp_results_2025
) tr
WHERE tr.session_key IN (SELECT session_key FROM races)
  AND tr.driver_number IN (SELECT driver_number FROM drivers);
  
-- Compute FIA points 
UPDATE results
SET points = CASE 
    WHEN position = 1 THEN 25 WHEN position = 2 THEN 18 WHEN position = 3 THEN 15
    WHEN position = 4 THEN 12 WHEN position = 5 THEN 10 WHEN position = 6 THEN 8
    WHEN position = 7 THEN 6  WHEN position = 8 THEN 4  WHEN position = 9 THEN 2
    WHEN position = 10 THEN 1 ELSE 0
END;

-- ====================================================================
-- PIT STOPS AND PENALTIES
-- ====================================================================

-- Import pit stop durations (filtered)
INSERT OR IGNORE INTO pit_stops (session_key, driver_number, lap_number, duration)
SELECT tr.session_key, tr.driver_number, tr.lap_number, tr.duration
FROM (
    SELECT session_key, driver_number, lap_number, duration FROM temp_pit_stops_2024
    UNION
    SELECT session_key, driver_number, lap_number, duration FROM temp_pit_stops_2025
) tr
WHERE EXISTS (
    SELECT 1 FROM results res 
    WHERE res.session_key = tr.session_key 
    AND res.driver_number = tr.driver_number
);

INSERT INTO penalties (session_key, driver_number, lap_number, infraction)
SELECT 
    tr.session_key,
    CAST(TRIM(SUBSTR(tr.infraction, INSTR(tr.infraction, 'CAR ') + 4, 3)) AS INTEGER),
    tr.lap_number,
    tr.infraction
FROM (
    SELECT session_key, infraction, lap_number FROM temp_penalties_2024
    UNION
    SELECT session_key, infraction, lap_number FROM temp_penalties_2025
) tr
WHERE tr.infraction LIKE '%CAR %';
