# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # Configuration of new VM.
  config.vm.define :default do |default|
    # Box name
    default.vm.box = "generic/ubuntu1804"

    # Domain Specific Options
    #
    #default.vm.provider :libvirt do |domain|
    #  domain.memory = 2048
    #  domain.cpus = 2
    #end

    # Interfaces for VM
    # 
    # Networking features in the form of `config.vm.network`
    #
    #default.vm.network :private_network, :ip => '10.20.30.40'
    #default.vm.network :public_network, :ip => '10.20.30.41'
  end

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

    # The username and password to access Libvirt. Password is not used when
    # connecting via ssh.
    libvirt.username = "root"
    #libvirt.password = "secret"

    # Libvirt storage pool name, where box image and instance snapshots will
    # be stored.
    libvirt.storage_pool_name = "default"

    # Set a prefix for the machines that's different than the project dir name.
    #libvirt.default_prefix = ''
  end
end
