include_recipe 'omnibus_updater'
remote_path = node['omnibus_updater']['full_url'].to_s
version = remote_path.scan(/chef-client-(\d+\.\d+.\d+)/).flatten.first

windows_package "Chef Client v#{version}" do
  source remote_path
end
