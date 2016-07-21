node.default['omnibus_updater']['version'] = '12.12.15'
node.default['omnibus_updater']['kill_chef_on_upgrade'] = false

include_recipe 'omnibus_updater'
