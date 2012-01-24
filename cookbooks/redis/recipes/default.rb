run_for_app(:photos => [:solo,:util,:app,:app_master,:db,:db_slave,:local]) do |app_name, role, rails_env|

    # for local dev we config some things differently
    is_local_dev = role == :local
    if is_local_dev
      redis_user = deploy_user
      redis_group = deploy_group
    else
      redis_user = "redis"
      redis_group = "redis"
    end

    redis_port = "6379"
    redis_server = zz[:app_config][:redis_host]
    redis_address = "#{redis_server}:#{redis_port}"
    we_are_redis_slave = zz[:app_config][:we_host_redis_slave]

    # first the application related support
    # we don't install redis for these, we just need the rails
    # config files that point to it

    # only override default yml on app servers
    # we depend on a symlink in the before_restart
    # deploy hook to symlink to this file
    template "/data/#{app_name}/shared/config/redis.yml" do
      source "redis.yml.erb"
      owner deploy_user
      group deploy_group
      mode 0644
      variables({
        :rails_env => rails_env,
        :redis_address => redis_address
        })
    end


    # now do the stuff that installs redis itself - there is no
    # nice neat package for the version we want so install from source
    if [:local, :solo, :db, :db_slave].include?(role)
      # install redis itself
      version =  "2.2.11"
      # do a version check to avoid having to install if we already have proper version
      `redis-server -v | grep 'version 2\.2\.11'`
      already_installed = $?.exitstatus == 0

      name = "redis"
      work_dir = "/tmp"
      install_prefix = is_local_dev ? "/usr/local" : "/usr"

      if role != :local
        # put the base level package on the machine, we will upgrade via the compile below
        package "redis" do
          action :install
          not_if {already_installed}
        end

        destination_cmd = "sudo cp #{install_prefix}/bin/redis-server /usr/sbin/redis-server"
      else
        destination_cmd = "echo"
      end

      #Download remote source into /tmp directory
      cookbook_file "#{work_dir}/#{name}-#{version}.tar.gz" do
        source "#{name}-#{version}.tar.gz"
        action :create_if_missing
        not_if {already_installed}
      end

      # Compile and Install
      bash "compile_#{name}_source" do
        Chef::Log.info( "ZangZing=> #{name} building from source and installing")
        cwd "#{work_dir}"
        code <<-EOH
          tar zxf #{name}-#{version}.tar.gz
          cd #{name}-#{version}
          sudo make
          sudo rm -rf #{install_prefix}/bin/redis-*
          sudo rm -rf #{install_prefix}/sbin/redis-*
          sudo rm -rf /usr/sbin/redis-*
          sudo make install PREFIX=#{install_prefix}
          #{destination_cmd}
        EOH
        not_if {already_installed}
      end

      # Clean Up Tmp File
      execute "Clean Up #{work_dir}/#{name} files" do
        command "rm -rf #{work_dir}/#{name}-#{version}*"
        not_if {already_installed}
      end


      # now set up redis config files and directories

      # the redis db goes here
      directory "/db" do
        owner redis_user
        group redis_group
        mode "775"
        action :create
      end

      directory "/db/redis" do
        owner redis_user
        group redis_group
        mode "775"
        action :create
        recursive true
      end

      directory "/var/run/redis" do
        mode "775"
        action :create
      end


      # install the configuration
      template "/etc/redis.conf" do
        source "redis.conf.erb"
        owner root_user
        group root_group
        mode 0644
        variables({
          :redis_server => redis_server,
          :redis_port => redis_port,
          :we_are_redis_slave => we_are_redis_slave
          })
        notifies :restart, "service[redis]" unless is_local_dev
        notifies :enable, "service[redis]" unless is_local_dev
        notifies :run, "bash[redis_local_restart]" if is_local_dev
      end

      if is_local_dev
        bash "redis_local_restart" do
          Chef::Log.info( "ZangZing=> restarting dev redis")
          code <<-EOH
            #{install_prefix}/bin/redis-cli shutdown
            sudo #{install_prefix}/bin/redis-server /etc/redis.conf
          EOH
          action :nothing
        end
      else
#        execute "Restart redis" do
#          command "sudo monit restart redis"
#          Chef::Log.info("ZangZing=> redis restarting...")
#          not_if {already_installed}
#        end

        service "redis" do
          supports :restart => true, :status => true
          action :nothing
        end
      end

      # run a cron job once a day to rewrite aof file
      cron "aof_writer" do
        command "/bin/bash -l -c 'redis-cli BGREWRITEAOF >> /data/#{app_name}/shared/log/cron.log 2>&1'"
        hour "1"
        minute "0"
#        user deploy_user
      end
    end

end