#!/bin/bash
FOLDER="LUT_Demo"
OUTPUT="Contact_Sheet.png"

# Generate a text file with one image per line
printf "" > images.txt
find "$FOLDER" -name "*.jpg" -type f | sort -V | while read img; do
  echo "file '$img'" >> images.txt
done

ffmpeg -f concat -safe 0 -i images.txt -vf \
"scale=256:144:force_original_aspect_ratio=decrease,
pad=256:144:(ow-iw)/2:(oh-ih)/2:black,
drawtext=text='%{file~basename}':fontcolor=yellow:fontsize=12:x=(w-text_w)/2:y=h-th-6:box=1:boxcolor=black@0.7,
drawtext=text='#%{n}':fontcolor=white:fontsize=11:x=8:y=8,
hstack=inputs=20,tile=20x30:margin=10:padding=10:color=black" \
-frames:v 1 -q:v 2 "$OUTPUT"

echo "Done — real filenames shown → $OUTPUT"