#!/bin/sh
/opt/tengine/sbin/nginx -g "daemon off;" &

tail -F /opt/tengine/logs/access.log /opt/tengine/logs/error.log

