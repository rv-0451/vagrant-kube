#!/usr/bin/env bash

apt-get update
apt-get install containerd -y

mkdir -p /etc/containerd
containerd config default /etc/containerd/config.toml

# install k8s internals
apt-get install -y apt-transport-https gnupg2 curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubelet kubeadm kubectl 

# setup sysctl
cat >> /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
echo '1' > /proc/sys/net/ipv4/ip_forward
sysctl --system

# load necessary modules 
modprobe overlay
modprobe br_netfilter

# setup insecure registry
mkdir -p /etc/containerd/certs.d/192.168.100.20:5000

cat >> /etc/containerd/certs.d/192.168.100.20:5000/hosts.toml <<EOF
server = "http://192.168.100.20:5000"

[host."http://192.168.100.20:5000"]
  skip_verify = true
EOF

cat >> /etc/containerd/config.toml <<EOF
version = 2

[plugins."io.containerd.grpc.v1.cri".registry]
   config_path = "/etc/containerd/certs.d"
EOF

systemctl restart containerd
service systemd-resolved restart
crictl config --set runtime-endpoint=unix:///run/containerd/containerd.sock --set image-endpoint=unix:///run/containerd/containerd.sock
