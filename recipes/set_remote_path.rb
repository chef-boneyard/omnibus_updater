# RULES
case node.platform_family
when 'debian'
  if(node.platform == 'ubuntu')
    platform_version = case node.platform_version
    when '10.10', '10.04'
      '10.10'
    when '12.04', '11.10', '11.04'
      '11.04'
    else
      raise 'Unsupported ubuntu version for deb packaged omnibus'
    end
  else
    platform_version = node.platform_version.split('.').first
  end

  file_name = "chef-full_#{node[:omnibus_updater][:version]}_"
  if(node.kernel.machine.include?('64'))
    file_name << 'amd64'
  else
    file_name << 'i386'
  end
  file_name << '.deb'

  omnibus_deb = File.join(
    node[:omnibus_updater][:base_uri],
    node.platform + '-' +
    platform_version + '-' +
    node.kernel.machine,
    file_name
  )

  unless(omnibus_deb == node[:omnibus_updater][:full_uri])
    node.set[:omnibus_updater][:full_uri] = omnibus_deb
    Chef::Log.info "Omnibus DEB package location: #{omnibus_deb}"
  end
when 'fedora', 'rhel'
  platform_version = case node.platform_version.split('.').first
  when '5'
    '5.7'
  when '6'
    '6.2'
  else
    raise 'Unsupported version'
  end

  omnibus_rpm = File.join(
    node[:omnibus_updater][:base_uri],
    'el-' +
    platform_version + '-' +
    node.kernel.machine,
    "chef-full-#{node[:omnibus_updater][:version]}.#{node.kernel.machine}.rpm"
  )

  unless(omnibus_rpm == node[:omnibus_updater][:full_uri])
    node.set[:omnibus_updater][:full_uri] = omnibus_rpm
    Chef::Log.info "Omnibus RPM package location: #{omnibus_rpm}"
  end
else
  omnibus_script = File.join(
    node[:omnibus_updater][:base_uri],
    node.platform + '-' +
    node.platform_version + '-' +
    node.kernel.machine,
    "chef-full-#{node[:omnibus_updater][:version]}-#{node.platform_version}-#{node.kernel.machine}.sh"
  )

  unless(omnibus_script == node[:omnibus_updater][:full_uri])
    node.set[:omnibus_updater][:full_uri] = omnibus_script
    Chef::Log.info "Omnibus install script location: #{omnibus_script}"
  end
end
