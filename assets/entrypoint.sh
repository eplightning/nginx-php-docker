#!/bin/bash -e

# passwd
if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
   echo "${USER_NAME:-app}:x:$(id -u):0:${USER_NAME:-app} user:/app:/usr/sbin/nologin" >> /etc/passwd
 fi
fi

if [ -z "$1" ]; then
  exec supervisord --configuration /app/assets/supervisord.conf
else
  exec "${@:1}"
fi
