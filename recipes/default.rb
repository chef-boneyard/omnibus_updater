
if(node[:omnibus_updater][:install_via])
  case node[:omnibus_updater][:install_via]
  when 'deb'
    include_recipe 'omnibus_updater::deb_package'
  when 'rpm'
    raise 'only deb support right now'
    include_recipe 'omnibus_updater::rpm_package'
  when 'script'
    raise 'only deb support right now'
    include_recipe 'omnibus_updater::script'
  else
    raise "Unknown omnibus update method requested: #{node[:omnibus_updater]}"
  end
else
  case node.platform_family
  when 'debian'
    include_recipe 'omnibus_updater::deb_package'
  when 'fedora', 'rhel'
    raise 'only deb support right now'
    include_recipe 'omnibus_updater::rpm_package'
  else
    raise 'only deb support right now'
    include_recipe 'omnibus_updater::script'
  end
end

include_recipe 'omnibus_updater::remove_chef_system_gem' if node[:omnibus_updater][:remove_chef_system_gem]
