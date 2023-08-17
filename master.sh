#!/bin/bash

dir=$1                # 2023XXXX
dir_cal=$dir/cal      # 2023XXXX/cal
wcs_dir=$dir/wcs_out  # 2023XXXX/wcs_out
scripts=$mnt_dir/scripts
object=$2

# Remove whitespace symbols from filenames.
$scripts/rm_whitespace.sh $dir_cal

# First image from which RA/DEC will be extracted.
image=$(ls $dir_cal | head -1)

# Check if wcs_dir exists, if not - create.
if [ ! -d "$wcs_dir" ]; then
    echo "WCS directory not found. Creating..."
    mkdir -p $wcs_dir
fi

# Run astrometry.net
cd $dir_cal && solve-field --no-plots --cpulimit 30 --scale-low 0.8 --scale-high 1.5 --dir $wcs_dir $image

echo "Cleaning up..."

# Delete all except the .wcs file
cd $wcs_dir && rm *.[^w]*

echo "Extraction data results"

# Read .wcs file
python3 $scripts/extract_ra_dec.py $wcs_dir

# Extracted RA and DEC from WCS file
ra_extracted=$(cut -d ' ' -f 2-4 $wcs_dir/extraction_data)
dec_extracted=$(cut -d ' ' -f 5-7 $wcs_dir/extraction_data)
ra_hh_extracted=$(cut -d ' ' -f 2 $wcs_dir/extraction_data)
dec_dd_extracted=$(cut -d ' ' -f 5 $wcs_dir/extraction_data)

# Extracted RA and DEC from FITS file
ra_header=$(fitsheader -t ascii.csv $dir_cal/$image | grep RA | cut -d ',' -f 4)
dec_header=$(fitsheader -t ascii.csv  $dir_cal/$image | grep DEC | cut -d ',' -f 4)
ra_hh_header=$(fitsheader -t ascii.csv $dir_cal/$image | grep RA | cut -d ',' -f 4 | cut -d ' ' -f 1)
dec_dd_header=$(fitsheader -t ascii.csv  $dir_cal/$image | grep DEC | cut -d ',' -f 4 | cut -d ' ' -f 1 | grep -oE '[0-9]+')

# Calculate RA/DEC deviations
ra_hh_deviation=$(($ra_hh_extracted - $ra_hh_header))
dec_dd_deviation=$(($dec_dd_extracted - $dec_dd_header))

echo "Header Data, RA: ${ra_header}"
echo "Header Data, DEC: ${dec_header}"
echo "[RA] Deviation in Hours: ${ra_hh_deviation}"
echo "[DEC] Deviation in Degrees: ${dec_dd_deviation}"


# If RA/DEC deviations are under 1 hour or degree - set header data with the current values otherwise write the values from WCS (astrometry.net)
if [ "$ra_hh_deviation" -eq 0 ] && [ "$dec_dd_deviation" -eq 0 ]; then
    echo "Deviation is low."
    echo "RA values will be applied: ${ra_header}"
    echo "DEC values will be applied: ${dec_header}"
    python3 $scripts/edit_header_auto.py $dir_cal $object $ra_header $dec_header
else
    echo "Deviation is high."
    echo "RA values will be applied: ${ra_extracted}"
    echo "DEC values will be applied: ${dec_extracted}"
    python3 $scripts/edit_header_auto.py $dir_cal $object $ra_extracted $dec_extracted
fi
