#!/bin/bash

LUT_DIR="3dluts";
OUTPUT_DIR="LUT_Demo";
SOURCE="ARTWORK6`.dng";
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