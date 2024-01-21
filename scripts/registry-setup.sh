#!/usr/bin/env bash

# install registry
apt-get install docker.io docker-registry apache2-utils -y

# setup registry
cat >> /etc/docker/daemon.json <<EOF
{
    "insecure-registries" : [ "192.168.100.20:5000" ]
}
EOF

# open port
ufw allow 5000/tcp

# remove auth from docker registry config
python3 -c 'import yaml; c="/etc/docker/registry/config.yml"; y=yaml.safe_load(open(c)); y.pop("auth", None); yaml.dump(y,open(c,"w"))'

systemctl restart docker
systemctl restart docker-registry
