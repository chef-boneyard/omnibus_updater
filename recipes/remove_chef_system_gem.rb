gem_package 'chef' do
  action :purge
  only_if do
    node[:omnibus_updater][:remove_chef_system_gem]
  end
end
