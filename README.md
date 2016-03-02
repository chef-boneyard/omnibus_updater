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
- windows

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

Chef Killing
------------

By default the omnibus updater will kill the chef instance by raising an exception.
You can turn this off using the `kill_chef_on_upgrade` attribute. It is not
recommended to turn this off. Internal chef libraries may change, move, or no
longer exist. The currently running instance can encounter unexpected states because
of this. To prevent this, the updater will attempt to kill the Chef instance so
that it can be restarted in a normal state.

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

Warnings
========

Windows Support
---------------
Windows support is available in versions 1.0.8 and higher; however, we only support Chef Client versions 12.5.1 and below, due to a [known bug in 12.6.0](https://github.com/chef/chef/issues/4623). This is reflected in the Windows test suite.

If you would like to wrap this cookbook in order to prevent OmnibusUpdater with version 12.6.0 on Windows, you may do something like the following:
```
if((node[:chef_packages][:chef][:version] == '12.6.0') && node[:os].downcase.include?('windows'))
  Chef::Log.warn 'Omnibus updater cannot upgrade or downgrade a Windows 12.6.0 installation, skipping'
else
  include_recipe 'omnibus_updater'
end
```

Infos
=====

* Repo: https://github.com/hw-cookbooks/omnibus_updater
* IRC: Freenode @ #heavywater
* Cookbook: http://ckbk.it/omnibus_updater
