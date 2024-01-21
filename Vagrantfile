Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"
  config.vm.define "master-node" do | node |
    node.vm.hostname = "master-node"
    node.vm.network "private_network", ip: "192.168.100.10"
    node.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 2
      vb.name = "master-node"
    end
    node.vm.provision :shell, :path => "scripts/node-setup.sh"
    node.vm.provision :shell, :path => "scripts/kube-setup.sh"
  end

  config.vm.box = "ubuntu/focal64"
  config.vm.define "worker-node1" do | node |
    node.vm.hostname = "worker-node1"
    node.vm.network "private_network", ip: "192.168.100.11"
    node.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
      vb.name = "worker-node1"
    end
    node.vm.provision :shell, :path => "scripts/node-setup.sh"
    node.vm.provision :shell, :path => "scripts/kube-setup.sh"
  end

  config.vm.box = "ubuntu/focal64"
  config.vm.define "worker-node2" do | node |
    node.vm.hostname = "worker-node2"
    node.vm.network "private_network", ip: "192.168.100.12"
    node.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
      vb.name = "worker-node2"
    end
    node.vm.provision :shell, :path => "scripts/node-setup.sh"
    node.vm.provision :shell, :path => "scripts/kube-setup.sh"
  end

  config.vm.box = "ubuntu/focal64"
  config.vm.define "registry-node" do | node |
    node.vm.hostname = "registry-node"
    node.vm.network "private_network", ip: "192.168.100.20"
    node.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
      vb.name = "registry-node"
    end
    node.vm.provision :shell, :path => "scripts/node-setup.sh"
    node.vm.provision :shell, :path => "scripts/registry-setup.sh"
  end
end
