init-controlplane:
	vagrant ssh master-node -c "sudo kubeadm init --apiserver-advertise-address 192.168.100.10 --pod-network-cidr=10.244.0.0/16"

save-kubeconfig:
	vagrant ssh master-node -c "sudo cat /etc/kubernetes/admin.conf" > kubeconfig

join-workers:
	$(eval JOIN_CMD = $(shell vagrant ssh master-node -c "sudo kubeadm token create --print-join-command"))
	vagrant ssh worker-node1 -c "sudo ${JOIN_CMD}"
	vagrant ssh worker-node2 -c "sudo ${JOIN_CMD}"

setup-kubeconfig:
	vagrant ssh master-node -c "mkdir -p /home/vagrant/.kube && sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config && sudo chown vagrant:vagrant /home/vagrant/.kube/config"

install-calico:
	vagrant ssh master-node -c "curl -L https://docs.projectcalico.org/manifests/calico.yaml | kubectl apply -f -"

install-helm:
	vagrant ssh master-node -c "curl -fsSL -o /tmp/get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && chmod +x /tmp/get_helm.sh && sudo /tmp/get_helm.sh"

install-ingress-deployment:
	vagrant ssh master-node -c "helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx --create-namespace --set controller.kind=Deployment --set controller.service.nodePorts.http=30080 --set controller.service.nodePorts.https=30443"

install-ingress-daemonset:
	vagrant ssh master-node -c "helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx --create-namespace --set controller.kind=DaemonSet --set controller.hostPort.enabled=true"
