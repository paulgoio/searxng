# Example Squid Proxy Config

This are example config files for setting up squid proxy with a IPv6 /64 subnet to use random IPv6 addresses from that net.

The script has some small modifications and is from: https://github.com/BackInBash/RPIPv6.



### Setup

* Install squid proxy on host and make sure to set a /64 network on your outgoing interface

* copy the `99-searxng.conf` and `rpipv6.sh` file to `/etc/squid/conf.d` and make sure to set your Ipv6 range at permitserver acl and set your IPv4 addresses or comment out the tcp outgoing section

* copy systemctl service file `rpipv6.service` to `/etc/systemd/system`

* enable squid and rpipv6 service: `systemctl enable --now squid` `systemctl enable --now rpipv6`

* You can test the setup with curl for example; on the server: `curl -x http://[::1]:3128 https://ifconfig.me/ip`

* To use the proxy in a docker container; use docker inspect to get the gateway IP of a docker network a container is in: `docker network inspect {network name}` and use that IP for proxy requests from inside a container
