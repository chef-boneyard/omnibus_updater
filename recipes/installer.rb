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
    upgrade_behavior = node[:omnibus_updater][:upgrade_behavior]
    if upgrade_behavior == 'exec'
      if Chef::Config[:solo] or Chef::Config.local_mode
        Chef::Log.info 'Cannot use omnibus_updater "exec" upgrade behavior in solo/local mode -- changing to "kill".'
        upgrade_behavior = 'kill'
      elsif not RbConfig::CONFIG['host_os'].start_with?('linux')
        Chef::Log.info 'omnibus_updater "exec" upgrade behavior only supported on Linux -- changing to "kill".'
        upgrade_behavior = 'kill'
      end
    end

    case upgrade_behavior
      when 'exec'
        Chef::Log.info 'Replacing ourselves with the new version of Chef to continue the run.'
        exec(node[:omnibus_updater][:exec_command], *ARGV)
      when 'kill'
        raise 'New version of Chef omnibus installed. Aborting the Chef run, please restart it manually.'
      else
        raise "Unexpected upgrade behavior: #{node[:omnibus_updater][:upgrade_behavior]}"
    end
  end
  action :nothing
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
  else
    raise "Unknown package type encountered for install: #{File.extname(remote_path)}"
  end
  if(node[:omnibus_updater][:restart_chef_service])
    notifies :restart, resources(:service => 'chef-client'), :immediately
  end
  notifies :create, resources(:ruby_block => 'omnibus chef killer'), :immediately
  only_if { node['chef_packages']['chef']['version'] != node['omnibus_updater']['version'] }
end

include_recipe 'omnibus_updater::old_package_cleaner'
