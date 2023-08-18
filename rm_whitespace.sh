#!/bin/bash

# Remove whitespace from filenames
# Example command run: rm_whitespace.sh /path/to/files

if [ $# -ne 1 ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

directory="$1"

if [ ! -d "$directory" ]; then
    echo "Directory not found: $directory"
    exit 1
fi

# Loop through files in the directory and remove whitespace characters from filenames
for file in "$directory"/*; do
    if [ -f "$file" ]; then
        new_file=$(echo "$file" | tr -d '()' | sed 's/ /_/')
        mv "$file" "$new_file"
        echo "Renamed: $file to $new_file"
    fi
done
