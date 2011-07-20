# set up the ruby env
#cookbook_file "/home/ec2-user/test.jpg" do
#  source "test.jpg"
#  mode 0755
#  owner deploy_user
#  group deploy_group
#end

run_for_app(:photos => [:solo,:util,:app,:app_master,:db,:local],
            :rollup => [:solo,:util,:app,:app_master,:db,:local]) do |app_name, role, rails_env|

  # utility commands go here
  directory "/usr/bin/zz" do
    owner deploy_user
    group deploy_group
    mode "0755"
    action :create
  end

  directory "/var/run/zz" do
    owner deploy_user
    group deploy_group
    mode "0755"
    action :create
  end

  directory "/var/run/zz/resque" do
    owner deploy_user
    group deploy_group
    mode "0755"
    action :create
  end

  # we do each part to get the right permissions at each node
  directory "/data" do
    owner deploy_user
    group deploy_group
    mode "0755"
    action :create
  end

  directory "/data/global" do
    owner deploy_user
    group deploy_group
    mode "0755"
    action :create
  end

  # move scripts to /data/global/bin
  scripts = ['unicorn_start.rb', 'unicorn_stop.rb', 'resque_start.rb', 'resque_stop.rb']
  scripts.each do |script|
    cookbook_file "/usr/bin/zz/#{script}" do
      source "#{script}"
      owner deploy_user
      group deploy_group
      mode "0755"
    end
  end

  directory "/data/#{app_name}" do
    owner deploy_user
    group deploy_group
    mode "0755"
    action :create
  end

  directory "/data/#{app_name}/shared" do
    owner deploy_user
    group deploy_group
    mode "0755"
    action :create
  end

  directory "/data/#{app_name}/shared/config" do
    owner deploy_user
    group deploy_group
    mode "0755"
    action :create
  end

  directory "/data/#{app_name}/shared/system" do
    owner deploy_user
    group deploy_group
    mode "0755"
    action :create
  end

  directory "/data/#{app_name}/shared/log" do
    owner deploy_user
    group deploy_group
    mode "0755"
    action :create
  end

  if role != :local
    template "/etc/profile.d/rubyenv.sh" do
      source "rubyenv.sh.erb"
      owner deploy_user
      group deploy_group
      mode "0644"
      variables({
        :rails_env => rails_env
      })
    end
  end


end
