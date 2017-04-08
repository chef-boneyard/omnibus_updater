name             'omnibus_updater'
maintainer       'Chef Software, Inc.'
maintainer_email 'cookbooks@chef.io'
license          'Apache-2.0'
description      'Chef omnibus package updater and installer'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '3.1.0'

%w(amazon centos debian mac_os_x opensuse opensuseleap oracle redhat scientific solaris2 suse ubuntu windows aix).each do |os|
  supports os
end

source_url       'https://github.com/chef-cookbooks/omnibus_updater' if respond_to?(:source_url)
issues_url       'https://github.com/chef-cookbooks/omnibus_updater/issues' if respond_to?(:issues_url)

chef_version '>= 11.0' if respond_to?(:chef_version)
