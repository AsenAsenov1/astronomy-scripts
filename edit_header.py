import os
from astropy.io import fits


# Fill the values
header_data = {
    "OBJECT": "",
    "RA": "",
    "DEC": "",
    "INSTRUME": "FLI",
    "TELESCOP": "SCHMIDT"
}

# Get the current directory
current_dir = os.getcwd()
file_names = os.listdir(current_dir)

# Insert file names into a list as strings
file_names_list = [(str(file_name)) for file_name in file_names if ".fit" in file_name]

# Iterate through every file and write the following values
for file in file_names_list:
    fits.setval(file, "OBJECT", value=header_data["OBJECT"])
    fits.setval(file, "RA", value=header_data["RA"])
    fits.setval(file, "DEC", value=header_data["DEC"])
    fits.setval(file, "INSTRUME", value=header_data["INSTRUME"])
    fits.setval(file, "TELESCOP", value=header_data["TELESCOP"])
