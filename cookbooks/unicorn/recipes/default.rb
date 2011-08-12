run_for_app(:photos => [:solo,:app,:app_master],
            :rollup => [:solo,:app,:app_master]) do |app_name, role, rails_env|

  current_dir = zz_env.current_dir
  num_workers = zz_env.worker_count

  # only override default yml on app servers
  # we depend on a symlink in the before_restart
  # deploy hook to symlink to this file
  template "/data/#{app_name}/shared/config/unicorn.rb" do
    source "unicorn.rb.erb"
    owner deploy_user
    group deploy_group
    mode 0644
    variables({
      :app_name => app_name,
      :num_workers => num_workers
      })
  end


  template "/etc/monit.d/unicorn_#{app_name}.monitrc" do
    owner root_user
    group root_group
    mode 0644
    source "monitrc.conf.erb"
    variables({
      :num_workers => num_workers,
      :app_name => app_name,
      :current_dir =>  current_dir,
      :rails_env => rails_env
      })
    notifies :run, "execute[monit-reload-config]"
  end

end