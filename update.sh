#!/bin/sh

echo "building theme from master branch searxng/searxng and update requirements.txt"

echo "init and pulling git submodule for upstream searxng"
git submodule init upstream/
git submodule update upstream/
git pull --recurse-submodules

echo "delete upstream simple theme definitions"
rm -f upstream/client/simple/src/less/definitions.less upstream/client/simple/src/less/search.less

echo "Replace fork simple theme definitions."
cp -v src/less/* upstream/client/simple/src/less/

echo "build themes with upstream scripts"
cd upstream
./manage vite.simple.build
cd ..

echo "cp build files back to fork src folder"
rm -rf src/css/*
cp -r -v upstream/searx/static/themes/simple/*.css src/css/

echo "update requirements from upstream searxng" 
cat upstream/requirements.txt upstream/requirements-server.txt > requirements.txt

echo "cleanup upstream searxng submodule"
git submodule update --force upstream/
