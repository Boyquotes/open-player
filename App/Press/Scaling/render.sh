#!/bin/bash

ffmpeg -i frame%d.png -r 10 -vf "scale=1200:800:force_original_aspect_ratio=decrease,pad=1200:800:-1:-1:color=black" responsive.gif -y

cp frame0.png portrait.png
cp frame40.png landscape.png
