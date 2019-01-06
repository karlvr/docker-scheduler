#!/bin/bash -eu

# being able to write to /dev/stdout not only by root user
# https://github.com/moby/moby/issues/31243
# So rsyslog can write to /dev/stdout
chmod o+w /dev/stdout

rsyslogd

# Run without exec so the container stops when asked
"$@" &
trap "kill $!" SIGINT SIGTERM
wait
exit $?
