#!/bin/bash
##ssarea script
DATE=$(date +%Y-%m-%d-%H:%M:%S)
YEAR=$(date +%Y)
MONTH=$(date +%m)
DIRNAME="/home/maciej/Pictures/${YEAR}/${MONTH}"
FILENAME="${DIRNAME}/Screenshot-${DATE}.png"

## makes dir if it doesn't exist
mkdir -p $DIRNAME
## take screenshot
maim $FILENAME

## copy file to clipboard
xclip -selection clipboard -t image/png -i $FILENAME
