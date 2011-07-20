run_for_app(:photos => [:solo,:app,:app_master,:util],
            :rollup => [:solo,:app,:app_master,:util]) do |app_name, role, rails_env|

  package "memcached" do
    action :install
  end

  # build up the list of servers and their weighting, util machines
  # get triple the weight since they have more memory on them
  cache_servers = []  # build list into this
  base_weight = 100
  util_multiplier = 3
  zz[:app_config][:app_servers].each do |server|
    cache_servers << "#{server}:11211:#{base_weight}"
  end
  # now triple the weight on util servers
  zz[:app_config][:util_servers].each do |server|
    cache_servers << "#{server}:11211:#{base_weight * util_multiplier}"
  end

  template "#{ZZDeploy.env.shared_config_dir}/memcached.yml" do
    source "memcached.yml.erb"
    owner deploy_user
    group deploy_group
    mode 0644
    variables({
      :app_name => app_name,
      :cache_servers => cache_servers,
      :rails_env => rails_env
      })
  end

  # util roles get a bigger cache
  base_mem = 64
  cache_size = role == :util ? base_mem * util_multiplier : base_mem
  template "/etc/sysconfig/memcached" do
    source "memcached.erb"
    owner root_user
    group root_group
    mode "0644"
    variables({
      :cache_size => cache_size
      })
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