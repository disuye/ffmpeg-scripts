# FFMPEG command to continuously rotate a PNG file, clockwise, at 45rpm, for 90 seconds and output an mp4 file
# -preset slow -crf 18 -r 25 -movflags +faststart

RECORD_RPM=45;
ARTWORK=ARTWORK5.jpg;
ffmpeg -loop 1 -i ${ARTWORK} \
       -t 20 \
       -filter_complex "[0:v]crop='min(iw,ih)':'min(iw,ih)', scale=1800:1800[artwork]; [artwork]rotate=(60/${RECORD_RPM})*t:c=black" \
       -c:v libx264 -pix_fmt yuv420p -r 25 \
       VINYL_${ARTWORK%.*}.mp4