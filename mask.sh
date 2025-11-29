# !/bin/bash
# Working script to generate luma matte & garbage mask of the vinyl record label, from DJ turntable background video...

BACKGROUND=footage/C0002.MP4;

ffmpeg -i ${BACKGROUND} \
       -loop 1 -i mask.png \
       -loop 1 -i matte.png \
       -t 3 \
       -filter_complex \
       "[0:v]crop='min(iw,ih)':'min(iw,ih)', scale=2160:2160, hue=s=0, eq=contrast=500:brightness=0.8, format=rgb24[A]; \
       [A][1:v]blend=all_mode=darken, format=rgb24[garbage_mask]; \
       [garbage_mask][2:v]blend=all_mode=lighten, format=rgb24[luma_matte];" \
       -map "[luma_matte]" \
       -c:v libx264 -pix_fmt yuv420p -r 25 \
       -c:a aac -b:a 320k \
       -shortest \
       VINYL_MASK.mp4