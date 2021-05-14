FROM searx/searx:latest
RUN rm -rf /usr/local/searx/searx/static/themes/simple/css/* && rm -rf /usr/local/searx/searx/static/themes/simple/img/*
COPY ./src/searx /etc/searx
COPY ./src/css /usr/local/searx/searx/static/themes/simple/css
COPY ./src/img /usr/local/searx/searx/static/themes/simple/img
