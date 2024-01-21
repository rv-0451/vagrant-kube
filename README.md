# Description

This is a quick way to bootstrap your own VM-based kubernetes cluster (of the latest version) with a private registry for LAB purposes.

## Prerequisites

- `Vagrant`
- `Virtualbox`

## VMs

The following VMs will be created

| IP             | Hostname
| ---            | ---   
| 192.168.100.10 | `master-node` 
| 192.168.100.11 | `worker-node1`
| 192.168.100.12 | `worker-node2` 
| 192.168.100.20 | `registry-node` 


# Setup kubernetes

## Spin up VMs

```bash
vagrant up
```

## Initialize kubernetes control plane

```bash
make init-controlplane
```

Save and export kubeconfig

```bash
make save-kubeconfig
export KUBECONFIG=$(pwd)/kubeconfig
```

Check cluster status

```bash
$ kubectl get no
NAME          STATUS     ROLES           AGE   VERSION
master-node   NotReady   control-plane   74s   v1.28.2
```

## Join workers

```bash
make join-workers
```

Check cluster status

```bash
NAME           STATUS     ROLES           AGE     VERSION
master-node    NotReady   control-plane   4m39s   v1.28.2
worker-node1   NotReady   <none>          15s     v1.28.2
worker-node2   NotReady   <none>          9s      v1.28.2
```

## Setup kubeconfig on master for future commands

```bash
make setup-kubeconfig
```

## Install calico to kubernetes cluster

```bash
make install-calico
```

Wait for calico to be running

```bash
$ kubectl get po -A | grep calico
kube-system   calico-kube-controllers-7ddc4f45bc-qfq5w   1/1     Running   0          2m51s
kube-system   calico-node-gs7l5                          1/1     Running   0          2m51s
kube-system   calico-node-xll2b                          1/1     Running   0          2m51s
kube-system   calico-node-zvpv5                          1/1     Running   0          2m51s
```

## Install helm on master node

```bash
make install-helm
```

## Install ingress-nginx

There are two options:
- as `Deployment` + `Service` + `NodePort`, in this case your apps will be accessible  through `30080 (http)` or `30443 (https)` ports: `my-app.vagrant.local:30080/api/v1`
- as `DaemonSet` + `HostPort`, in this case your apps will be accessible directly: `my-app.vagrant.local/api/v1`

In both cases it is needed to configure your dns (for example in `/etc/hosts`) to resolve your application's ingress hostname to:
- any node's ip for `Deployment` option, for example master's: `192.168.100.10 my-app.vagrant.local`
- any (or both) worker node's ip for `DaemonSet` option, for example: `192.168.100.11 my-app.vagrant.local`

To install ingress-nginx:

```bash
make install-ingress-deployment
# or
make install-ingress-daemonset
```

In this example the deployment mode was used - wait for ingress-nginx to be running

```bash
$ kubectl get po -A | grep ingress
ingress-nginx   ingress-nginx-controller-76df688779-k2hs5   1/1     Running   0          48s
```

Check it (add `192.168.100.10 my-app.vagrant.local` to your dns)

```bash
$ curl http://my-app.vagrant.local:30080
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx</center>
</body>
</html>

$ curl -k https://my-app.vagrant.local:30443
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx</center>
</body>
</html>
```

# Test private registry

On your local machine add `192.168.100.20:5000` to docker's `insecure-registries` in `/etc/docker/daemon.json`

```json
{
    "insecure-registries" : [ "some-other-registry.private.net:17001", "192.168.100.20:5000" ]
}
```

and restart docker `sudo systemctl restart docker`

To test our private registry pull some image, tag it and push to 192.168.100.20:5000

```bash
docker pull hello-world:latest
# output:
# Status: Image is up to date for hello-world:latest
# docker.io/library/hello-world:latest

docker image tag hello-world:latest 192.168.100.20:5000/hello-world:latest

docker push 192.168.100.20:5000/hello-world:latest
# output:
# The push refers to repository [192.168.100.20:5000/hello-world]
# ac28800ec8bb: Pushed
```
