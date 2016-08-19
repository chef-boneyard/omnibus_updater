require 'spec_helper'

describe 'omnibus_updater::default' do
  let(:chef_run) do
    ChefSpec::ServerRunner.new(platform: 'redhat', version: '7.0') do |node, server|
    end.converge(described_recipe)
  end

  it 'should complie without any errors' do
    expect { chef_run }.to_not raise_error
  end
end
