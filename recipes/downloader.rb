#
# Cookbook Name:: omnibus_updater
# Recipe:: downloader
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

# NOTE: This recipe is here for others that just want the
# package, not the actual installation (lxc for example)

if(node[:omnibus_updater][:direct_url])
  remote_path = node[:omnibus_updater][:direct_url]
else
  version = node[:omnibus_updater][:version] || ''
  remote_path = OmnibusTrucker.url(
    OmnibusTrucker.build_url(node,
      :version => node[:omnibus_updater][:force_latest] ? nil : version.sub(/\-.+$/, ''),
      :prerelease => node[:omnibus_updater][:preview]
    ), node
  )
end

if(remote_path)
  node.set[:omnibus_updater][:full_url] = remote_path

  directory node[:omnibus_updater][:cache_dir] do
    recursive true
  end

  remote_file "omnibus_remote[#{File.basename(remote_path)}]" do
    path File.join(node[:omnibus_updater][:cache_dir], File.basename(remote_path))
    source remote_path
    backup false
    checksum node[:omnibus_updater][:checksum] if node[:omnibus_updater][:checksum]
    action :create_if_missing
    only_if do
      unless(version = node[:omnibus_updater][:version])
        case node['platform_family']
          when 'windows'
            version = node[:omnibus_updater][:full_url].scan(%r{chef-windows|client-(\d+\.\d+.\d+)}).flatten.first
          else
            version = node[:omnibus_updater][:full_url].scan(%r{chef[_-](\d+\.\d+.\d+)}).flatten.first
        end
      end
      if(node[:omnibus_updater][:always_download])
        # warn if there may be unexpected behavior
        node[:omnibus_updater][:prevent_downgrade] &&
          Chef::Log.warn("omnibus_updater: prevent_downgrade is ignored when always_download is true")
        Chef::Log.debug "Omnibus Updater remote path: #{remote_path}"
        true
      elsif(node[:omnibus_updater][:prevent_downgrade])
        # Return true if the found/specified version is newer
        Gem::Version.new(version.to_s.sub(/\-.+$/, '')) > Gem::Version.new(Chef::VERSION)
      else
        # default is to install if the versions don't match
        Chef::VERSION != version.to_s.sub(/\-.+$/, '')
      end
    end
  end
else
  Chef::Log.warn 'Failed to retrieve omnibus download URL'
end

include_recipe 'omnibus_updater::old_package_cleaner'
