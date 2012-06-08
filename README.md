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

Current Support
===============

Currently support has only been added for the debian family. Support
for RPM and script installs should be available soon.

Infos
=====

* Repo: https://github.com/heavywater/chef-omnibus_updater


