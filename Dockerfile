# use alpine as base for searx and set workdir as well as env vars
FROM alpine:edge

COPY ./requirements.txt .

# install build deps and git clone searxng as well as setting the version
RUN apk -U upgrade \
&& apk add --no-cache -t build-dependencies alpine-base build-base python3-dev py3-pip tar \
&& apk add --no-cache alpine-baselayout ca-certificates-bundle python3 wget tini brotli git bash su-exec \
&& pip3 install --break-system-packages --no-cache -r requirements.txt \
&& pip3 install --break-system-packages --no-cache "granian~=2.0" \
&& apk del build-dependencies \
&& rm -rf /var/cache/apk/* /root/.cache
