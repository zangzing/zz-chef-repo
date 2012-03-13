run_for_app(:photos => [:solo,:util,:app,:app_master]) do |app_name, role, rails_env|

  # see what kind of queues each type should listen to
  cpu_queues = "image_edit,image_processing"
  # todo after we let current work drain, switch over completely to new queues
  cpu_queues += ",cpu_100,cpu_090,cpu_080,cpu_070,cpu_060,cpu_050,cpu_040,cpu_030,cpu_020,cpu_010"
  # todo keep remote_job, all others can go after switch
  app_queues = "remote_job_#{ZZDeploy.env.this_host_name},mailer_high,io_bound_high,mailer,io_local_#{ZZDeploy.env.this_host_name},facebook,twitter,like,io_bound,share,io_bound_low,mailer_low,test_queue"
  app_queues += ",io_local_#{ZZDeploy.env.this_host_name}_100,io_local_#{ZZDeploy.env.this_host_name}_050,io_local_#{ZZDeploy.env.this_host_name}_030,io_100,io_090,io_080,io_070,io_060,io_050,io_040,io_030,io_020,io_010"
  if role == :solo
    num_workers = 4
    # all the queues when solo
    queues = [app_queues,cpu_queues].join(',')
  elsif zz[:app_config][:we_host_resque_cpu]
    #CPU bound jobs only
    num_workers = zz_env.cpu_worker_count
    queues = cpu_queues
  else
    # all other jobs including special named job tied to machine it originated from
    # this host named job lets us work with things like temp files that only exist
    # on that hos
    num_workers = zz_env.worker_count
    queues = app_queues
  end
  num_workers.times do |count|
      template "/data/#{app_name}/shared/config/resque_#{count}.conf" do
        owner deploy_user
        group deploy_group
        mode 0644
        source "resque_wildcard.conf.erb"
        variables({
          :queue_args => queues
          })
      end
  end

  # create a config file in shared that is used to override default resque.yml
  template "/data/#{app_name}/shared/config/resque.yml" do
    owner deploy_user
    group deploy_group
    mode 0644
    source "resque.yml.erb"
    variables({
      :rails_env => rails_env,
      :redis_server => zz[:app_config][:redis_host] + ":6379"
      })
  end

  include_scheduler = zz[:app_config][:we_host_resque_scheduler]
  current_dir = zz_env.current_dir

  template "/etc/monit.d/resque_#{app_name}.monitrc" do
    owner root_user
    group root_group
    mode 0644
    source "monitrc.conf.erb"
    variables({
      :num_workers => num_workers,
      :app_name => app_name,
      :current_dir =>  current_dir,
      :rails_env => rails_env,
      :deploy_user => deploy_user,
      :include_scheduler => include_scheduler
      })
    notifies :run, "execute[monit-reload-config]"
    notifies :run, "execute[unmonitor_resque]"
  end

  template "/usr/bin/zzscripts/#{app_name}_resque_start_all" do
    owner deploy_user
    group deploy_group
    mode 0755
    source "start_all.erb"
    variables({
      :num_workers => num_workers,
      :app_name => app_name,
      :current_dir =>  current_dir,
      :rails_env => rails_env,
      :deploy_user => deploy_user,
      :include_scheduler => include_scheduler
      })
  end

  template "/usr/bin/zzscripts/#{app_name}_resque_stop_all" do
    owner deploy_user
    group deploy_group
    mode 0755
    source "stop_all.erb"
    variables({
      :num_workers => num_workers,
      :app_name => app_name,
      :current_dir =>  current_dir,
      :rails_env => rails_env,
      :deploy_user => deploy_user,
      :include_scheduler => include_scheduler
      })
  end

  # turn off monitoring if first time in
  execute "unmonitor_resque" do
    command "sleep 20 && sudo monit -g resque_#{app_name} unmonitor"
    not_if "test -d /data/#{app_name}/current"
    action :nothing
  end

end