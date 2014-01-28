include_recipe 'omnibus_updater'
remote_path = node[:omnibus_updater][:full_url].to_s

file '/tmp/nocheck' do
  content 'conflict=nocheck\naction=nocheck'
  only_if { node['os'] =~ /^solaris/ }
end

ruby_block 'omnibus chef killer' do
  block do
    raise 'New omnibus chef version installed. Killing Chef run!'
  end
  action :nothing
  only_if do
    node[:omnibus_updater][:kill_chef_on_upgrade]
  end
end

execute "omnibus_install[#{File.basename(remote_path)}]" do
  case File.extname(remote_path)
  when '.deb'
    command "dpkg -i #{File.join(node[:omnibus_updater][:cache_dir], File.basename(remote_path))}"
  when '.rpm'
    command "rpm -Uvh #{File.join(node[:omnibus_updater][:cache_dir], File.basename(remote_path))}"
  when '.sh'
    command "/bin/sh #{File.join(node[:omnibus_updater][:cache_dir], File.basename(remote_path))}"
  when '.solaris'
    command "pkgadd -n -d #{File.join(node[:omnibus_updater][:cache_dir], File.basename(remote_path))} -a /tmp/nocheck chef"
  else
    raise "Unknown package type encountered for install: #{File.extname(remote_path)}"
  end
  action :nothing
  if(node[:omnibus_updater][:restart_chef_service])
    notifies :restart, resources(:service => 'chef-client'), :immediately
  end
  notifies :create, resources(:ruby_block => 'omnibus chef killer'), :immediately
end

ruby_block 'Omnibus Chef install notifier' do
  block{ true }
  action :nothing
  subscribes :create, resources(:remote_file => "omnibus_remote[#{File.basename(remote_path)}]"), :immediately
  notifies :run, resources(:execute => "omnibus_install[#{File.basename(remote_path)}]"), :delayed
end

include_recipe 'omnibus_updater::old_package_cleaner'
