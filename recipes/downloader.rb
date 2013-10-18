# NOTE: This recipe is here for others that just want the
# package, not the actual installation (lxc for example)

if(node[:omnibus_updater][:direct_url])
  remote_path = node[:omnibus_updater][:direct_url]
else
  version = node[:omnibus_updater][:version] || ''
  remote_path = OmnibusTrucker.url(
    OmnibusTrucker.build_url(node,
      :version => node[:omnibus_updater][:force_latest] ? nil : version.sub(/\-.+$/, ''),
      :prerelease => node[:omnibus_updater][:preview]
    ), node
  )
end

if(remote_path)
  node.set[:omnibus_updater][:full_url] = remote_path

  remote_file "omnibus_remote[#{File.basename(remote_path)}]" do
    path File.join(node[:omnibus_updater][:cache_dir], File.basename(remote_path))
    source remote_path
    backup false
    action :create_if_missing
    only_if do
      unless(version = node[:omnibus_updater][:version])
        version = node[:omnibus_updater][:full_url].scan(%r{chef_(\d+\.\d+.\d+)}).flatten.first
      end
      if(node[:omnibus_updater][:always_download])
        # warn if there may be unexpected behavior
        node[:omnibus_updater][:prevent_downgrade] &&
          Chef::Log.warn("omnibus_updater: prevent_downgrade is ignored when always_download is true")
        Chef::Log.debug "Omnibus Updater remote path: #{remote_path}"
        true
      elsif(node[:omnibus_updater][:prevent_downgrade])
        # Return true if the found/specified version is newer
        Gem::Version.new(version.to_s.sub(/\-.+$/, '')) > Gem::Version.new(Chef::VERSION)
      else
        # default is to install if the versions don't match
        Chef::VERSION != version.to_s.sub(/\-.+$/, '')
      end
    end
  end
else
  Chef::Log.warn 'Failed to retrieve omnibus download URL'
end

include_recipe 'omnibus_updater::old_package_cleaner'
