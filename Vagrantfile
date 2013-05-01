# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
    config.vm.box = "precise64"

    config.vm.box_url = "http://cloud-images.ubuntu.com/precise/current/precise-server-cloudimg-vagrant-amd64-disk1.box"

    config.vm.network :hostonly, "192.168.33.10"

    # config.vm.network :bridged

    # config.vm.forward_port 80, 8080

    # Enable provisioning with Puppet stand alone.  Puppet manifests
    # are contained in a directory path relative to this Vagrantfile.
    # You will need to create the manifests directory and a manifest in
    # the file ci.pp in the manifests_path directory.

	config.vm.provision :puppet,
					    :options => ["--verbose", "--debug"],
					    :module_path => "modules" do |puppet|
        puppet.manifests_path = "manifests"
        puppet.manifest_file  = "base.pp"
end


end
