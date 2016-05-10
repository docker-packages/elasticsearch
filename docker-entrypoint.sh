#!/usr/bin/dumb-init /bin/bash

set -e

# Add elasticsearch as command if needed
if [ "${1:0:1}" = '-' ]; then
	set -- elasticsearch "$@"
fi

# set environment
export CLUSTER_NAME=${CLUSTER_NAME:-es-default}
export NODE_MASTER=${NODE_MASTER:-true}
export NODE_DATA=${NODE_DATA:-true}
export HTTP_ENABLE=${HTTP_ENABLE:-true}
export SCRIPT_ENABLE=${SCRIPT_ENABLE:-true}
export MULTICAST=${MULTICAST:-false}

export INITIAL_SHARDS=${INITIAL_SHARDS:-1}
export INITIAL_REPLICAS=${INITIAL_REPLICAS:-0}

export MLOCKALL=${MLOCKALL:-false}
if [ "$MLOCKALL" = "true" ]; then
  # allow for memlock
  ulimit -l unlimited
fi

# Drop root privileges if we are running elasticsearch
# allow the container to be started with `--user`
if [ "$1" = 'elasticsearch' -a "$(id -u)" = '0' ]; then
	# Change the ownership of /usr/share/elasticsearch/data to elasticsearch
	chown -R elasticsearch:elasticsearch /opt/elasticsearch/data

	set -- gosu elasticsearch "$@"
fi

exec "$@"