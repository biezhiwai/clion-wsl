sudo echo "%sudo ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
sudo echo "vm.overcommit_memory = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl vm.overcommit_memory=1
