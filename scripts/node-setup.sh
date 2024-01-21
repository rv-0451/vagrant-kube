#!/usr/bin/env bash

sed -i -e 's/#DNS=/DNS=8.8.8.8/' /etc/systemd/resolved.conf

cat >> /etc/hosts <<EOF
192.168.100.10 master-node
192.168.100.11 worker-node1
192.168.100.12 worker-node2
192.168.100.20 registry-node
EOF

apt-get update
apt-get install -y git wget vim curl
