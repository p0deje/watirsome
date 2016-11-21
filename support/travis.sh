#!/bin/bash -ex

mkdir bin/

# https://omahaproxy.appspot.com
# https://commondatastorage.googleapis.com/chromium-browser-snapshots/index.html?prefix=Linux_x64/
CHROME_REVISION=386257
curl -L -O "http://commondatastorage.googleapis.com/chromium-browser-snapshots/Linux_x64/${CHROME_REVISION}/chrome-linux.zip"
unzip chrome-linux.zip
ln -s "$(pwd)/chrome-linux/chrome" "$(pwd)/bin/google-chrome"

curl -L -O "http://chromedriver.storage.googleapis.com/2.21/chromedriver_linux64.zip"
unzip chromedriver_linux64.zip
ln -s "$(pwd)/chromedriver" "$(pwd)/bin/chromedriver"
