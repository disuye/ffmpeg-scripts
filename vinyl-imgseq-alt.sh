# USER VARIABLES
ARTWORK=f3.PNG
MUSIC=SlaterL2.wav
MUSIC_START=00:00:00
COLOR_GRADE_LUT=3dluts_vinyl/7.cube
OUTPUT_DURATION=551

# SCRIPT ADMIN
BACKGROUND=footage/img_seq/frame_%04d.png
MASK_FILE=mask.png
MATTE_FILE=matte.png
# RPM45=(t*(3*PI/2), 2*PI)
# RPM33=mod(t*(10*PI/9), 2*PI)

ffmpeg -y \
       -stream_loop -1 -r 25 -i "${BACKGROUND}" \
       -loop 1 -i "${MASK_FILE}" \
       -loop 1 -i "${MATTE_FILE}" \
       -loop 1 -i "${ARTWORK}" \
       -ss "${MUSIC_START}" -i "${MUSIC}" \
       -t ${OUTPUT_DURATION} \
       -filter_complex "[0:v] \
          crop='min(iw,ih)':'min(iw,ih)', \
          pad='min(iw,ih)'+20:'min(iw,ih)'+20:10:20:green, \
          scale=2160:2160, \
          split=2[BG_A][BG_B]; \
        \
        [BG_B] \
          hue=s=0, \
          eq=contrast=500:brightness=0.8, \
          boxblur=3:1:1[BLURRED_GRAY]; \
        \
        [BLURRED_GRAY][1:v] \
          blend=all_mode=darken[GARBAGE_MASKED]; \
        \
        [GARBAGE_MASKED][2:v] \
          blend=all_mode=lighten, \
          hue=s=0[LUMA_MATTE]; \
        \
        [3:v] \
          crop='min(iw,ih)':'min(iw,ih)', \
          pad=2*'min(iw,ih)':2*'min(iw,ih)':'min(iw,ih)'/2:'min(iw,ih)'/2:black, \
          scale=2160:2160[ARTWORK_PAD]; \
        \
        [ARTWORK_PAD] \
          rotate='mod(t*(3*PI/2), 2*PI)':c=black, \
          crop=2160:2160:(iw-2160)/2:(ih-2160)/2, \
          scale=2160:2160[LABEL]; \
        \
        [LABEL][LUMA_MATTE] \
          alphamerge, \
          colorchannelmixer=aa=0.88[LABEL_MASKED]; \
        \
        [BG_A][LABEL_MASKED] \
          overlay, \
          crop=2000:2000:80:80, \
          lut3d='${COLOR_GRADE_LUT}', \
          format=yuv420p[output]" \
       -map "[output]" -map 4:a \
       -c:v libx264 -preset medium -crf 23 -r 25 \
       -c:a aac -b:a 320k \
       -shortest \
       "VINYL_${ARTWORK%.*}.mp4"
# END #