#
# Cookbook Name:: ruby-env 
# Recipe:: default 
#
# Author:: Ryuzee <ryuzee@gmail.com>
#
# Copyright 2013, Ryutaro YOSHIBA 
#
# This software is released under the MIT License.
# http://opensource.org/licenses/mit-license.php

case node["platform"]
when "centos"

  include_recipe "build-essential"
  include_recipe "git"
  include_recipe "ca-certificates::default"

  %w{sqlite-devel openssl-devel readline-devel}.each do |p|
    package p do
      action :install
    end
  end

  git "/home/#{node['ruby-env']['user']}/.rbenv" do
    repository "https://github.com/sstephenson/rbenv.git"
    user #{node['ruby-env']['user']}
    group #{node['ruby-env']['group']}
    not_if { File.exists?("/home/#{node['ruby-env']['user']}/.rbenv") }
    action :sync
  end

#  execute "rbenv_install" do
#    command "git clone https://github.com/sstephenson/rbenv.git /home/#{node['ruby-env']['user']}/.rbenv"
#    user #{node['ruby-env']['user']}
#    group #{node['ruby-env']['group']}
#    environment 'HOME' => "/home/#{node['ruby-env']['user']}"
#    not_if { File.exists?("/home/#{node['ruby-env']['user']}/.rbenv") }
#  end

  template ".bash_profile" do
    source ".bash_profile.erb"
    path   "/home/#{node['ruby-env']['user']}/.bash_profile"
    mode   0644
    owner  #{node['ruby-env']['user']}
    group  #{node['ruby-env']['group']}
    not_if "grep rbenv ~/.bash_profile", :environment => { :'HOME' => "/home/#{node['ruby-env']['user']}" }
  end

  execute "ruby-build_install" do
    command "git clone https://github.com/sstephenson/ruby-build.git /home/#{node['ruby-env']['user']}/.rbenv/plugins/ruby-build"
    user #{node['ruby-env']['user']}
    group #{node['ruby-env']['group']}
    environment 'HOME' => "/home/#{node['ruby-env']['user']}"
    not_if { File.exists?("/home/#{node['ruby-env']['user']}/.rbenv/plugins/ruby-build")}
  end

  execute "rbenv install #{node['ruby-env']['version']}" do
    command "/home/#{node['ruby-env']['user']}/.rbenv/bin/rbenv install #{node['ruby-env']['version']}"
    user #{node['ruby-env']['user']}
    group #{node['ruby-env']['group']}
    environment 'HOME' => "/home/#{node['ruby-env']['user']}"
    not_if { File.exists?("/home/#{node['ruby-env']['user']}/.rbenv/versions/#{node['ruby-env']['version']}")}
  end

  execute "rbenv global #{node['ruby-env']['version']}" do
    command "/home/#{node['ruby-env']['user']}/.rbenv/bin/rbenv global #{node['ruby-env']['version']}"
    user #{node['ruby-env']['user']}
    group #{node['ruby-env']['group']}
    environment 'HOME' => "/home/#{node['ruby-env']['user']}"
  end

  %w{rbenv-rehash unicorn bundler rails}.each do |p| 
    execute "gem install #{p} --no-ri --no-rdoc" do
      command "/home/#{node['ruby-env']['user']}/.rbenv/shims/gem install #{p}"
      user #{node['ruby-env']['user']}
      group #{node['ruby-env']['group']}
      environment 'HOME' => "/home/#{node['ruby-env']['user']}"
      not_if { system("/home/#{node['ruby-env']['user']}/.rbenv/shims/gem which #{p}") }
    end
  end

end
