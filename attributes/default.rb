default[:omnibus_updater][:version] = nil
default[:omnibus_updater][:force_latest] = false
default[:omnibus_updater][:cache_dir] = '/opt'
default[:omnibus_updater][:cache_omnibus_installer] = false
default[:omnibus_updater][:remove_chef_system_gem] = false
default[:omnibus_updater][:prerelease] = false
default[:omnibus_updater][:disabled] = false
default[:omnibus_updater][:upgrade_behavior] = 'exec'
default[:omnibus_updater][:upgrade_notification] = :immediately
default[:omnibus_updater][:exec_command] = 'chef-client'
# restore the 'classic' behavior with:
# default[:omnibus_updater][:upgrade_behavior] = 'kill'
# default[:omnibus_updater][:upgrade_notification] = :delayed
default[:omnibus_updater][:always_download] = false
default[:omnibus_updater][:prevent_downgrade] = false
default[:omnibus_updater][:restart_chef_service] = false
default[:omnibus_updater][:checksum] = nil
