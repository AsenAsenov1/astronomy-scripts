# Extracts RA and DEC from .wcs files
#
# Example command run: python3 extract_ra_dec.py /path/to/files/
#
# Example output:
# 6249Jennifer-020_R180 14 54 51.60 +01 32 00.23
# 6249Jennifer-021_R180 14 56 01.97 +00 54 37.25
# 6249Jennifer-022_R180 14 54 11.06 +01 01 13.46


import os
import sys
from astropy.io import fits
from astropy.coordinates import Angle
import astropy.units as u


def decimal_to_hms(decimal_value):
    ra_angle = Angle(decimal_value, unit=u.deg)
    ra_hms = ra_angle.to_string(unit=u.hourangle, sep=' ', pad=True, precision=2)
    return ra_hms


def decimal_to_dms(decimal_value):
    dec_angle = Angle(decimal_value, unit=u.deg)
    dec_dms = dec_angle.to_string(unit=u.deg, sep=' ', pad=True, precision=2, alwayssign=True, decimal=False)
    return dec_dms


dir_path = sys.argv[1]  # Target directory in which .wcs files are located
file_names = os.listdir(dir_path)

dictionary_ra_dec = {}

for file in file_names:
    file_path = os.path.join(dir_path, file)
    if os.path.isfile(file_path):
        if ".wcs" in str(file):
            ra_decimal = fits.getval(file_path, 'CRVAL1')  # Read the .wcs file and get RA decimal values
            dec_decimal = fits.getval(file_path, 'CRVAL2')  # Read the .wcs file and get DEC decimal values

            ra = decimal_to_hms(ra_decimal)  # Convert RA decimal to HH:MM:SS
            dec = decimal_to_dms(dec_decimal)  # Convert DEC decimal to DD:MM:SS

            filename = str(file).replace(".wcs", "")
            dictionary_ra_dec[filename] = {"ra": ra, "dec": dec}  # Put the values into a dictionary

            # print(filename, ra, dec)

            with open('extraction_data', 'a+') as extract_file:
                extract_file.write(f"{filename} {ra} {dec}")

for file, dict_ra_dec in dictionary_ra_dec.items():
    print(file, dict_ra_dec['ra'], dict_ra_dec['dec'])

