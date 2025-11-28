# Junk file for hold ideas...


ffmpeg -loop 1 -i ARTWORK.png \
       -i MUSIC.wav \
       -ss 00:02:15 -t 90 \
       -filter_complex \
 "[1:a]showwaves=s=720x1800:mode=p2p:split_channels=0:colors=white:draw=full,noise=c0s=20:c0f=t+u,scale=1800x1800,format=rgb24[wave]; \
  [0:v][wave]blend=all_mode=screen:all_opacity=1.0,rgbashift=rh=1:gh=-1,format=rgb24[v]" \
       -map "[v]" -map 1:a \
       -c:v libx264 -pix_fmt yuv420p \
       -c:a aac -b:a 320k \
       -shortest \
       VIDEO_OUTPUT.mp4





ARTWORK=ARTWORK5.jpg
BACKGROUND=footage/C0002.MP4
MUSIC=MUSIC.wav
RECORD_RPM=45

ffmpeg -loop 1 -i ${ARTWORK} \
       -i ${BACKGROUND} \
       -ss 00:04:29 \
       -i ${MUSIC} \
       -t 10 \
       -filter_complex \
       "[0:v]crop='min(iw,ih)':'min(iw,ih)', scale=1800:1800[artwork]; \
        [artwork]rotate=2*PI*t*(${RECORD_RPM}/60):c=black, crop=1800:1800:(iw-1800)/2:(ih-1800)/2, scale=1800:1800[label]; \
        [1:v]crop='min(iw,ih)':'min(iw,ih)', scale=1800:1800[bg]; \
        [bg][label]blend=all_mode=multiply, lut3d='3dluts_vinyl/2.cube', format=rgb24[output]" \
       -map "[output]" -map 2:a \
       -c:v libx264 -pix_fmt yuv420p -r 25 \
       -c:a aac -b:a 320k \
       -shortest \
       VINYL_${ARTWORK%.*}.mp4








       ffmpeg -loop 1 -i "$ARTWORK" \
       -i "$BACKGROUND" \
       -ss 00:04:29 -i "$MUSIC" \
       -t 10 \
       -filter_complex \
"[1:v]crop='min(iw,ih)':'min(iw,ih)',scale=1800:1800,format=gray,eq=contrast=32[mask_base]; \
 [mask_base]split=2[mask][bg_scaled]; \
 [0:v]crop='min(iw,ih)':'min(iw,ih)',scale=1800:1800,\
      rotate=2*PI*t*($RECORD_RPM/60):ow=1800:oh=1800:c=black[label]; \
 [label][mask]blend=all_mode=multiply[label_masked]; \
 [bg_scaled][label_masked]blend=all_mode=overlay,\
      lut3d='3dluts_vinyl/2.cube',format=rgb24[output]" \
-map "[output]" -map 2:a \
-c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p -r 25 \
-c:a aac -b:a 320k -shortest \
"VINYL_${ARTWORK%.*}.mp4"


