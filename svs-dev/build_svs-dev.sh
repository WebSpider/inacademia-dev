#! /bin/bash
source svs-dev.cnf

# make sure we have the latest metadata from the IdP
/usr/bin/curl -ksS https://idp.inacademia.local/saml2/idp/metadata.php > config/production/idp.xml || exit 3

# make sure we have the ssh key we can use to pull and push from git
/bin/cp $GIT_KEY_PATH config/id_rsa_inacademia || exit 3

MY_HOST_UID=$(id -g)

# create workdir
mkdir -p workdir || exit 3

# As the build command is being called, we assume we need to build a new image.
# To be sure we therefor first remove existign ones
if [[ "$(docker images -q $IMAGE_TAG 2> /dev/null)" != "" ]]; then
  echo "Removing existing $IMAGE_TAG docker container ..."
  docker rmi -f $IMAGE_TAG
fi

echo "Building  docker container $IMAGE_TAG ..."
# Build the docker image
docker build -t $IMAGE_TAG .

# find the location of configs in current directory structure
RUN_DIR=$PWD
CONFIG_DIR="$RUN_DIR/config"

# Remove existing container
docker rm $CONTAINER_NAME

# Create SVS
docker create -it \
    --name $CONTAINER_NAME \
    --env SATOSA_TAG=$SATOSA_TAG \
    --env SVS_TAG=$SVS_TAG \
    --env MY_HOST_UID=$MY_HOST_UID \
    --env PROXY_PORT=80 \
    --env SATOSA_STATE_ENCRYPTION_KEY=1fa0dafd36d9d2c8401b943sk4kwde954e2016cf3f37fa1f67bbffe6c4f2f78e \
    --env SATOSA_USER_ID_HASH_SALT=6f692915a7df20d9d4be17a70djdieff04585b0ab231825b7a15ed5d6140aa1e \
    -v $CONFIG_DIR/production:/var/svs \
    -v $CONFIG_DIR/cdb:/etc/cdb \
    -v /etc/passwd:/etc/passwd:ro   \
    -v /etc/group:/etc/group:ro \
    -v $PWD/workdir:/opt/workdir \
    -e DATA_DIR=/var/svs \
    -w /var/svs \
    --net inacademia.local \
    --ip 172.172.172.1 \
    --add-host=svs.inacademia.local:172.172.172.1 \
    --add-host=op.inacademia.local:172.172.172.2 \
    --add-host=rp.inacademia.local:172.172.172.100 \
    --add-host=idp.inacademia.local:172.172.172.200 \
    --hostname svs.inacademia.local \
    --expose 80 \
    --expose 443 \
    $IMAGE_TAG

# Remove the key so it does not get into git by accident
rm config/id_rsa_inacademia
