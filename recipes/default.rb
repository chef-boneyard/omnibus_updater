#
# Cookbook:: omnibus_updater
# Recipe:: default
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

# fail hard if we're on an unsupported platform
# feel free to open PRs to add additional platforms
unless platform_family?('debian', 'fedora', 'mac_os_x', 'rhel', 'solaris2', 'windows', 'suse')
  Chef::Application.fatal! "Omnibus updater does not support the #{node['platform']} platform"
end

if node['omnibus_updater']['disabled']
  Chef::Log.warn 'Omnibus updater disabled via `disabled` attribute'
else
  include_recipe 'omnibus_updater::downloader'
  include_recipe 'omnibus_updater::installer'
end
