node.set[:omnibus_updater][:kill_chef_on_upgrade] = false
node.set[:omnibus_updater][:version] = '10.16.2'
include_recipe "omnibus_updater"
