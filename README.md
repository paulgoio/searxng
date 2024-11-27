# SearXNG

builds custom SearXNG container with a changed simple theme and settings.yml; This project builds on top of https://github.com/searxng/searxng



### Project Links

Production Server / Instance : https://paulgo.io

Docker Hub : https://hub.docker.com/r/paulgoio/searxng

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

* You can build the docker container locally by running (check out base branch for the alpine base with the needed python packages): ```docker build --pull -f ./Dockerfile -t searxng-dev:latest .```

* Debug the local container with: ```docker run -it --rm -p 8080:8080 searxng-dev:latest```



### Environment Variables (all optional: if not set -> using default settings)

* ```IMAGE_PROXY``` : enable the image proxyfication through SearXNG; the built-in image proxy is used (set this to `true`)

* ```REDIS_URL``` : set the URL of Redis server to store data for limiter plugin (for example `redis://redis:6379/0` or `unix:///usr/local/searxng-redis/run/redis.sock?db=0`)

* ```LIMITER``` : limit bot traffic; this option also requires Redis to be set up

* ```METRICS_PASSWORD```: enable the /metrics endpoint with basic auth for ingestion via prometheus (username can be any string, password is the set password, for example: `pass123`, `|` is not allowed in the password)

* ```BASE_URL``` : set the base URL (for example example.org would have `https://example.org/` as base)

* ```NAME``` : set the name of the instance, which is for example displayed in the title of the site (for example `PaulGO`)

* ```PRIVACYPOLICY``` : set URL of privacy policy of the instance (for example `https://example.org/privacy-policy`)

* ```CONTACT``` : set instance maintainer contact (for example `mailto:user@example.org`)

* ```ISSUE_URL``` : set issue URL for custom SearXNG repo (for example `https://github.com/paulgoio/searxng/issues` !Without trailing /)

* ```GIT_URL``` : set git URL for custom SearXNG repo (for example `https://github.com/paulgoio/searxng`)

* ```GIT_BRANCH``` : set git branch for custom SearXNG repo (for example `main`)

* ```PROXY``` : set proxy servers that are applied as round robin for all engines; separate multiple proxies with a comma (for example `http://example.org:8080,http://proxy.example.net`)

* ```UWSGI_WORKERS``` : set the amount of uwsgi workers (each worker can handle HTTP requests to the server); defaults to the amount of CORS the server has (for example: `4`)

* ```UWSGI_THREADS``` : set the amount of uwsgi threads per worker; so each worker has the amount of threads defined here; defaults to 4 (for example: `4`)

* ```SEARCH_DEFAULT_LANG``` : Set the default language used for search queries. By default, this is set to auto to autodetect the language from the query string (for example `en-US`)

* ```SEARCH_ENGINE_ACCESS_DENIED``` : Set the suspension timeout in seconds if a search engine throws a SEARCH_ENGINE_ACCESS_DENIED exception, by default this value is set to `86400` (e.g. 1 day)

* ```PUBLIC_INSTANCE``` : Set instance as public instance to enable some optional features, that are only relevent to public instances (defaults to false, can be set to `true`)
