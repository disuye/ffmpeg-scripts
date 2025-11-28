# !/bin/bash

BACKGROUND=footage/C0002.MP4;
ffmpeg -i ${BACKGROUND} \
       -loop 1 -i mask.png \
       -t 3 \
       -filter_complex \
       "[0:v]crop='min(iw,ih)':'min(iw,ih)', scale=1800:1800, hue=s=0, eq=contrast=500:brightness=0.8, format=rgb24[record]; \
       [1:v]format=rgb24[garbage]; \
       [garbage][record]blend=all_mode=multiply, format=rgb24[mask]" \
       -map "[mask]" \
       -c:v libx264 -pix_fmt yuv420p -r 25 \
       -c:a aac -b:a 320k \
       -shortest \
       VINYL_BACKGROUND.mp4