include_recipe 'omnibus_updater'
remote_path = node[:omnibus_updater][:full_url].to_s

windows_package 'chef-client' do
  source remote_path
end