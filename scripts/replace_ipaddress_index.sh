#!/bin/bash

INDEX_HTML=/var/lib/tomcat7/webapps/ROOT/as-demo/index.html

# HOSTNAME=$(hostname)
IPADDRESS=$(ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')

# sed -i "s/MyHostname/${HOSTNAME}/g" ${INDEX_HTML}
sed -i "s/MyIPAddress/${IPADDRESS}/g" ${INDEX_HTML}

service tomcat7 restart
