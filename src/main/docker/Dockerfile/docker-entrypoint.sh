#!/bin/bash

set -e


# Drop root privileges if we are running elasticsearch
# allow the container to be started with `--user`
if [  "$(id -u)" = '0' ]; then
	# Change the ownership of user-mutable directories to elasticsearch
	for path in \
		/usr/share/elasticsearch/data \
		/usr/share/elasticsearch/logs \
	; do
		chown -R elasticsearch:elasticsearch "$path"
	done

	nohup gosu elasticsearch elasticsearch &
else
   nohup exec elasticsearch &
fi

printf  "waiting for ElasticSearch"
COUNTER=0
until [ ${COUNTER} -lt 20 ] || [ $(curl --output /dev/null --silent --head --fail http://localhost:9200) ]; do
    printf '.'
    COUNTER=${COUNTER}+1
    printf "."
    sleep 5
done

if [ ${COUNTER} -eq 20 ]; then
  echo "Failed to wait for ElasticSearch"
fi

# As argument is not related to elasticsearch,
# then assume that user wants to run his own process,
# for example a `bash` shell to explore this image
exec "$@"
