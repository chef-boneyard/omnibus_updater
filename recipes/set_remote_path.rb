# RULES

platform_name = node.platform
platform_majorversion = ""
case node.platform_family
when 'debian'
  if(node.platform == 'ubuntu')
    platform_version = case node.platform_version
    when '10.10', '10.04'
       platform_majorversion << '10.04'
      '10.04'
    when '12.10', '12.04', '11.10', '11.04'
       platform_majorversion << '11.04'
      '11.04'
    else
      raise 'Unsupported ubuntu version for deb packaged omnibus'
    end
  else
    platform_version = case pv = node.platform_version.split('.').first
    when '6', '5'
      platform_majorversion << '6'
      '6.0.5'
    else
      platform_majorversion << pv
      pv
    end
  end
when 'fedora', 'rhel'
  platform_version = node.platform_version.split('.').first
  platform_name = 'el'
  platform_majorversion << '6'

else
  platform_version = node.platform_version
end

if(node[:omnibus_updater][:install_via])
  install_via = node[:omnibus_updater][:install_via]
else
  install_via = case node.platform_family
  when 'debian'
    'deb'
  when 'fedora', 'rhel', 'centos'
    'rpm'
  else
    raise 'Unsupported omnibus install method requested'
  end
end
case install_via
when 'deb'
  kernel_name = ""
  file_name = "chef_#{node[:omnibus_updater][:version]}.#{platform_name}.#{platform_version}_"
  if(node.kernel.machine.include?('64'))
    file_name << 'amd64'
    kernel_name << 'x86_64'
  else
    file_name << 'i386'
    kernel_name << 'i686'
  end
  file_name << '.deb'

when 'rpm'
  file_name = "chef-#{node[:omnibus_updater][:version]}.#{platform_name}#{platform_version}.#{node.kernel.machine}.rpm"
end

remote_omnibus_file = File.join(
  node[:omnibus_updater][:base_uri],
  platform_name,
  platform_majorversion,
  kernel_name,
  file_name
)

unless(remote_omnibus_file == node[:omnibus_updater][:full_uri])
  node.override[:omnibus_updater][:full_uri] = remote_omnibus_file
  Chef::Log.info "Omnibus remote file location: #{remote_omnibus_file}"
end
