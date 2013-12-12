#
# Cookbook Name:: ruby-env 
# Recipe:: nginx 
#
# Author:: Ryuzee <ryuzee@gmail.com>
#
# Copyright 2013, Ryutaro YOSHIBA 
#
# This software is released under the MIT License.
# http://opensource.org/licenses/mit-license.php

include_recipe "nginx"

template 'ruby-env.conf' do
  path '/etc/nginx/conf.d/server/ruby-env.conf'
  source 'ruby-env.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

template 'upstream.conf' do
  path "/etc/nginx/conf.d/upstream_#{node["ruby-env"]["unicorn_sock_name"]}.conf"
  source 'upstream.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, "service[nginx]"
end
