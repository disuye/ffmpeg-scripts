#!/bin/bash
# Convert MOV to folder of image sequence PNGs
INPUT=footage/C0002.MP4
INPUT_START=00:1:00
INPUT_END=00:01:08
OUTPUT_FOLDER=OUTPUT_SEQ
mkdir -p ${OUTPUT_FOLDER}
ffmpeg -ss ${INPUT_START} -to ${INPUT_END} -i ${INPUT} -vf "fps=25" ${OUTPUT_FOLDER}/frame_%04d.png
# END #