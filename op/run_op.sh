#! /bin/bash
IMAGE_TAG=inacademia/op:v1

# Build the docker image if needed
if [[ "$(docker images -q inacademia/op:v1 2> /dev/null)" == "" ]]; then
  docker build -t $IMAGE_TAG .
fi

# Start SSP IDP
docker run --net inacademia.local --ip 172.172.172.2 -e BACKEND_PORT=tcp://172.172.172.1:80 -e REWRITE_LOCATION=0 \
	--add-host=svs.inacademia.local:172.172.172.1 \
	--add-host=op.inacademia.local:172.172.172.2 \
	--add-host=rp.inacademia.local:172.172.172.100 \
	--add-host=idp.inacademia.local:172.172.172.200 \
	--hostname op.inacademia.local \
	--expose 80 \
	--expose 443 \
	-v /home/niels/dev/inacademia-dev/op/config/etc/ssl:/etc/ssl \
	-p 443:443 \
	-it $IMAGE_TAG
