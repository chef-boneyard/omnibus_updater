require 'spec_helper'

describe 'omnibus_updater::default on unsupported platform' do
  cached(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'opensuse', version: '13.2').converge('omnibus_updater::default')
  end

  it 'logs a warning that the platform is unsupported' do
    expect { chef_run }.to raise_error
  end
end

describe 'omnibus_updater::default with no attributes set' do
  cached(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04').converge('omnibus_updater::default')
  end

  it 'compiles without any errors' do
    expect { chef_run }.to_not raise_error
  end

  it 'includes the downloader recipe' do
    expect(chef_run).to include_recipe('omnibus_updater::downloader')
  end

  it 'includes the installer recipe' do
    expect(chef_run).to include_recipe('omnibus_updater::installer')
  end

  it 'includes the old_package_cleaner recipe' do
    expect(chef_run).to include_recipe('omnibus_updater::old_package_cleaner')
  end

  it 'does not include the remove_chef_system_gem recipe' do
    expect(chef_run).to_not include_recipe('omnibus_updater::remove_chef_system_gem')
  end
end

describe 'omnibus_updater::default with remove_chef_system_gem set' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.normal['omnibus_updater']['remove_chef_system_gem'] = true
    end.converge(described_recipe)

    it 'includes the remove_chef_system_gem recipe' do
      expect(chef_run).to include_recipe('omnibus_updater::remove_chef_system_gem')
    end
  end
end
