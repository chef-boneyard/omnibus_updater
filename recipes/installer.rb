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
  when '.msi'
    base_path = File.join(node[:omnibus_updater][:cache_dir], File.basename(remote_path))
    my_win_path = base_path.gsub(::File::SEPARATOR, ::File::ALT_SEPARATOR || '\\') if base_path
    # print "my_win_path is #{my_win_path}"
    command "msiexec /qn /i #{my_win_path}"
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
  only_if { node['chef_packages']['chef']['version'] != node['omnibus_updater']['version'] }
end

include_recipe 'omnibus_updater::old_package_cleaner'
