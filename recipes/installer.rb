#
# Cookbook:: omnibus_updater
# Recipe:: installer
#
# Copyright:: 2014-2017, Heavy Water Ops, LLC
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
remote_path = node['omnibus_updater']['full_url']

service 'chef-client-omnibus' do
  service_name 'chef-client'
  supports status: true, restart: true
  action :nothing
end

if platform?('windows')
  version = node['omnibus_updater']['version'] || remote_path.scan(/chef-windows|client-(\d+\.\d+.\d+)/).flatten.first
  Chef::Recipe.send(:include, Chef::Mixin::ShellOut)
  chef_version = shell_out('chef-client -v')
  chef_version = chef_version.stdout

  # clean up previous upgrades
  directory 'c:/opscode/chef.upgrade' do
    action :delete
    recursive true
  end

  if node['chef_packages']['chef']['version'] != node['omnibus_updater']['version']
    execute 'chef-move' do
      command 'move c:/opscode/chef c:/opscode/chef.upgrade'
      action :nothing
    end
    execute 'chef-uninstall' do
      command 'wmic product where "name like \'Chef Client%% %%\'" call uninstall /nointeractive'
      action :nothing
    end
    execute 'chef-install' do
      command "msiexec.exe /qn /i #{File.basename(remote_path)} ADDLOCAL=\"#{node['omnibus_updater']['addlocal']}\""
      cwd node['omnibus_updater']['cache_dir']
      action :nothing
    end
    execute 'chef-service-kill' do
      command 'taskkill /F /FI "SERVICES eq chef-client"'
      action :nothing
    end

    ruby_block 'Omnibus Chef Update' do
      block { true }
      notifies :run, 'execute[chef-service-kill]', :immediately
      notifies :run, 'execute[chef-move]', :immediately
      notifies :run, 'execute[chef-uninstall]', :immediately
      notifies :run, 'execute[chef-install]', :immediately
      notifies :start, 'service[chef-client-omnibus]', :immediately if node['omnibus_updater']['restart_chef_service']
      not_if { chef_version == "Chef: #{version}\r\n" }
    end
  end
else
  file '/tmp/nocheck' do
    content 'conflict=nocheck\naction=nocheck'
    only_if { node['os'] =~ /^solaris/ }
  end

  ruby_block 'omnibus chef killer' do
    block do
      Chef::Application.fatal!('New omnibus chef version installed. Killing Chef run!', node['omnibus_updater']['kill_chef_on_upgrade_exit_code'])
    end
    action :nothing
    only_if { node['omnibus_updater']['kill_chef_on_upgrade'] }
  end

  execute "omnibus_install[#{File.basename(remote_path)}]" do # ~FC009
    case File.extname(remote_path)
    when '.deb'
      command "dpkg -i #{File.join(node['omnibus_updater']['cache_dir'], File.basename(remote_path))}"
    when '.rpm'
      if node['platform'] == 'amazon'
        command "rpm -e chef && rpm -Uvh --oldpackage #{File.join(node['omnibus_updater']['cache_dir'], File.basename(remote_path))}"
      else
        command "rpm -Uvh --oldpackage #{File.join(node['omnibus_updater']['cache_dir'], File.basename(remote_path))}"
      end
    when '.sh'
      command "/bin/sh #{File.join(node['omnibus_updater']['cache_dir'], File.basename(remote_path))}"
    when '.solaris'
      command "pkgadd -n -d #{File.join(node['omnibus_updater']['cache_dir'], File.basename(remote_path))} -a /tmp/nocheck chef"
    when '.dmg'
      command <<-EOF
          hdiutil detach "/Volumes/chef_software" >/dev/null 2>&1 || true
          hdiutil attach "#{File.join(node['omnibus_updater']['cache_dir'], File.basename(remote_path))}" -mountpoint "/Volumes/chef_software"
          cd / && /usr/sbin/installer -pkg `find "/Volumes/chef_software" -name \*.pkg` -target /
          hdiutil detach "/Volumes/chef_software"
        EOF
    else
      raise "Unknown package type encountered for install: #{File.extname(remote_path)}"
    end
    action :nothing
    if node['omnibus_updater']['restart_chef_service']
      notifies :restart, 'service[chef-client-omnibus]', :immediately
    end
    notifies :create, 'ruby_block[omnibus chef killer]', :immediately
  end

  ruby_block 'Omnibus Chef install notifier' do
    block { true }
    action :nothing
    subscribes :create, "remote_file[omnibus_remote[#{File.basename(remote_path)}]]", :immediately
    notifies :run, "execute[omnibus_install[#{File.basename(remote_path)}]]", :delayed
    only_if { node['chef_packages']['chef']['version'] != node['omnibus_updater']['version'] }
  end
end

include_recipe 'omnibus_updater::old_package_cleaner'
