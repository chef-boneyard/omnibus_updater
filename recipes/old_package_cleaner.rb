#
# Cookbook Name:: omnibus_updater
# Recipe:: old_package_cleaner
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

old_pkgs =
  if(::File.exist?(node[:omnibus_updater][:cache_dir]))
    Dir.glob(File.join(node[:omnibus_updater][:cache_dir], 'chef*')).find_all do |file|
      !file.include?(node[:omnibus_updater][:version].to_s) && !file.scan(/\.(rpm|deb|msi)$/).empty?
    end
  else
    []
  end

old_pkgs.each do |filename|
  file filename do
    action :delete
    backup 1
  end
end
