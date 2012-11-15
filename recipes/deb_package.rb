include_recipe 'omnibus_updater::set_remote_path'

remote_file "chef omnibus_package[#{File.basename(node[:omnibus_updater][:full_uri])}]" do
  path File.join(node[:omnibus_updater][:cache_dir], File.basename(node[:omnibus_updater][:full_uri]))
  source node[:omnibus_updater][:full_uri]
  backup false
  not_if do
    File.exists?(
      File.join(node[:omnibus_updater][:cache_dir], File.basename(node[:omnibus_updater][:full_uri]))
    ) || (
      Chef::VERSION.to_s.scan(/\d+\.\d+\.\d+/) == node[:omnibus_updater][:version].scan(/\d+\.\d+\.\d+/) && OmnibusChecker.is_omnibus?
    )
  end
end

# NOTE: We do not use notifications to trigger the install
#   since they are broken with remote_file in 0.10.10
execute "chef omnibus_install[#{node[:omnibus_updater][:version]}]" do
  command "dpkg -i #{File.join(node[:omnibus_updater][:cache_dir], File.basename(node[:omnibus_updater][:full_uri]))}"
  only_if do
    (File.exists?(
      File.join(node[:omnibus_updater][:cache_dir], File.basename(node[:omnibus_updater][:full_uri]))
    ) &&
    Chef::VERSION.to_s.scan(/\d+\.\d+\.\d+/) != node[:omnibus_updater][:version].scan(/\d+\.\d+\.\d+/)) ||
    !OmnibusChecker.is_omnibus?
  end
end

include_recipe 'omnibus_updater::_old_deb_cleaner'
