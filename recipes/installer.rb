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
remote_path = node[:omnibus_updater][:full_url].to_s

file '/tmp/nocheck' do
  content 'conflict=nocheck\naction=nocheck'
  only_if { node['os'] =~ /^solaris/ }
end

service 'chef-client' do
  action :nothing
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
    command "rpm -Uvh --oldpackage #{File.join(node[:omnibus_updater][:cache_dir], File.basename(remote_path))}"
  when '.sh'
    command "/bin/sh #{File.join(node[:omnibus_updater][:cache_dir], File.basename(remote_path))}"
  when '.solaris'
    command "pkgadd -n -d #{File.join(node[:omnibus_updater][:cache_dir], File.basename(remote_path))} -a /tmp/nocheck chef"
  when '.msi'
    # Do not raise exception, the installation will be triggered in the sched-task resource
  else
    raise "Unknown package type encountered for install: #{File.extname(remote_path)}"
  end
  action :nothing
  if(node[:omnibus_updater][:restart_chef_service])
    notifies :restart, resources(:service => 'chef-client'), :immediately
  end
  notifies :create, resources(:ruby_block => 'omnibus chef killer'), :immediately
end

template "#{Chef::Config[:file_cache_path]}/upgrade_chef_client.bat" do
  source 'upgrade_chef_client.bat.erb'
  variables({
                "msi_installer" => "c:#{File.join(node[:omnibus_updater][:cache_dir], File.basename(remote_path)).gsub('/','\\')}"
            })
  action :nothing
end

ruby_block "omnibus_install_windows[#{File.basename(remote_path)}]" do
  block do
    # Stops the chef-client service
    notifies :stop, resources(:service => 'chef-client'), :immediately
    # Creates a bat file to be run in a scheduled task
    notifies :create, resources(:template => "#{Chef::Config[:file_cache_path]}/upgrade_chef_client.bat"), :immediately
    # Remove the scheduled task (in case it is not the first time it is upgraded)
    notifies :remove, resources(:windows_task => 'Update chef-client'), :immediately
    # Adds a scheduled task to be run once in 10 minutes
    notifies :create, resources(:windows_task => 'Update chef-client'), :immediately
    # Kills the current chef-client execution
    notifies :create, resources(:ruby_block => 'omnibus chef killer'), :immediately
  end
  action :nothing
end

#Instead of scheduling for 600 seconds after chef compile time, we should get current time during task execution
windows_task "Update chef-client" do
  action :nothing
  command "#{Chef::Config[:file_cache_path]}/upgrade_chef_client.bat > #{Chef::Config[:file_cache_path]}/upgrade_chef_client.log"
  start_day (Time.now + 600).strftime("%d/%m/%Y")
  start_time (Time.now + 600).strftime("%H:%M")
  frequency :once
end

ruby_block 'Omnibus Chef install notifier' do
  block{ true }
  action :nothing
  subscribes :create, resources(:remote_file => "omnibus_remote[#{File.basename(remote_path)}]"), :immediately
  if platform?('windows')
    notifies :run, resources(:ruby_block => "omnibus_install_windows[#{File.basename(remote_path)}]"), :delayed
  else
    notifies :run, resources(:execute => "omnibus_install[#{File.basename(remote_path)}]"), :delayed
  end
  only_if { node['chef_packages']['chef']['version'] != node['omnibus_updater']['version'] }
end

include_recipe 'omnibus_updater::old_package_cleaner'
