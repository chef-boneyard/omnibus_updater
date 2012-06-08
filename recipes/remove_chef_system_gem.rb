# Chef installed via system gem will only be removed
# if the attributes tell us to AND we are in omnibus

gem_package 'chef' do
  action :remove
  only_if do
    node[:omnibus_updater][:remove_chef_system_gem] && OmnibusChecker.is_omnibus?
  end
end
