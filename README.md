# omnibus_updater cookbook

[![Build Status](https://travis-ci.org/chef-cookbooks/omnibus_updater.svg?branch=master)](http://travis-ci.org/chef-cookbooks/omnibus_updater) [![Cookbook Version](https://img.shields.io/cookbook/v/omnibus_updater.svg)](https://supermarket.chef.io/cookbooks/omnibus_updater)

This cookbook allows you to upgrade the omnibus based Chef install package via Chef. You can run either latest or pin to specific version.

## Requirements

### Platforms

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

### Chef

- Chef 11+

### Cookbooks

- none

## Usage

Add the recipe to your run list and specify what version should be installed on the node:

`knife node run_list add recipe[omnibus_updater]`

In your role you'll likely want to set the version. It defaults to nothing, and will install the latest..

```ruby
override_attributes(
  :omnibus_updater => {
    :version => '11.4.0'
  }
)
```

It can also uninstall Chef from the system Ruby installation if you tell it to:

```ruby
override_attributes(
  :omnibus_updater => {
    :remove_chef_system_gem => true
  }
)
```

## Features

### Latest Version

Force installation of the latest version regardless of value stored in version attribute by setting the `force_latest` attribute.

### Chef Killing

By default the omnibus updater will kill the chef instance by raising an exception. You can turn this off using the `kill_chef_on_upgrade` attribute. It is not recommended to turn this off. Internal chef libraries may change, move, or no longer exist. The currently running instance can encounter unexpected states because of this. To prevent this, the updater will attempt to kill the Chef instance so that it can be restarted in a normal state.

## Restart chef-client Service

Use the `restart_chef_service` attribute to restart chef-client if you have it running as a service.

### Prerelease

Prereleases can be installed via the auto-installation using `prerelease` attribute.

### Disable

If you want to disable the updater you can set the `disabled` attribute to true. This might be useful if the cookbook is added to a role but should then be skipped for example on a Chef server.

### Prevent Downgrade

If you want to prevent the updater from downgrading chef on a node, you can set the `prevent_downgrade` attribute to true. This can be useful for testing new versions manually. Note that the `always_download` attribute takes precedence if set.

## Warnings

### Windows Support

Windows support is available in versions 1.0.8 and higher; however, we only support Chef Client versions 12.5.1 and below, due to a [known bug in 12.6.0](https://github.com/chef/chef/issues/4623). This is reflected in the Windows test suite.

If you would like to wrap this cookbook in order to prevent OmnibusUpdater with version 12.6.0 on Windows, you may do something like the following:

```ruby
if (node[:chef_packages][:chef][:version] == '12.6.0') && node[:os].downcase.include?('windows')
  Chef::Log.warn 'Omnibus updater cannot upgrade or downgrade a Windows 12.6.0 installation, skipping'
else
  include_recipe 'omnibus_updater'
end
```

## License & Authors

- Author: Chris Roberts ([chrisroberts.code@gmail.com](mailto:chrisroberts.code@gmail.com))

```text
Copyright:: 2010-2016, Chef Software, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
