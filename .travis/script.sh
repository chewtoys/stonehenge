#!/bin/bash

# exit when any command fails
set -e

echo "Distribution: ${TRAVIS_DIST}"

docker --version
docker-compose --version
make debug
ping -c 1 docker.sh
cat /etc/resolv.conf
cat /etc/systemd/resolved.conf

# Start up Stonehenge
make up

# Install mkcert
make mkcert-install

# Install SSL-sertificate
if [[ ${TRAVIS_DIST} == 'xenial' ]]; then
  # See https://github.com/FiloSottile/mkcert/pull/193
  sudo make certs
else
  make certs
fi

ping -c 1 docker.sh
cat /etc/resolv.conf
cat /etc/systemd/resolved.conf

# Check that we can connect to local Portainer
#curl -Is https://portainer.docker.sh | head -1
echo "CURL portainer for checking access starts"
curl -s https://portainer.docker.sh | grep Portainer
echo "CURL portainer for checking access ends"

# Tear down Stonehenge
make down

# Check that DNS work still
curl -Is https://www.google.com | head -1
