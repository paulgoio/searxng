#!/bin/sh

echo "building theme from master branch privau/searxng-favicon"

echo "clone/pull latest privau/searxng-favicon"
if [ ! -d build ]
then
    git clone https://github.com/privau/searxng-favicon.git build
else
    cd build
    git restore .
    git pull https://github.com/privau/searxng-favicon.git
    cd ..
fi

echo "delete upstream simple theme definitions"
rm -f build/searx/static/themes/simple/src/less/definitions.less build/searx/static/themes/simple/src/less/search.less

echo "copy fork simple theme definitions in place"
cp -v src/less/definitions.less build/searx/static/themes/simple/src/less/definitions.less
cp -v src/less/search.less build/searx/static/themes/simple/src/less/search.less

echo "build themes with upstream scripts"
cd build
make themes.all
cd ..

echo "cp build files back to fork src folder"
rm -rf src/css/*
cp -r -v build/searx/static/themes/simple/css/* src/css/
