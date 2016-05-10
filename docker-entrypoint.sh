#!/bin/sh

[ "$1" = "/bin/sh" ] && exec "$@"
[ "$1" = "/bin/bash" ] && exec "$@"
[ "$1" = "sh" ] && exec "$@"
[ "$1" = "bash" ] && exec "$@"

# set environment
export CLUSTER_NAME=${CLUSTER_NAME:-elasticsearch-default}
export NODE_MASTER=${NODE_MASTER:-true}
export NODE_DATA=${NODE_DATA:-true}
export HTTP_ENABLE=${HTTP_ENABLE:-true}
export SCRIPT_ENABLE=${SCRIPT_ENABLE:-true}
export MULTICAST=${MULTICAST:-false}
export CONFIG_DIR=${CONFIG_DIR:-/elasticsearch/config}
export PLUGINS_DIR=${PLUGINS_DIR:-/elasticsearch/plugins}

export INITIAL_SHARDS=${INITIAL_SHARDS:-1}
export INITIAL_REPLICAS=${INITIAL_REPLICAS:-0}

export MLOCKALL=${MLOCKALL:-false}
if [ "$MLOCKALL" = "true" ]; then
  # allow for memlock
  ulimit -l unlimited
fi

# When running as the root user switch to the user
# that matches the uid and gid of the data folder
# create the user and group if necessary
if [ "$(id -u)" = "0" ]; then
  data_owner="$(stat -c %u /data)"
  data_group="$(stat -c %g /data)"
  addgroup -g "$data_group" elasticsearch || addgroup -S -g "$data_group" elasticsearch || true
  adduser -u "$data_owner" -g "$data_group" -D elasticsearch || adduser -S -u "$data_owner" -g "$data_group" -D elasticsearch || true
  data_owner_name="$(stat -c %U /data)"
  data_group_name="$(stat -c %G /data)"
  for path in /data/data /data/logs "$CONFIG_DIR" "$CONFIG_DIR"/scripts "$PLUGINS_DIR"; do
    mkdir -p "$path"
    chown -R "$data_owner_name":"$data_group_name" "$path";
  done
  sudo -E -u "$data_owner_name" /elasticsearch/bin/elasticsearch "$@"
else
  for path in /data/data /data/logs "$CONFIG_DIR" "$CONFIG_DIR"/scripts "$PLUGINS_DIR"; do
    mkdir -p "$path";
  done
  exec /elasticsearch/bin/elasticsearch "$@"
fi