# SearXNG

builds custom SearXNG container with a changed simple theme, settings.yml and bundled with filtron binary; This project builds on top of https://github.com/searxng/searxng (SearXNG vs SearX: https://github.com/searxng/searxng/issues/46) as well as https://github.com/dalf/filtron.



### Project Links

Production Server / Instance : https://paulgo.io

DockerHub : https://hub.docker.com/r/paulgoio/searxng

GitHub : https://github.com/paulgoio/searxng

GitLab : https://paulgo.dev/paulgoio/searxng



### Basic Example

* ```docker run -it --rm -p 8080:8080 paulgoio/searxng:production```

* After that just visit http://127.0.0.1:8080 in your browser and stop the server with ctrl-c



### Production Setup

Check out the `docker-compose.yml` file in this repo for reference



### Development

* Clone this repo: ```git clone https://github.com/paulgoio/searxng.git```

* After making your changes in `src/less` make sure to update `src/css` by running `update.sh` (python, npm and make needed)

* You can build the docker container locally by running (check out base branch for the alpine base with the needed python packages and filtron branch for the filtron binary build which this image is using): ```docker build --pull -f ./Dockerfile -t searxng-dev:latest .```

* Debug the local container with: ```docker run -it --rm -p 8080:8080 searxng-dev:latest```



### Environment Variables (all optional: if not set -> using default settings)

* ```FILTRON``` : set this to `true` to run filtron binary on startup; filtron is a basic rate limiter and bot protection (do not use this with a load balancer in front, since rate limiting wont be effective; using dalf/filtron; rules are in src/rule.json, they are from searx/searx-docker with a patch to make the built in image_proxy work properly)

* ```IMAGE_PROXY``` : enable the image proxyfication through SearXNG; If `MORTY_KEY` and `MORTY_URL` is set morty is used instead of the built in /image_proxy, otherwise the built in image proxy is used (set this to `true`)

* ```MORTY_KEY``` : set the morty key here (a secret key that is shared by SearXNG and morty, generate one with `openssl rand -hex 16`)

* ```MORTY_URL``` : set the full URL where the morty instance is reachable (for example `https://morty.example.com/morty`)

* ```REDIS_URL``` : set the URL of redis server to store data for limiter plugin (for example `redis://redis:6379/0` or `unix:///usr/local/searxng-redis/run/redis.sock?db=0`)

* ```LIMITER``` : set the built in filtron alternative; this option also requires redis to be set up

* ```BASE_URL``` : set the base url (for example example.org would have `https://example.org/` as base)

* ```NAME``` : set the name of the instance, which is for example displayed in the title of the site (for example `PaulGO`)

* ```CONTACT``` : set instance maintainer contact (for example `mailto:user@example.org`)

* ```ISSUE_URL``` : set issue url for custom SearXNG repo (for example `https://github.com/paulgoio/searxng/issues` !Without trailing /)

* ```GIT_URL``` : set git url for custom SearXNG repo (for example `https://github.com/paulgoio/searxng`)

* ```GIT_BRANCH``` : set git branch for custom SearXNG repo (for example `main`)
