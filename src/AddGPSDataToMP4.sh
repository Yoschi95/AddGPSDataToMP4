#!/bin/bash

#================================================================================
# Script name:     AddGPSDataToMP4.sh
# Description:     This script adds GPS metadata to mp4-files
# Call:            ./AddGPSDataToMP4.sh /d/path/to/videos
# Input parameter: <pathToVideoDirectory>: Path to the video and text files 
# Author:          Yoschi95
#================================================================================

# Save passed arguments
pathToVideoDirectory=$1

# Print found MP4 files
numberOfMP4Files=$(find $pathToVideoDirectory -maxdepth 1 -type f -iname "*.mp4" | wc -l)
echo "found $numberOfMP4Files .mp4 file(s)"  

# Print found SRT or TXT files
numberOfGPSDataFiles=$(find $pathToVideoDirectory -maxdepth 1 -type f \( -iname "*.SRT" -o -iname "*.txt" \) | wc -l)
#numberOfGPSDataFiles=$(find $pathToVideoDirectory -maxdepth 1 -type f -iname "*.SRT" | wc -l)
echo "found $numberOfGPSDataFiles .SRT and .txt file(s)"  
echo ""

# Iterate over all .SRT and .txt files
for file in "$pathToVideoDirectory"/*.{SRT,txt}; do

    if [[ -f "$file" ]]; then

        fileNameWithType=$(basename "$file")
        fileNameWithoutType="${fileNameWithType%.*}"
        echo "Parsing GPS data from $fileNameWithType"

        # Parse GPS location and save in vars
        GPSLatitude=$(grep -Po -m 1 "(?<=latitude: )\d+\.\d+" $file)
        if [ -z "$GPSLatitude" ]; then
            echo "No GPS latitude found. Nothing to do."
            continue
        fi
        echo "GPSLatitude: $GPSLatitude"

        GPSLongitude=$(grep -Po -m 1 "(?<=longitude: )\d+\.\d+" $file)
        if [ -z "$GPSLongitude" ]; then
            echo "No GPS longitude found. Nothing to do."
            continue
        fi
        echo "GPSLongitude: $GPSLongitude"

        GPSAltitude=$(grep -Po -m 1 "(?<=abs_alt: )\d+\.\d+" $file)
        if [ -z "$GPSAltitude" ]; then
            echo "Warning: No GPS altitude found."
        else
            echo "GPSAltitude: $GPSAltitude"
        fi

        # Set GPS data to .mp4 file
        echo "Writing GPS data to $fileNameWithoutType.mp4"
        exiftool -overwrite_original -Keys:GPSCoordinates="$GPSLatitude, $GPSLongitude, $GPSAltitude" -ItemList:GPSCoordinates="$GPSLatitude, $GPSLongitude, $GPSAltitude" $pathToVideoDirectory/$fileNameWithoutType.mp4

        echo ""
    fi
done
