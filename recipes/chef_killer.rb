ruby_block 'omnibus chef killer' do
  block do
    upgrade_behavior = node[:omnibus_updater][:upgrade_behavior]
    if upgrade_behavior == 'exec'
      if not RbConfig::CONFIG['host_os'].start_with?('linux')
        Chef::Log.warn 'omnibus_updater "exec" upgrade behavior only supported on Linux -- changing to "kill".'
        upgrade_behavior = 'kill'
      end
    end

    case upgrade_behavior
      when 'exec'
        Chef::Log.warn 'Replacing ourselves with the new version of Chef to continue the run.'
        exec(node[:omnibus_updater][:exec_command], *node[:omnibus_updater][:exec_args])
      when 'kill'
        if(Chef::Config[:client_fork] && Process.ppid != 1)
          Chef::Log.warn 'Chef client is defined for forked runs. Sending TERM to parent process!'
          Process.kill('TERM', Process.ppid)
        end
        Chef::Application.exit!('New omnibus chef version installed. Forcing chef exit!')
      else
        raise "Unexpected upgrade behavior: #{node[:omnibus_updater][:upgrade_behavior]}"
    end
  end
  action :nothing
end
