# omnibus_updater Cookbook CHANGELOG

This file is used to list changes made in each version of the omnibus_updater cookbook.

## 3.0.2 (2017-03-07)

- Fix version detection for macOS systems
- Test with Local Delivery instead of Rake

## 3.0.1 (2017-01-05)

- Remove the remaining system gem reference

## 3.0.0 (2017-01-05)

- Added support for the new upgrade exit code (213) introduced with RFC062 and first shipped in chef 12.15.19
- Fix support for upgrading Windows client 12.6 and later by first moving the install directory
- Remove the recipe to cleanup system ruby chef installs. We should assume everyone is on Omnibus installs at this point and this same functionality can be easily implemented in your own recipes
- Added suse, opensuse, and opensuseleap to the metadata

## 2.0.0 (2016-08-19)

- Hard fail on unsupported platforms now
- Add suse support
- Add additional chefspec tests

## 1.2.1 (2016-08-19)

- Use the improved rakefile
- Fix github URLs in the metadata
- Add testing on additional platforms to kitchen config
- fix 1.2.0 no implicit conversion of nil to string. fixes #123

## 1.2.0 (2016-08-18)

- Add OS X DMG Support and fix Mac OS X Version Determination
- Add a potential Restart Fix
- Add chef_version metadata to the metadata.rb file
- Change maintainership to Chef and add standard Chef contributing, test, and maintainer docs
- Renamed the test recipe for consistency and removed the use of minitest
- Swapped Librarian for Berkshelf
- Added testing in Travis CI using ChefDK
- Resolved Foodcritic FC001/FC043 warnings
- Resolved all Cookstyle warnings
- Identify Fedora to be EL7 not EL6
- Avoid a node.set deprecation warning
- No need to warn on Debian 5\. No one should be on this now.
- Add a test for the standard flows

# v1.1.0

- Add Windows support (only Chef client versions 12.5.1 and below).
- Improve upgrade behavior on Amazon Linux
- Explicitly require windows testing gems in order to support test-kitchen 1.6.x.

# v1.0.6

- Get rid of warnings about defined constant
- update Chef download url
- Updates supported versions
- require chef/rest
- use Chef::Mash explicitly
- Define the Chef::Mash constant if not provided by chef
- add test suites for ubuntu 14.04 and centos 7

# v1.0.4

- file_cache_path path to store chef-client
- Avoid deleting chef-server packages if using the same cache dir
- Only backup the last old chef client file
- make sure directory exists before trying to write to it

# v1.0.2

- Maintenance updates
- Support for Fedora
- omnitrucker solaris update
- bug fixes

# v1.0.0

- Breaking change: `:always_download` is now defaulted to false
- Add solaris package install support (#37 thanks @jtimberman)
- Update notifies/subscribes usage to support older Chefs (#38 thanks @spheromak)

# v0.2.8

- Always download the package (thanks @miketheman for swiftly pointing out the issue!)

# v0.2.6

- Work with amazon linux (thanks @thommay)
- Disable updates on debian 5 (thanks @ianand0204)
- Only use major version on debian systems (thanks @kvs)
- Allow prevention of downgrades (thanks @buysse)
- Add support for restarting chef service after upgrade (thanks @andrewfraley)

# v0.2.4

- Only download omnibus package if version difference detected (#20 #22 #23)
- Provide attribute for always downloading package even if version matches

# v0.2.3

- Use chef internals for interactions with omnitruck to provide proper proxy support (#19)

# v0.2.0

- Use omnitruck client for url generation for package fetching
- Use `prerelease` in favor of `allow_release_clients`

# v0.1.2

- Fix regression on debian package path construction (thanks [ashmere](https://github.com/ashmere))

# v0.1.1

- Search for proper version suffix if not provided (removes default '-1')
- Do not allow release clients by default when version search is enabled
- Push omnibus package installation to the end of run (reduces issue described in #10)
- Allow updater to be disabled via attribute (thanks [Teemu Matilainen](https://github.com/tmatilai))

# v0.1.0

- Fix redhat related versioning issues
- Remove requirement for '-1' suffix on versions
- Initial support for automatic latest version install

# v0.0.5

- Add support for Ubuntu 12.10
- Path fixes for non-64 bit packages (thanks [ashmere](https://github.com/ashmere))

# v0.0.4

- Use new aws bucket by default
- Update file key building

# v0.0.3

- Path fix for debian omnibus packages (thanks [ashmere](https://github.com/ashmere))

# v0.0.2

- Add robust check when uninstalling chef gem to prevent removal from omnibus

# v0.0.1

- Initial release
