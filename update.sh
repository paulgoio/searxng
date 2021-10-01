#!/bin/sh

echo "update minified css from searxng.css and searxng-rtl.css"
docker pull tdewolff/minify:latest
docker run -it --rm -v ${PWD}/src/css:/css tdewolff/minify:latest sh -c "cd /css && minify searxng.css -o searxng.min.css && minify searxng-rtl.css -o searxng-rtl.min.css"
