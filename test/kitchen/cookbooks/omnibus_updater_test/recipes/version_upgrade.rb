node.set[:omnibus_updater][:version] = '11.18'
node.set[:omnibus_updater][:kill_chef_on_upgrade] = false
include_recipe "omnibus_updater"
