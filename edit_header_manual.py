from astropy.io import fits
import os
import sys

# Fill the values
header_data = {
    "OBJECT": "  ",
    "RA": "  ",
    "DEC": "  ",
    "INSTRUME": "FLI",
    "TELESCOP": "SCHMIDT"
}

dir_path = sys.argv[1]  # Target directory in which .fit files are located
file_names = os.listdir(dir_path)

for file in file_names:
    file_path = os.path.join(dir_path, file)
    if os.path.isfile(file_path):
        if ".fit" in str(file):
            fits.setval(file_path, "OBJECT", value=header_data["OBJECT"])
            fits.setval(file_path, "RA", value=header_data["RA"])
            fits.setval(file_path, "DEC", value=header_data["DEC"])
            fits.setval(file_path, "INSTRUME", value=header_data["INSTRUME"])
            fits.setval(file_path, "TELESCOP", value=header_data["TELESCOP"])
            print(f"File {file} header is now updated.")
