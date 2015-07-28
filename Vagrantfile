SETUP_SCRIPT = <<EOF
apt-get update
apt-get install -y bc \
    build-essential \
    git \
    libncurses-dev \
    unzip
EOF

Vagrant.configure(2) do |config|
    config.vm.box = "boxcutter/ubuntu1404"
    config.vm.network "public_network"
    config.vm.provision "shell", inline: SETUP_SCRIPT
    config.vm.provider "virtualbox" do |vm|
        vm.memory = 4096
        vm.cpus = 2
    end
end
