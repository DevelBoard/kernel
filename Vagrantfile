SETUP_SCRIPT = <<EOF
apt-get update
apt-get install -y bc \
    build-essential \
    git \
    libncurses-dev \
    unzip

touch /home/vagrant/.bash_aliases
chown vagrant:vagrant /home/vagrant/.bash_aliases
echo 'alias cleantarget="rm -rf target build/.root build/*/.stamp_target_installed"' > /home/vagrant/.bash_aliases
echo 'alias makeflash="make all && /vagrant/tools/flashsd.sh --quick /dev/sdc"' >> /home/vagrant/.bash_aliases

su - vagrant -c "make -C/vagrant O=/home/vagrant/buildroot FORCE_TOOLCHAIN_EXTERNAL=1 configure-buildroot"
EOF

Vagrant.configure(2) do |config|
    config.vm.box = "boxcutter/ubuntu1404"
    config.vm.network "public_network"
    config.vm.provision "shell", inline: SETUP_SCRIPT
    config.vm.provider "virtualbox" do |vm|
        vm.memory = 4096
        vm.cpus = 2
        vm.customize ["modifyvm", :id, "--usb", "on"]
        vm.customize ["modifyvm", :id, "--usbehci", "on"]
    end
    config.ssh.forward_agent = true
end
