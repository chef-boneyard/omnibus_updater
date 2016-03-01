name             "omnibus_updater"
maintainer       "Chris Roberts"
maintainer_email "chrisroberts.code@gmail.com"
license          "Apache 2.0"
description      "Chef omnibus package updater and installer"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "2.0.0"

%w(redhat centos amazon scientific oracle debian ubuntu mac_os_x solaris).each do |plat|
  supports plat
end
