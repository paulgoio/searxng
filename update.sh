#!/bin/sh

echo "building theme from master branch searxng/searxng"

echo "clone/pull latest searxng/searxng"
if [ ! -d build ]
then
    git clone https://github.com/searxng/searxng.git build
else
    cd build
    git restore .
    git pull https://github.com/searxng/searxng.git
    cd ..
fi

echo "delete upstream simple theme definitions"
rm -f build/client/simple/src/less/definitions.less build/client/simple/src/less/search.less

echo "Replace fork simple theme definitions."
cp -v src/less/* build/client/simple/src/less/

echo "build themes with upstream scripts"
cd build
make themes.all
cd ..

echo "cp build files back to fork src folder"
rm -rf src/css/*
cp -r -v build/searx/static/themes/simple/css/* src/css/
