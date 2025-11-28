#!/bin/bash
# This script renders one demo image file through an entire folder of 3DLUT files, in order to quickly compare all LUTs side-by-side...
# Change the variables: 
# LUT_DIR = location folder that contains all of your 3DLUT files; can contain subfolders; file names with special characters *might* crash the script
# OUTPUT_DIR = name & location of the folder where all processed images should be saved
# SOURCE = name & location of the image file you wish to use, can be almost any image format
# Do not forget to make this script executable: chmod +x demo_all_luts.sh
# github.com @disuye

LUT_DIR="3dluts";
OUTPUT_DIR="LUT_Demo";
SOURCE="ARTWORK.dng";
mkdir -p "${OUTPUT_DIR}_${SOURCE%.*}"; \
find "${LUT_DIR}/" -type f \( -iname "*.cube" -o -iname "*.3dl" -o -iname "*.lut" \) -print0 | \
while IFS= read -r -d '' lut; do \
  clean=$(basename "${lut%.*}" | sed -e 's/[_ ]\+/-/g' -e 's/[^A-Za-z0-9.-]//g' -e 's/^[-.]\+//'); \
  output="${OUTPUT_DIR}_${SOURCE%.*}/${clean}.jpg"; \
  ffmpeg -y -loop 1 -i "$SOURCE" \
    -vf "lut3d=file=$(printf '%q' "$lut" | sed "s/\\\\'/'/g"):interp=tetrahedral" \
    -frames:v 1 -update 1 \
    "$output" < /dev/null; \
done