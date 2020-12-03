# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.define :default do |default|
    # Box name
    default.vm.box = "generic/ubuntu1804"
  end

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.synced_folder ".", "/home/ubuntu/containernet"

  # Options for Libvirt Vagrant provider.
  config.vm.provider :libvirt do |libvirt|
    # A hypervisor name to access. Different drivers can be specified, but
    # this version of provider creates KVM machines only. Some examples of
    # drivers are KVM (QEMU hardware accelerated), QEMU (QEMU emulated),
    # Xen (Xen hypervisor), lxc (Linux Containers),
    # esx (VMware ESX), vmwarews (VMware Workstation) and more. Refer to
    # documentation for available drivers (http://libvirt.org/drivers.html).
    libvirt.driver = "kvm"

    # The name of the server, where Libvirtd is running.
    # libvirt.host = "localhost"

    # If use ssh tunnel to connect to Libvirt.
    libvirt.connect_via_ssh = false

    # Libvirt storage pool name, where box image and instance snapshots will
    # be stored.
    libvirt.storage_pool_name = "default"
  end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", inline: <<-SHELL
     sudo apt-get update
     sudo apt-get install -y ansible
     sudo echo "localhost ansible_connection=local" >> /etc/ansible/hosts
     # install containernet
     echo "Installing containernet (will take some time up to ~30 minutes) ..."
     cd /home/ubuntu/containernet/ansible
     sudo ansible-playbook -v install.yml

     # execute containernet tests at the end to validate installation
     echo "Running containernet unit tests to validate installation"
     cd /home/ubuntu/containernet
     sudo python setup.py develop
     sudo py.test -v mininet/test/test_containernet.py

     # place motd
     sudo cp util/motd /etc/motd
  SHELL
end
