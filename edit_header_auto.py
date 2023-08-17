from astropy.io import fits
import os
import sys

dir_path = sys.argv[1]  # Target directory in which .fit files are located
astro_object = sys.argv[2]
ra_value = " ".join(sys.argv[3:6])
dec_value = " ".join(sys.argv[6:])
file_names = os.listdir(dir_path)

for file in file_names:
    file_path = os.path.join(dir_path, file)
    if os.path.isfile(file_path):
        if ".fit" in str(file):
            # Values from input
            fits.setval(file_path, "OBJECT", value=astro_object)
            fits.setval(file_path, "RA", value=ra_value)
            fits.setval(file_path, "DEC", value=dec_value)

            # Default values
            fits.setval(file_path, "INSTRUME", value="FLI")
            fits.setval(file_path, "TELESCOP", value="SCHMIDT")
            fits.setval(file_path, "EPOCH", value="2000")

            print(f"File {file} header is now updated.")
