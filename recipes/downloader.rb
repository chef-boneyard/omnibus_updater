# NOTE: This recipe is here for others that just want the
# package, not the actual installation (lxc for example)

remote_path = OmniTrucker.url(
  OmniTrucker.build_url(node,
    :version => node[:omnibus_updater][:force_latest] ? nil : node[:omnibus_updater][:version].sub(/\-.+$/, ''),
    :preview => node[:omnibus_updater][:preview]
  )
)

if(remote_path)
  node.run_state[:omnibus_remote] = remote_path
  Chef::Log.info "Omnibus Updater remote path: #{remote_path}"

  remote_file "omnibus_remote[#{File.basename(remote_path)}]" do
    path File.join(node[:omnibus_updater][:cache_dir], File.basename(remote_path))
    source remote_path
    backup false
    only_if do
      node[:omnibus_updater][:cache_omnibus_installer] &&
        !File.exists?(
        File.join(node[:omnibus_updater][:cache_dir], File.basename(remote_path))
        )
    end
  end
  
else
  Chef::Log.warn 'Failed to retrieve omnibus download URL'
end

include_recipe 'omnibus_updater::old_package_cleaner'
