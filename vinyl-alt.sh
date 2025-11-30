#!/bin/bash
# USER VARIABLES
ARTWORK=ARTWORK66.PNG
MUSIC=MUSIC.wav
MUSIC_START=00:05:00
COLOR_GRADE_LUT= #3dluts_vinyl/5.cube
OUTPUT_DURATION=4

# SCRIPT ADMIN
BACKGROUND=footage/C0002.MP4
MASK_FILE=mask.png
MATTE_FILE=matte.png
MUCK_FILE=muck.png
SHADOWS_FILE=shadows.png
# RPM45=mod(t*(3*PI/2), 2*PI)
# RPM33=mod(t*(10*PI/9), 2*PI)

# PICK RANDOM START FRAME FOR BACKGROUND
RANDOM_START=$(( RANDOM % 5000 + 1 )); \
printf -v RANDOM_START "%02d:%02d:%02d" $((RANDOM_START/108000)) $(((RANDOM_START%108000)/1800)) $(((RANDOM_START/30)%60)); \
echo $RANDOM_START

# VIDEO COMPOSITING START
ffmpeg -y -hide_banner -loglevel error -stats \
       -noaccurate_seek \
       -ss "${RANDOM_START}" \
       -i "${BACKGROUND}" \
       -loop 1 -i "${MASK_FILE}" \
       -loop 1 -i "${MATTE_FILE}" \
       -loop 1 -i "${ARTWORK}" \
       -ss "${MUSIC_START}" -i "${MUSIC}" \
       -loop 1 -i "${MUCK_FILE}" \
       -loop 1 -i "${SHADOWS_FILE}" \
       -t ${OUTPUT_DURATION} \
       -filter_complex "[0:v] \
          crop='min(iw,ih)':'min(iw,ih)', \
          pad='min(iw,ih)'+20:'min(iw,ih)'+20:10:20:green, \
          scale=2160:2160, \
          trim=duration=33, \
          setpts=PTS-STARTPTS, \
          loop=-1:33:0, \
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
        [ARTWORK_PAD][5:v] \
          blend=all_mode=multiply[ARTWORK_MUCKED]; \
        \
        [ARTWORK_MUCKED] \
          rotate='mod(t*(3*PI/2), 2*PI)':c=black, \
          crop=2160:2160:(iw-2160)/2:(ih-2160)/2, \
          scale=2160:2160[ARTWORK_SPIN]; \
        \
        [ARTWORK_SPIN][6:v] \
          blend=all_mode=multiply[LABEL]; \
        \
        [LABEL][LUMA_MATTE] \
          alphamerge, \
          colorchannelmixer=aa=1.0[LABEL_MASKED]; \
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