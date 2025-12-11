import os
import re
from collections import defaultdict

INPUT_FOLDER = "/home/aiims/Desktop/Yash/scripts/XC_labeller/SPDC/XC-LABELLING/Summary/."
OUTPUT_FILE = "/home/aiims/Desktop/Yash/scripts/XC_labeller/SPDC/XC-LABELLING/Summary/combined_summary.txt"

def extract_float(pattern, text):
    match = re.search(pattern, text)
    return float(match.group(1)) if match else 0.0

def extract_int(pattern, text):
    match = re.search(pattern, text)
    return int(match.group(1)) if match else 0

def parse_file(path):
    with open(path, "r", encoding="utf-8") as f:
        text = f.read()

    data = {}
    
    # Total Images Labeled
    data["images_labeled"] = extract_int(r"Images Labeled:\s+(\d+)", text)

    # Unique Cases (counting rows under PER-CASE)
    case_ids = re.findall(r"^\s*([0-9A-Za-z_]+)\s+\d+", text, re.MULTILINE)
    data["case_count"] = len(set(case_ids))

    # Timing metrics
    data["avg_time"] = extract_float(r"Average Time per Image:\s+([\d\.]+)", text)
    data["fastest"] = extract_float(r"Fastest Image:\s+([\d\.]+)", text)
    data["slowest"] = extract_float(r"Slowest Image:\s+([\d\.]+)", text)
    data["median"] = extract_float(r"Median Time:\s+([\d\.]+)", text)

    # Label distribution
    data["suspicious"] = extract_int(r"Suspicious:\s+(\d+)", text)
    data["non_suspicious"] = extract_int(r"Non-Suspicious:\s+(\d+)", text)
    data["na"] = extract_int(r"NA:\s+(\d+)", text)

    # Productivity
    data["img_per_hour"] = extract_float(r"Images per Hour:\s+([\d\.]+)", text)
    data["session_eff"] = extract_float(r"Session Efficiency:\s+([\d\.]+)", text)

    return data


def main():
    all_data = []
    
    for file in os.listdir(INPUT_FOLDER):
        if file.lower().endswith(".txt"):
            all_data.append(parse_file(os.path.join(INPUT_FOLDER, file)))

    if not all_data:
        print("No TXT files found.")
        return

    # --- TOTALS ---
    total_cases = sum(d["case_count"] for d in all_data)
    total_images = sum(d["images_labeled"] for d in all_data)

    # Timing Averages
    avg_avg_time = sum(d["avg_time"] for d in all_data) / len(all_data)
    avg_fastest = sum(d["fastest"] for d in all_data) / len(all_data)
    avg_slowest = sum(d["slowest"] for d in all_data) / len(all_data)
    avg_median = sum(d["median"] for d in all_data) / len(all_data)

    # Label Distribution Totals
    total_suspicious = sum(d["suspicious"] for d in all_data)
    total_non_susp = sum(d["non_suspicious"] for d in all_data)
    total_na = sum(d["na"] for d in all_data)

    # Productivity Averages
    avg_img_per_hour = sum(d["img_per_hour"] for d in all_data) / len(all_data)
    avg_eff = sum(d["session_eff"] for d in all_data) / len(all_data)

    # --- WRITE OUTPUT ---
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        f.write("===========================================================\n")
        f.write("           COMPILED LABELLING SUMMARY REPORT\n")
        f.write("===========================================================\n\n")

        f.write("AGGREGATED METRICS\n")
        f.write("-----------------------------------------------------------\n")
        f.write(f"Total Unique Cases: {total_cases}\n")
        f.write(f"Total Images Labeled: {total_images}\n\n")

        f.write("AVERAGE TIMING METRICS (ACROSS ALL BATCHES)\n")
        f.write("-----------------------------------------------------------\n")
        f.write(f"Average of Average Time per Image: {avg_avg_time:.2f} sec\n")
        f.write(f"Average Fastest Time: {avg_fastest:.2f} sec\n")
        f.write(f"Average Slowest Time: {avg_slowest:.2f} sec\n")
        f.write(f"Average Median Time: {avg_median:.2f} sec\n\n")

        f.write("LABEL DISTRIBUTION (TOTAL)\n")
        f.write("-----------------------------------------------------------\n")
        f.write(f"Suspicious: {total_suspicious}\n")
        f.write(f"Non-Suspicious: {total_non_susp}\n")
        f.write(f"NA: {total_na}\n\n")

        f.write("PRODUCTIVITY METRICS (AVERAGED)\n")
        f.write("-----------------------------------------------------------\n")
        f.write(f"Images per Hour (Avg): {avg_img_per_hour:.2f}\n")
        f.write(f"Session Efficiency (Avg): {avg_eff/10:.2f}%\n\n")

        f.write("===========================================================\n")
        f.write("Compiled Summary Generated Successfully\n")
        f.write("===========================================================\n")

    print(f"Summary saved to: {OUTPUT_FILE}")


if __name__ == "__main__":
    main()
