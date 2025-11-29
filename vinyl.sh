# !/bin/bash
# github.com/disuye/ffmpeg-scripts
# FFMPEG script to simulate record artwork on a spinning turntable... 
# EXPLANATION OF -filter_complex:
# [0:v] cropping = turntable spindle is +10h -5w pixels off centre
# Crop, center, garbage matte/mask & extract luma matte from the background turntable video (lines 1-2-3-4)
# Rotate vinyl label artwork at 45RPM, crop & mask using luma matte (lines 5-6-7)
# Composite, final crop, apply 3DLUT colour grading [optional] (line 8)
# Incoming ARTWORK should be square, any image format
# Incoming MUSIC should be 24bit WAV file, any audio format should work
# Matte & mask files must be 2160x2160 PNG files

# USER VARIABLES
ARTWORK=ARTWORK66.PNG
MUSIC=MUSIC.wav
MUSIC_START=00:04:29
COLOR_GRADE_LUT=3dluts_vinyl/3.cube
OUTPUT_DURATION=10

# SCRIPT ADMIN
BACKGROUND=footage/C0002.MP4
BACKGROUND_START=00:00:25
MASK_FILE=mask.png
MATTE_FILE=matte.png

ffmpeg -ss ${BACKGROUND_START}  \
       -i ${BACKGROUND} \
       -loop 1 -i ${MASK_FILE} \
       -loop 1 -i ${MATTE_FILE} \
       -loop 1 -i ${ARTWORK} \
       -ss ${MUSIC_START} \
       -i ${MUSIC} \
       -t ${OUTPUT_DURATION} \
       -filter_complex "[0:v]crop='min(iw,ih)':'min(iw,ih)', pad='min(iw,ih)'+20:'min(iw,ih)'+20:10:20:green, scale=2160:2160, format=rgba, split=2[A][B]; \
              [B]hue=s=0, eq=contrast=500:brightness=0.8, boxblur=3:1:1, format=rgba[C]; \
              [C][1:v]blend=all_mode=darken, format=rgba[garbage_mask]; \
              [garbage_mask][2:v]blend=all_mode=lighten, hue=s=0, format=rgba[luma_matte]; \
              [3:v]crop='min(iw,ih)':'min(iw,ih)', pad=2*'min(iw,ih)':2*'min(iw,ih)':'min(iw,ih)'/2:'min(iw,ih)'/2:black, scale=2160:2160, format=rgba[artwork]; \
              [artwork]rotate=2*PI*t*(45/60):c=black, crop=2160:2160:(iw-2160)/2:(ih-2160)/2, scale=2160:2160, format=rgba[label]; \
              [label][luma_matte]alphamerge, colorchannelmixer=aa=0.88, format=rgba[label_masked]; \
              [A][label_masked]overlay, crop=2000:2000:80:80, lut3d='${COLOR_GRADE_LUT}', format=rgba[output]" \
       -map "[output]" -map 4:a \
       -c:v libx264 -pix_fmt yuv420p -r 25 \
       -c:a aac -b:a 320k \
       -shortest \
       VINYL_${ARTWORK%.*}.mp4
# END #