#!/bin/sh

echo "update minified css from searx.css and searx-rtl.css"
docker pull tdewolff/minify:latest
docker run -it --rm -v ${PWD}/src/css:/css tdewolff/minify:latest sh -c "cd /css && minify searx.css -o searx.min.css && minify searx-rtl.css -o searx-rtl.min.css"
