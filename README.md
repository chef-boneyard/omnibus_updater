OmnibusUpdater
==============

Update your omnibus! This cookbook can install the omnibus
Chef package into your system if you are currently running
via gem install, and it can keep your omnibus install up
to date.

Supports
========

- redhat
- centos
- amazon
- scientific
- oracle
- debian
- ubuntu
- mac_os_x
- solaris

Usage
=====

Add the recipe to your run list and specify what version should
be installed on the node:

`knife node run_list add recipe[omnibus_updater]`

In your role you'll likely want to set the version. It defaults
to nothing, and will install the latest..

```
override_attributes(
  :omnibus_updater => {
    :version => '11.4.0'
  }
)
```

It can also uninstall Chef from the system Ruby installation
if you tell it to:

```
override_attributes(
  :omnibus_updater => {
    :remove_chef_system_gem => true
  }
)
```

Features
========

Latest Version
--------------

Force installation of the latest version regardless of value stored in version
attribute by setting the `force_latest` attribute.

Restarting Chef Client
------------

By default the omnibus updater will restart the run using the new version
by calling `exec` with the original command line and arguments.
Older versions used to kill the chef-client and abort the run by default,
but re-`exec`ing the client allows runs to complete without errors being bubbled up
the stack. You can choose between these behaviors by using the
`upgrade_behavior` attribute:

* If set to `:kill`, the run will be aborted by raising an exception.
* If set to `:exec` (the default), the run will be resumed by re-`exec`ing chef-client.
  You can customize the command that is exec'd by setting the `exec_command` attribute.
  The default for `exec_command` is `$0` (the original command used to call chef-client).
* If set to anything else, an error is raised.

Restart chef-client Service
---------------------------

Use the `restart_chef_service` attribute to restart chef-client if you have it running as a service.

Prerelease
--------

Prereleases can be installed via the auto-installation using `prerelease` attribute.

Disable
-------

If you want to disable the updater you can set the `disabled`
attribute to true. This might be useful if the cookbook is added
to a role but should then be skipped for example on a Chef server.

Prevent Downgrade
-----------------

If you want to prevent the updater from downgrading chef on a node, you
can set the `prevent_downgrade` attribute to true.  This can be useful
for testing new versions manually.  Note that the `always_download`
attribute takes precedence if set.

Infos
=====

* Repo: https://github.com/hw-cookbooks/omnibus_updater
* IRC: Freenode @ #heavywater
* Cookbook: http://ckbk.it/omnibus_updater
