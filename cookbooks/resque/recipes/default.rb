run_for_app(:photos => [:solo,:util,:app,:app_master]) do |app_name, role, rails_env|

  # see what kind of queues each type should listen to
  if zz[:app_config][:we_host_resque_cpu]
    #CPU bound jobs only
    num_workers = zz_env.cpu_worker_count
    queues = "image_edit,image_processing"
  else
    # all other jobs including special named job tied to machine it originated from
    # this host named job lets us work with things like temp files that only exist
    # on that hos
    num_workers = zz_env.worker_count
    queues = "remote_job_#{ZZDeploy.env.this_host_name},mailer,io_local_#{ZZDeploy.env.this_host_name},io_bound,share,facebook,twitter,like,io_bound_low,test_queue"
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

end