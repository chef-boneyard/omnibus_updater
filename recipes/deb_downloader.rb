
remote_file "chef omnibus_package_downloader[#{File.basename(node[:omnibus_updater][:full_uri])}]" do
  path File.join(node[:omnibus_updater][:cache_dir], File.basename(node[:omnibus_updater][:full_uri]))
  source node[:omnibus_updater][:full_uri]
  only_if do
    node[:omnibus_updater][:cache_omnibus_installer] &&
    !File.exists?(
      File.join(node[:omnibus_updater][:cache_dir], File.basename(node[:omnibus_updater][:full_uri]))
    )
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
