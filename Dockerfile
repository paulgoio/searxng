FROM searx/searx:latest
RUN rm -rf /usr/local/searx/searx/static/themes/simple/css/* && rm -rf /usr/local/searx/searx/static/themes/simple/img/*
COPY ./searx /etc/searx
COPY ./css /usr/local/searx/searx/static/themes/simple/css
COPY ./img /usr/local/searx/searx/static/themes/simple/img
