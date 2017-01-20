#!/usr/bin/env bash

set -e

mkdir -p /etc/squid

HTTP_PROXY_HOST=$(echo "${HTTP_PROXY}" | sed -nE "s/^http(s)?:\/\/(.+):([0-9]+)$/\2/p")
HTTP_PROXY_PORT=$(echo "${HTTP_PROXY}" | sed -nE "s/^http(s)?:\/\/(.+):([0-9]+)$/\3/p")

ACL_LOCALNET=""
for net in ${NO_PROXY_NETWORKS}; do
    ACL_LOCALNET="${ACL_LOCALNET}acl localnet-dst dst ${net}
"
done

cat > /etc/squid/squid.conf <<EOF
#
# Recommended minimum configuration:
#

# Example rule allowing access from your local networks.
# Adapt to list your (internal) IP networks from where browsing
# should be allowed
acl localnet src 10.0.0.0/8     # RFC1918 possible internal network
acl localnet src 172.16.0.0/12  # RFC1918 possible internal network
acl localnet src 192.168.0.0/16 # RFC1918 possible internal network
acl localnet src fc00::/7       # RFC 4193 local private network range
acl localnet src fe80::/10      # RFC 4291 link-local (directly plugged) machines

${ACL_LOCALNET}

acl SSL_ports port 443
acl Safe_ports port 80          # http
acl Safe_ports port 21          # ftp
acl Safe_ports port 443         # https
acl Safe_ports port 70          # gopher
acl Safe_ports port 210         # wais
acl Safe_ports port 1025-65535  # unregistered ports
acl Safe_ports port 280         # http-mgmt
acl Safe_ports port 488         # gss-http
acl Safe_ports port 591         # filemaker
acl Safe_ports port 777         # multiling http
acl CONNECT method CONNECT

#
# Recommended minimum Access Permission configuration:
#
# Deny requests to certain unsafe ports
http_access deny !Safe_ports

# Deny CONNECT to other than secure SSL ports
http_access deny CONNECT !SSL_ports

# Only allow cachemgr access from localhost
http_access allow localhost manager
http_access deny manager

# We strongly recommend the following be uncommented to protect innocent
# web applications running on the proxy server who think the only
# one who can access services on "localhost" is a local user
#http_access deny to_localhost

#
# INSERT YOUR OWN RULE(S) HERE TO ALLOW ACCESS FROM YOUR CLIENTS
#

# Example rule allowing access from your local networks.
# Adapt localnet in the ACL section to list your (internal) IP networks
# from where browsing should be allowed
http_access allow localnet
http_access allow localhost

# And finally deny all other access to this proxy
http_access deny all

# set fake hostname
visible_hostname squid-proxy

# Squid normally listens to port 3128
http_port 3128

# don't cache anything
cache deny all

# logging
access_log /dev/null
cache_store_log none
cache_log /dev/null

# Leave coredumps in the first cache dir
coredump_dir /var/cache/squid

#
# Add any of your own refresh_pattern entries above these.
#
refresh_pattern ^ftp:           1440    20%     10080
refresh_pattern ^gopher:        1440    0%      1440
refresh_pattern -i (/cgi-bin/|\?) 0     0%      0
refresh_pattern .               0       20%     4320

#
# Upstream proxy settings
#
cache_peer ${HTTP_PROXY_HOST} parent ${HTTP_PROXY_PORT} 0 no-query default name=upstream
cache_peer_access upstream deny localnet-dst
never_direct deny localnet
never_direct allow all
EOF

exec squid -f /etc/squid/squid.conf -N