# set up the ruby env
#cookbook_file "/home/ec2-user/test.jpg" do
#  source "test.jpg"
#  mode 0755
#  owner deploy_user
#  group deploy_group
#end

run_for_app(:photos => [:solo,:util,:app,:app_master,:db,:db_slave,:local],
            :rollup => [:solo,:util,:app,:app_master,:db,:db_slave,:local]) do |app_name, role, rails_env|

  # utility commands go here
  directory "/usr/bin/zzscripts" do
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

  # a place to put temp backups
  directory '/media/ephemeral0/backup' do
    owner deploy_user
    group deploy_group
    mode "1777"
    action :create
    recursive true
  end

  # we do each part to get the right permissions at each node
  directory "/data" do
    owner deploy_user
    group deploy_group
    mode "0755"
    action :create
  end

  directory "/data/tmp" do
    owner deploy_user
    group deploy_group
    mode "0755"
    action :create
  end

  directory "/data/tmp/json_ipc" do
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

  directory "/data/global/profiles" do
    owner deploy_user
    group deploy_group
    mode "0755"
    action :create
  end

  cookbook_file "/data/global/profiles/sRGB.icm" do
    source "sRGB.icm"
    owner deploy_user
    group deploy_group
    mode "0755"
  end

  # move scripts to /data/global/bin
  scripts = ['unicorn_start.rb', 'unicorn_stop.rb', 'resque_start.rb', 'resque_stop.rb', 'zz_cmds.rb']
  scripts.each do |script|
    cookbook_file "/usr/bin/zzscripts/#{script}" do
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
