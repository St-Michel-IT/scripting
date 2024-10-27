#!/usr/bin/bash
# Constants as readonly variables
readonly IMAGE_FOLDER="doc/image"
# If pngcrush is not installed crash the script
if ! command -v pngcrush &>/dev/null; then
  echo "pngcrush is not installed. Please install it."
  exit 1
fi
# Compress all png images in the doc/image directory inplace
find $IMAGE_FOLDER -name "*.png" -exec pngcrush -ow -reduce -brute {} \;
# Same as the two steps above but with from jpg and jpegoptim
if ! command -v jpegoptim &>/dev/null; then
  echo "jpegoptim is not installed. Please install it."
  exit 1
fi
find $IMAGE_FOLDER -name "*.jpg" -exec jpegoptim --strip-all {} \;
