run_for_app(:photos => [:solo,:app,:app_master],
            :rollup => [:solo,:app,:app_master]) do |app_name, role, rails_env|

  package "memcached" do
    action :install
  end

  template "/data/#{app_name}/shared/config/memcached_custom.yml" do
    source "memcached.yml.erb"
    owner deploy_user
    group deploy_group
    mode 0744
    variables({
      :app_name => app_name,
      :server_names => zz[:app_config][:app_servers],
      :rails_env => rails_env
      })
  end

  template "/etc/sysconfig/memcached" do
    source "memcached.erb"
    owner root_user
    group root_group
    mode "0644"
    notifies :restart, "service[memcached]", :immediately
  end

  service "memcached" do
    supports :restart => true, :status => true
    action :nothing
  end

  # add ourselves to monit
  template "/etc/monit.d/memcached.monitrc" do
    owner 'root'
    group 'root'
    mode 0644
    source "memcached.monitrc.erb"
    notifies :run, "execute[monit-reload-config]"
  end

end