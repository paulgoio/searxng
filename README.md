# Searx

builds custom searxng container with a changed simple theme and settings.yml; This project builds on top of https://github.com/searxng/searxng (searxng vs searx: https://github.com/searxng/searxng/issues/46).

Check out https://start.paulgo.io for a deployed server with this container



### Development

* Clone this repo: ```git clone https://github.com/paulgoio/searx.git```

* After making your changes make sure to update `searx.min.css` as well as `searx-rtl.min.css` by running `update.sh` (docker needed)

* You can build the docker container locally by running: ```docker build --pull -f ./Dockerfile -t searx-dev:latest .```

* Debug the local container with: ```docker run -it --rm -p 8080:8080 searx-dev:latest```



### Environment Variables (all optional: if not set -> using default settings)

* ```IMAGE_PROXY``` : enable the image proxyfication through searx; If `MORTY_KEY` and `MORTY_URL` is set morty is used instead of the built in /image_proxy, otherwise the built in image proxy is used (set this to `true`)

* ```MORTY_KEY``` : set the morty key here (a secret key that is shared by searx and morty, for example `1234`)

* ```MORTY_URL``` : set the full URL where the morty instance is reachable (for example `https://morty.example.com/morty`)

* ```DOMAIN``` : set the domain for instance name and the base url (for example example.org would have `https://example.org/` as base)

* ```CONTACT``` : set instance maintainer contact (for example `mailto:user@example.org`)

* ```ISSUE_URL``` : set issue url for custom searx repo (for example `https://github.com/paulgoio/searx/issues` !Without trailing /)

* ```GIT_URL``` : set git url for custom searx repo (for example `https://github.com/paulgoio/searx`)

* ```GIT_BRANCH``` : set git branch for custom searx repo (for example `main`)



### Basic Example

* ```docker run -it --rm -p 8080:8080 paulgoio/searx:production```

* After that just visit http://127.0.0.1:8080 in your browser and stop the server with ctrl-c



### Production Setup

Check out the `docker-compose.yml` file in this repo for reference (it also uses a custom filtron image for a complete stateless setup)
