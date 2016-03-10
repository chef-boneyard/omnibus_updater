#
# Cookbook Name:: omnibus_updater
# Library:: omnitrucker
#
# Copyright 2014, Heavy Water Ops, LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require "chef/rest"
require "chef/mash"
require "net/http"

unless(Chef.constants.include?(:Mash))
  Chef::Mash = Mash
end

module OmnibusTrucker
  class << self
    URL_MAP = {
      :p => :platform, :pv => :platform_version, :m => :machine,
      :v => :version, :prerelease => :prerelease,
      :nightlies => :nightlies
    }  unless defined?(URL_MAP)

    def build_url(*opts)
      args = node = nil
      opts.each do |o|
        if(o.kind_of?(Hash))
          args = o
        elsif(o.kind_of?(Chef::Node))
          node = o
        else
          raise ArgumentError.new "Provided argument is not allowed: #{o.class}"
        end
      end
      args ||= {}
      if(node)
        args = collect_attributes(node).merge(args)
      end
      url = args[:url] || "http://www.chef.io/chef/download#{'-server' if args[:server]}"
      u_args = URL_MAP.map do |u_k, a_k|
        "#{u_k}=#{args[a_k]}" unless args[a_k].nil?
      end.compact
      "#{url}?#{u_args.join('&')}"
    end

    def collect_attributes(node, args={})
      set = Chef::Mash[
        [:platform_family, :platform, :platform_version].map do |k|
          [k, args[k] || node[k]]
        end
      ]
      unless(@attrs)
        if(set[:platform] == 'amazon')
          @attrs = {:platform => 'el', :platform_version => 6}
        elsif(set[:platform_family] == 'fedora')
          @attrs = {:platform => 'el', :platform_version => 6}
        elsif(set[:platform_family] == 'rhel')
          @attrs = {:platform => 'el', :platform_version => set[:platform_version].to_i}
        elsif(set[:platform] == 'debian')
          @attrs = {:platform => set[:platform], :platform_version => set[:platform_version].to_i}
        elsif(set[:platform_family] == 'mac_os_x')
          @attrs = {:platform => set[:platform_family], :platform_version => [set[:platform_version].to_f, 10.7].min}
        elsif(set[:platform_family] == 'windows')
          @attrs ={:platform => set[:platform], :platform_version => '2008r2'}
        else
          @attrs = {:platform => set[:platform], :platform_version => set[:platform_version]}
        end
        @attrs[:machine] = args[:machine] || node[:kernel][:machine]
        @attrs[:machine] = "i386" if(set[:platform_family] == 'solaris2' && @attrs[:machine] == "i86pc")
      end
      @attrs
    end

    def url(url_or_node, node = nil)
      if(url_or_node.is_a?(Chef::Node))
        url = build_url(url_or_node)
        node = url_or_node
      else
        url = url_or_node
        raise "Node instance is required for Omnitruck.url!" unless node
      end
      request = Chef::REST::RESTRequest.new(:head, URI.parse(url), nil)
      result = request.call
      if(result.kind_of?(Net::HTTPRedirection))
        result['location']
      end
    end

  end
end
