# NOTE: This recipe is here for others that just want the
# package, not the actual installation (lxc for example)

if(node[:omnibus_updater][:direct_url])
  remote_path = node[:omnibus_updater][:direct_url]
else
  remote_path = OmnibusTrucker.url(
    OmnibusTrucker.build_url(node,
      :version => node[:omnibus_updater][:force_latest] ? nil : node[:omnibus_updater][:version].sub(/\-.+$/, ''),
      :prerelease => node[:omnibus_updater][:preview]
    ), node
  )
end

if(remote_path)
  node.set[:omnibus_updater][:full_url] = remote_path
  Chef::Log.info "Omnibus Updater remote path: #{remote_path}"

  remote_file "omnibus_remote[#{File.basename(remote_path)}]" do
    path File.join(node[:omnibus_updater][:cache_dir], File.basename(remote_path))
    source remote_path
    backup false
    action :create_if_missing
  end
  
else
  Chef::Log.warn 'Failed to retrieve omnibus download URL'
end

include_recipe 'omnibus_updater::old_package_cleaner'
