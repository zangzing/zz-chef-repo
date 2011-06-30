run_for_app(:photos => [:solo,:util,:app,:app_master]) do |app_name, role, rails_env|

  template "/usr/bin/zz/resque_scheduler" do
      source "resque_scheduler_runner.erb"
      owner root_user
      group root_group
      mode 0755
  end

  template "/usr/bin/zz/resque" do
      source "resque_worker_runner.erb"
      owner root_user
      group root_group
      mode 0755
  end

  # set up standard number of workers for generic and i/o bound based
  # on machine capacity
  case node[:ec2][:instance_type]
  when 'm1.small': worker_count = 2
  when 'c1.medium': worker_count = 4
  when 'c1.xlarge': worker_count = 8
  else
    worker_count = 4
  end

  # see what kind of queues each type should listen to
  if zz[:app_config][:we_host_resque_cpu]
    #CPU bound jobs only
    queues = "image_processing"
  else
    # all other jobs including special named job tied to machine it originated from
    # this host named job lets us work with things like temp files that only exist
    # on that hos
    queues = "remote_job_#{ZZDeploy.env.this_host_name},mailer,io_local_#{ZZDeploy.env.this_host_name},io_bound,share,facebook,twitter,like,test_queue"
  end
  worker_count.times do |count|
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

  template "/etc/monit.d/resque_#{app}.monitrc" do
    owner root_user
    group root_group
    mode 0644
    source "monitrc.conf.erb"
    variables({
      :num_workers => worker_count,
      :app_name => app_name,
      :rails_env => rails_env,
      :include_scheduler => include_scheduler
      })
    notifies :run, "execute[monit-reload-config]"
  end

end