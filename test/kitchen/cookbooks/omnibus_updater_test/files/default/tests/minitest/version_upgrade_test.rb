require 'minitest/spec'
require 'rexml/document'
require 'open-uri'

describe_recipe 'omnibus_updater_test::search' do
  include MiniTest::Chef::Assertions

  it "sets remote package location" do
    assert(node[:omnibus_updater][:full_uri], "Failed to set URI for omnibus package")
  end

  it "downloads the package to the node" do
    file("/opt/#{File.basename(node[:omnibus_updater][:full_uri])}").must_exist
  end

  it "installs the proper version into the node" do
    expected_version = REXML::Document.new(
      open(node[:omnibus_updater][:base_uri])
    ).elements.to_a('//Contents//Key').map(&:text).find_all{|x|
      x.include?('.deb') && !x.include?('.rc') && !x.include?('server')
    }.map{|x| x.scan(%r{\d+.\d+.\d+}).first }.flatten.sort.last
    assert_equal(
      expected_version,
      `chef-client --version`.strip.scan(/\d+\.\d+\.\d+/).first,
      "Installed chef version does not match version execpted: #{expected_version}"
    )
  end
end
