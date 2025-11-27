# FFMPEG command to make social neda promo from album artwork + song snippet...


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




