# Build and store 

# RULES
platform_version = case node.platform_version
when '10.10', '10.04'
  '10.10'
when '12.04', '11.10', '11.04'
  '11.04'
else
  raise 'Unsupported ubuntu version for deb packaged omnibus'
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

remote_file "chef omnibus_package[#{File.basename(node[:omnibus_updater][:full_uri])}]" do
  path File.join(node[:omnibus_updater][:cache_dir], File.basename(node[:omnibus_updater][:full_uri]))
  source node[:omnibus_updater][:full_uri]
  not_if do
    File.exists?(
      File.join(node[:omnibus_updater][:cache_dir], File.basename(node[:omnibus_updater][:full_uri]))
    ) || (
      Chef::VERSION.to_s.scan(/\d+\.\d+\.\d+/) == node[:omnibus_updater][:version].scan(/\d+\.\d+\.\d+/) && OmnibusChecker.is_omnibus?
    ) ||
    node[:omnibus_updater][:cache_omnibus_installer]
  end
end

# NOTE
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

ruby_block "omnibus_updater[remove old debs]" do
  block do
    Dir.glob(File.join(node[:omnibus_updater][:cache_dir], 'chef*.deb')).each do |file|
      unless(file.include?(node[:omnibus_updater][:version]))
        Chef::Log.info "Deleting stale omnibus package: #{file}"
        File.delete(
          File.join(node[:omnibus_updater][:cache_dir], file)
        )
      end
    end
  end
end
