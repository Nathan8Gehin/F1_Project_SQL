import requests
import csv
import os
import time
import re

BASE_URL = "https://api.openf1.org/v1"

def get_data(endpoint, params=None):
    try:
        response = requests.get(f"{BASE_URL}/{endpoint}", params=params, timeout=25)
        if response.status_code == 200:
            data = response.json()
            return data if data else []
        return []
    except Exception as e:
        print(f"Erreur sur {endpoint}: {e}")
        return []

def get_results_season(year):
    path = f"data/{year}/"
    os.makedirs(path, exist_ok=True)

    # RACES
    sessions = get_data("sessions", {"year": year, "session_name": "Race"})
    if not sessions:
        print("There is yet no data for that year")
        return

    with open(f"{path}/temp_races_{year}.csv", "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["session_key", "gp_name", "country", "date"])
        for s in sessions:
            writer.writerow([s['session_key'], s['location'], s['country_name'], s['date_start']])

    # DRIVERS
    first_session = sessions[0]['session_key']
    drivers_list = get_data("drivers", {"session_key": first_session})
    with open(f"{path}/temp_drivers_{year}.csv", "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["driver_number", "full_name", "team_name", "team_colour"])
        for d in drivers_list:
            writer.writerow([d['driver_number'], d.get('full_name'), d.get('team_name'), d.get('team_colour')])

    with open(f"{path}/temp_results_{year}.csv", "w", newline="", encoding="utf-8") as f_res, \
        open(f"{path}/temp_pit_stops_{year}.csv", "w", newline="", encoding="utf-8") as f_pit, \
        open(f"{path}/temp_penalties_{year}.csv", "w", newline="", encoding="utf-8") as f_pen:

        res_w = csv.writer(f_res)
        pit_w = csv.writer(f_pit)
        pen_w = csv.writer(f_pen)

        # RESULTS
        res_w.writerow(["session_key", "driver_number", "position"])
        # PIT STOPS (On garde lane_duration pour la cohérence sur toute la saison)
        pit_w.writerow(["session_key", "driver_number", "lap_number", "duration"])
        pen_w.writerow(["session_key", "driver_number", "lap_number", "infraction"])

        for s in sessions:
            sk = s['session_key']
            print(f"GP : {s['location']} : {year}")

            # RESULTS
            res_data = get_data("session_result", {"session_key": sk})
            for rd in res_data:
                d_num = rd.get('driver_number')
                pos = rd.get('position_number') or rd.get('position')
                if d_num and pos:
                    res_w.writerow([sk, d_num, pos])
            print(f"Results : {len(res_data)} drivers recorded")

            time.sleep(1.0)

            # PIT STOPS
            pits = get_data("pit", {"session_key": sk})
            for p in pits:
                # Utilisation de lane_duration (nouveau standard) ou pit_duration (deprecated)
                duration = p.get('lane_duration') or p.get('pit_duration')
                if p.get('driver_number'):
                    pit_w.writerow([sk, p.get('driver_number'), p.get('lap_number'), duration if duration else ""])
            print(f"Pit Stops : {len(pits)} stops recorded")

            # PENALTIES
            msgs = get_data("race_control", {"session_key": sk})
            pen_count = 0
            for m in msgs:
                txt = m.get('message', '').upper()

                if "PENALTY" in txt or "INCIDENT" in txt or "INVESTIGATION" in txt:
                    driver_no = m.get('driver_number')

                    if driver_no is None or str(driver_no) == "" or str(driver_no) == "None":
                        match = re.search(r"CAR\s*[:\s]\s*(\d+)", txt)
                        if not match:
                            match = re.search(r"CAR\s+(\d+)", txt)

                        if match:
                            driver_no = match.group(1)

                    if driver_no:
                        pen_w.writerow([sk, driver_no, m.get('lap_number'), m.get('message')])
                        pen_count += 1

            time.sleep(4)

            print(f"Penalties : {pen_count} recorded")

    print(f"The {year} season has well been exported in {path}")

if __name__ == "__main__":
    get_results_season(2025)
