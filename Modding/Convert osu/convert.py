import json
import os

def convert_raw_osu_to_json(input_filename="osu.txt", output_filename="chart.json"):
    x_to_column = {
        32: 0, 96: 1, 160: 2, 224: 3, 
        288: 4, 352: 5, 416: 6, 480: 7
    }
    
    notes = []
    
    if not os.path.exists(input_filename):
        print(f"Error: The file '{input_filename}' was not found.")
        return

    with open(input_filename, "r", encoding="utf-8") as file:
        for line in file:
            line = line.strip()
            
            # Skip empty lines, headers, or comments completely
            if not line or line.startswith("[") or line.startswith("//"):
                continue
                
            parts = line.split(",")
            # Make sure it's an actual data row containing coordinates
            if len(parts) < 5:
                continue
                
            try:
                raw_x = int(parts[0])
                start_time = int(parts[2])
                raw_type = int(parts[3])
                
                # Turn X into column numbers 0-7
                column = x_to_column.get(raw_x, max(0, (raw_x - 32) // 64))
                
                note_data = {
                    "N": column,
                    "T": start_time
                }
                
                # 128 = Hold/Long note, 1 = Tap note
                if raw_type == 128:
                    note_data["NT"] = 2
                    end_time_raw = parts[5].split(":")[0]
                    note_data["SE"] = int(end_time_raw)
                else:
                    note_data["NT"] = 1
                    
                notes.append(note_data)
                
            except (ValueError, IndexError):
                # Skip any lines that run into conversion issues
                continue

    with open(output_filename, "w", encoding="utf-8") as json_file:
        json.dump(notes, json_file, indent=4)
        
    print(f"Success! Processed {len(notes)} raw notes into '{output_filename}'.")

if __name__ == "__main__":
    convert_raw_osu_to_json()
