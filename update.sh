#!/bin/sh
set -e # <-- CRITICAL: Fail immediately if any command fails

# this file is meant to be run by renovate when updating the git submodule upstream/
echo "building theme from master branch searxng/searxng and update requirements.txt"

echo "init and update submodule for upstream searxng"
git submodule update --init --remote upstream/

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
git submodule foreach --recursive 'git reset --hard HEAD && git clean -fd'
