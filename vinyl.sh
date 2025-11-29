# !/bin/bash
# FFMPEG script to simulate record artwork on spinning turntable... (turntable spindle is +9x -3y [10.8, 3.6]  pixels [high & to the right] off centre)
# -filter_complex:
# Extract luma matte from the background turntable video (lines 1-2-3)
# Rotate vinyl label artwork at 45RPM, crop using above luma matte (lines 4-5-6)
# Composite and apply 3DLUT colour grading (line 7)... lut3d='3dluts_vinyl/5.cube'

ARTWORK=ARTWORK66.PNG
BACKGROUND=footage/C0002.MP4
MUSIC=MUSIC.wav
ffmpeg -ss 00:00:15 \
       -i ${BACKGROUND} \
       -loop 1 -i mask.png \
       -loop 1 -i matte.png \
       -loop 1 -i ${ARTWORK} \
       -ss 00:04:29 \
       -i ${MUSIC} \
       -t 90 \
       -filter_complex "[0:v]crop='min(iw,ih)':'min(iw,ih)', scale=1800:1800, format=rgba, split=2[A][B]; \
              [B]hue=s=0, eq=contrast=500:brightness=0.8, format=rgba[C]; \
              [C][1:v]blend=all_mode=darken, format=rgba[garbage_mask]; \
              [garbage_mask][2:v]blend=all_mode=lighten, hue=s=0, format=rgba[luma_matte]; \
              [3:v]crop='min(iw,ih)':'min(iw,ih)', scale=1800:1800, format=rgba[artwork]; \
              [artwork]rotate=2*PI*t*(45/60):c=black, crop=1800:1800:(iw-1800)/2:(ih-1800)/2, scale=1800:1800, format=rgba[label]; \
              [label][luma_matte]alphamerge, format=rgba[label_masked]; \
              [A][label_masked]overlay, lut3d='3dluts_vinyl/5.cube', format=rgba[output]" \
       -map "[output]" -map 4:a \
       -c:v libx264 -pix_fmt yuv420p -r 25 \
       -c:a aac -b:a 320k \
       -shortest \
       VINYL_${ARTWORK%.*}.mp4