# Searx

builds custom searx container with a changed simple theme and settings.yml; This project builds on top of https://github.com/searx/searx.

Check out https://start.paulgo.io for a deployed server with this container


### Environment Variables (all optional: if not set -> using default settings)

* ```MORTY_KEY``` : set the morty key in the settings.yml file (it also enables/disables image prozy)

* ```DOMAIN``` : set the domain for instance name and morty, as well as the base url (for example example.org would have `https://example.org/` as base and `https://example.org/morty` as morty url)

* ```CONTACT``` : set instance maintainer contact (for example `mailto:user@example.org`)

* ```TWITTER``` : set twitter user (for example `paul_braeuning`)

* ```GIT_URL``` : set git and issue url for custom searx repo (for example `https://github.com/paulgoio/searx` !Without trailing /)


### Basic Example

* ```docker run -it --rm --name paulgoio_searx -p 8080:8080 paulgoio/searx:production```

* After that just visit http://127.0.0.1:8080 in your browser and stop the server with ctrl-c


### Production Setup

Check out the `docker-compose.yml` file in this repo for reference (it also uses a custom filtron image for a complete stateless setup)
