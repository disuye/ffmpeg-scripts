#!/bin/bash
# NOT WORKING in all cases: Determine if an image contains colour, or is only black & white

FOLDER="${1:-.}"

echo "Checking images in: $FOLDER"
echo "--------------------------------"

find "$FOLDER" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -print0 | sort -z | while IFS= read -r -d '' img; do
    if ffmpeg -v error -i "$img" -vf "hue=s=0" -f null - ; then
        echo "B&W     | $img"
    else
        echo "COLOR   | $img"
    fi
done