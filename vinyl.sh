# FFMPEG command to continuously rotate a PNG file, clockwise, at 45rpm, for 90 seconds and output an mp4 file
# -preset slow -crf 18 -r 25 -movflags +faststart
# lut3d='3dluts_vinyl/2.cube', 


ARTWORK=ARTWORK6.DNG
BACKGROUND=footage/C0002.MP4
MUSIC=MUSIC.wav
RECORD_RPM=45

ffmpeg -loop 1 -i ${ARTWORK} \
       -i ${BACKGROUND} \
       -loop 1 -i mask.png \
       -ss 00:04:29 \
       -i ${MUSIC} \
       -t 3 \
       -filter_complex \
       "[0:v]crop='min(iw,ih)':'min(iw,ih)', scale=1800:1800, format=rgb24[artwork]; \
        [artwork]rotate=2*PI*t*(${RECORD_RPM}/60):c=black, crop=1800:1800:(iw-1800)/2:(ih-1800)/2, scale=1800:1800, format=rgb24[label]; \
        [1:v]crop='min(iw,ih)':'min(iw,ih)', scale=1800:1800, format=rgb24, split=2[bg][to_luma]; \
        [2:v]format=rgb24[garbage]; \
        [to_luma]hue=s=0, eq=contrast=30:brightness=0, format=rgb24[luma_matte]; \
        [garbage][luma_matte]blend=all_mode=darken, format=rgb24[label_mask]; \
        [label_mask][label]blend=all_mode=darken, format=rgb24[label_masked]; \
        [bg][label_masked]blend=all_mode=multiply:all_opacity=0.9, lut3d='3dluts_vinyl/5.cube', format=rgb24[output]" \
       -map "[output]" -map 3:a \
       -c:v libx264 -pix_fmt yuv420p -r 25 \
       -c:a aac -b:a 320k \
       -shortest \
       VINYL_${ARTWORK%.*}.mp4