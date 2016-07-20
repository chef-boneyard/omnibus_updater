name             'omnibus_updater'
maintainer       'Chef Software, Inc.'
maintainer_email 'cookbooks@chef.io'
license          'Apache 2.0'
description      'Chef omnibus package updater and installer'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.1.1'

%w(redhat centos amazon scientific oracle debian ubuntu mac_os_x solaris windows).each do |os|
  supports os
end

source_url       'https://github.com/hw-cookbooks/omnibus_updater' if respond_to?(:source_url)
issues_url       'https://github.com/hw-cookbooks/omnibus_updater/issues' if respond_to?(:issues_url)

chef_version '>= 11.0' if respond_to?(:chef_version)
