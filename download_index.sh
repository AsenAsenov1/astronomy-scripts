#!/bin/bash

# Download all index files from 4205 to 4212.
# These images cover a range of 11 to 170 arcminutes,
# which is necessary for a CCD with field of view of 1 degree.

# Download range 420{5..7}-{00..11} incl.
for num_1 in {5..7}; do
    for num_2 in {00..11}; do
        wget http://broiler.astrometry.net/~dstn/4200/index-420$num_1-$num_2.fits
    done
done

# Download range 42{08..12} incl.
for num in {08..12}; do
   wget http://broiler.astrometry.net/~dstn/4200/index-42$num.fits
done


