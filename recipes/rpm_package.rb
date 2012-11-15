include_recipe 'omnibus_updater::set_remote_path'

remote_file "chef omnibus_package[#{File.basename(node[:omnibus_updater][:full_uri])}]" do
  path File.join(node[:omnibus_updater][:cache_dir], File.basename(node[:omnibus_updater][:full_uri]))
  source node[:omnibus_updater][:full_uri]
  backup false
  not_if do
    File.exists?(
      File.join(node[:omnibus_updater][:cache_dir], File.basename(node[:omnibus_updater][:full_uri]))
    ) || (
      Chef::VERSION.to_s.scan(/\d+\.\d+\.\d+/) == node[:omnibus_updater][:full_version].scan(/\d+\.\d+\.\d+/) && OmnibusChecker.is_omnibus?
    )
  end
end

execute "chef omnibus_install[#{node[:omnibus_updater][:full_version]}]" do
  command "rpm -Uvh #{File.join(node[:omnibus_updater][:cache_dir], File.basename(node[:omnibus_updater][:full_uri]))}"
  only_if do
    (File.exists?(
      File.join(node[:omnibus_updater][:cache_dir], File.basename(node[:omnibus_updater][:full_uri]))
    ) &&
    Chef::VERSION.to_s.scan(/\d+\.\d+\.\d+/) != node[:omnibus_updater][:full_version].scan(/\d+\.\d+\.\d+/)) ||
    !OmnibusChecker.is_omnibus?
  end
end

include_recipe 'omnibus_updater::old_package_cleaner'
