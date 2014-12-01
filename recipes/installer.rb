#
# Cookbook Name:: omnibus_updater
# Recipe:: installer
#
# Copyright 2014, Heavy Water Ops, LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'omnibus_updater'

file '/tmp/nocheck' do
  content 'conflict=nocheck\naction=nocheck'
  only_if { node['os'] =~ /^solaris/ }
end

service 'chef-client' do
  action :nothing
end

ruby_block 'omnibus chef killer' do
  block do
    if(Chef::Config[:client_fork] && Process.ppid != 1)
      Chef::Log.warn 'Chef client is defined for forked runs. Sending TERM to parent process!'
      Process.kill('TERM', Process.ppid)
    end
    Chef::Application.exit!('New omnibus chef version installed. Forcing chef exit!')
  end
  action :nothing
  only_if do
    node[:omnibus_updater][:kill_chef_on_upgrade]
  end
end

if(node[:omnibus_updater][:install_sh][:enabled])
  resource_ident = "v#{node[:omnibus_updater].fetch(:version, 'latest')}"
  script_path = File.join(Chef::Config[:file_cache_path], 'chef-client-install.sh')

  remote_file script_path do
    source node[:omnibus_updater][:install_sh][:url]
    mode 0755
  end

  script_command = [script_path]
  script_options = Mash.new(node[:omnibus_updater][:install_sh][:script_options].to_hash)

  if(node[:omnibus_updater][:version])
    script_options['-v'] = node[:omnibus_updater][:version]
  end

  script_command.push(script_options.flatten).flatten.compact.join(' ')

  execute "omnibus_install[#{resource_ident}]" do
    command script_command
    action :nothing
    if(node[:omnibus_updater][:restart_chef_service])
      notifies :restart, resources(:service => 'chef-client'), :immediately
    end
    notifies :create, resources(:ruby_block => 'omnibus chef killer'), :immediately
  end

else
  include_recipe 'omnibus_updater::downloader'

  remote_path = node[:omnibus_updater][:full_url].to_s
  resource_ident = File.basename(remote_path)

  execute "omnibus_install[#{resource_ident}]" do
    case File.extname(remote_path)
    when '.deb'
      command "dpkg -i #{File.join(node[:omnibus_updater][:cache_dir], File.basename(remote_path))}"
    when '.rpm'
      command "rpm -Uvh --oldpackage #{File.join(node[:omnibus_updater][:cache_dir], File.basename(remote_path))}"
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

end

ruby_block 'Omnibus Chef install notifier' do
  block{ true }
  notifies :run, resources(:execute => "omnibus_install[#{resource_ident}]"), :delayed
  only_if { node['chef_packages']['chef']['version'] != node['omnibus_updater']['version'] }
end

include_recipe 'omnibus_updater::old_package_cleaner'
