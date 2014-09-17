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

Chef Killing
------------

By default the omnibus updater will re-exec chef to continue the run using the
new version.  Older versions used to just kill the chef-client and abort the
run, but exec()ing Chef allows runs to complete without errors being bubbled up
the stack. You can choose between these behaviors by using the
`upgrade_behavior` attribute.

* If set to 'kill', the run will be aborted by raising an exception.
* If set to 'exec', the run will be resumed by re-exec'ing chef-client. This
  doesn't work in solo mode; when using chef-solo, setting this attribute to
  'exec' is equivalent to 'kill'. You can customize the command that is exec'd
  by setting the `exec_command` attribute.
* If set to anything else, the run is not aborted. Doing this is not
  recommended. Internal chef libraries may change, move, or no
  longer exist. The currently running instance can encounter unexpected states
  because of this, so using 'kill' or 'exec' is highly recommended.

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
