OmnibusUpdater
==============

Update your omnibus! This cookbook can install the omnibus
Chef package into your system if you are currently running
via gem install, and it can keep your omnibus install up
to date.

Usage
=====

Add the recipe to your run list and specify what version should
be installed on the node:

`knife node run_list add recipe[omnibus_updater]`

In your role you'll likely want to set the version (it defaults
to the 0.10.10 version of Chef):

```
override_attributes(
  :omnibus_updater => {
    :version => '10.12.0.rc.1'
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
---
If you are using a Chef version earlier than 10.12.0 you may want
to take a look at the chef_gem cookbook to ensure gems are going
where expected.
---

The default recipe will install the omnibus package based
on system information but you can override that by using
the `install_via` attribute which accepts: deb, rpm or script.

Infos
=====

* Repo: https://github.com/hw-cookbooks/omnibus_updater


