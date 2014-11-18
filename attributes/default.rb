default[:omnibus_updater][:version] = nil
default[:omnibus_updater][:force_latest] = false
default[:omnibus_updater][:cache_dir] = Chef::Config[:file_cache_path]
default[:omnibus_updater][:cache_omnibus_installer] = false
default[:omnibus_updater][:remove_chef_system_gem] = false
default[:omnibus_updater][:prerelease] = false
default[:omnibus_updater][:disabled] = false
default[:omnibus_updater][:kill_chef_on_upgrade] = true
default[:omnibus_updater][:always_download] = false
default[:omnibus_updater][:prevent_downgrade] = false
default[:omnibus_updater][:restart_chef_service] = false
default[:omnibus_updater][:checksum] = nil
default[:omnibus_updater][:win_versions] = {
    6.3 => {
        :os_name => "Windows Server 2012 R2",
        :os_omnibus_name => "2012"
    },
    6.2 => {
        :os_name => "Windows Server 2012",
        :os_omnibus_name => "2012"
    },
    6.1 => {
        :os_name => "Windows Server 2008 R2",
        :os_omnibus_name => "2008r2"
    },
    6.0 => {
        :os_name => "Windows Server 2008",
        :os_omnibus_name => "2008"
    },
    5.2 => {
        :os_name => "Windows Server 2003 R2",
        :os_omnibus_name => "2003r2"
    }
}
