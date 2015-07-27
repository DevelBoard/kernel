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

su - vagrant -c "cd /vagrant/buildroot; make O=/home/vagrant/buildroot develer_develboard_defconfig"
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
