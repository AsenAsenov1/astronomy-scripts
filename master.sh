#!/bin/bash

# Define directories and input data

dir=$mnt_dir/$1      # 2023XXXX
cal_dir=$dir/cal     # 2023XXXX/cal
wcs_dir=$dir/wcs_out # 2023XXXX/wcs_out
scripts=$mnt_dir/scripts
object=$2


# FUNCTIONS START

# Decimal RA to HH MM SS function START
decimal_to_hms() 
{
    local decimal_value=$1
    python3 - <<END
decimal_value = $decimal_value
hours = int(decimal_value / 15)
remainder = decimal_value - (hours * 15)
minutes = int(remainder * 4)
seconds = int((remainder - (minutes / 4)) * 240)
print(f"{hours:02d} {minutes:02d} {seconds:02d}")
END
}
# Decimal RA to HH MM SS function END


# Decimal DEC to DD MM SS function START
decimal_to_dms_python() 
{
    local decimal_value=$1
    python3 - <<END
decimal_value = $decimal_value
degrees = int(decimal_value)
remainder = decimal_value - degrees
minutes = int(remainder * 60)
seconds = int((remainder - (minutes / 60)) * 3600)
print(f"{degrees:02d} {minutes:02d} {seconds:02d}")
END
}
# Decimal DEC to DD MM SS function END

# FUNCTIONS END





# SCRIPT START

# Remove whitespace symbols from filenames.
$scripts/rm_whitespace.sh $cal_dir

# Check if wcs_dir exists, if not - create.
if [ ! -d "$wcs_dir" ]; then
  echo "WCS directory not found. Creating..."
  mkdir -p $wcs_dir
fi

echo ""
echo "############################           ASTROMETRIC CALIBRATION BEGINS        ############################"
echo ""

cd $cal_dir

# Run astrometry.net until successful astrometric calibration
for image in *; do
  solve-field --no-plots --cpulimit 5 --scale-low 0.8 --scale-high 1.5 --dir $wcs_dir $image
  target_image_search="$(echo $image | cut -d '.' -f 1).wcs"
  check_image_wcs=$(ls $wcs_dir | grep -i "${target_image_search}")
  if [ "$target_image_search" = "$check_image_wcs" ]; then
	echo ""
    echo "############################  Astrometric calibration for image $image is successful!    ############################"
	echo ""
    break
  else
    echo "Astrometric calibration for image $image is not successful! Continuing with next one..."
  fi
done


echo ""
echo "Cleaning WCS directory from non-wcs files..."
echo ""

# Delete all except the .wcs file
cd $wcs_dir && rm *.[^w]*

echo ""
echo "############################            EXTRACTION DATA RESULT        ############################"
echo ""

# RA and DEC from WCS file
decimal_ra=$(fitsheader $wcs_dir/*.wcs | grep -i crval1 | grep -Po "\d+\.\d+")
decimal_dec=$(fitsheader $wcs_dir/*.wcs | grep -i crval2 | grep -Po "\d+\.\d+")

# Convert using Python and capture the result
converted_ra=$(decimal_to_hms "$decimal_ra")
converted_dec=$(decimal_to_dms_python "$decimal_dec")

# Split the Python output into separate variables
read hours minutes seconds <<< "$converted_ra"
read degrees dec_minutes dec_seconds <<< "$converted_dec"

echo "RA values will be applied: $hours $minutes $seconds"
echo "DEC values will be applied: $degrees $dec_minutes $dec_seconds"
echo "OBJECT: $object"

echo ""
echo "############################           WRITING HEADER DATA BEGINS        ############################"
echo ""

python3 $scripts/edit_header_auto.py $cal_dir $object $hours $minutes $seconds $degrees $dec_minutes $dec_seconds

echo ""
echo "############################           DONE! READY FOR PHOTOMETRY PIPELINE!        ############################"
echo ""

# SCRIPT END
