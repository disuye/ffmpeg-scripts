#!/bin/bash
# FFMPEG command to create  social media promo video using album artwork + song snippet + waveform oscilloscope...
# ARTWORK = the image file, can be any format & size, will be scaled & cropped to 1800x1800 pixels
# MUSIC = the audio file, be any audio format, *.wav gives best results
# -ss = fast forward thru the audio file to the beginning of the song preview 
# -t = the duration of the video output, 90 seconds is default 
# lut3d = location of a 3dLUT colour grading file (optional, can be left blank)
# Optional special effects... Fake film grain: noise=c0s=20:c0f=t+u
# Do not forget to make this script executable: chmod +x promo_maker-image.sh
# github.com @disuye

ffmpeg -loop 1 \
       -i ARTWORK2.jpg \
       -ss 00:04:29 \
       -i MUSIC.wav \
       -t 90 \
       -filter_complex \
              "[0:v]crop='min(iw,ih)':'min(iw,ih)', scale=1800:1800[artwork]; \
              [1:a]showwaves=s=900x300:mode=p2p:colors=white:draw=full, scale=1800:1800, rgbashift=rh=1:gh=-1[wave]; \
              [artwork][wave]blend=all_mode=screen:all_opacity=1.0, lut3d='3dluts/A9.cube', format=rgb24[output]" \
       -map "[output]" -map 1:a \
       -c:v libx264 -pix_fmt yuv420p \
       -c:a aac -b:a 320k \
       -shortest \
       VIDEO_OUTPUT.mp4