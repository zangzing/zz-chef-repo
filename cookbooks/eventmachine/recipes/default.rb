run_for_app(:photos => [:solo,:app,:app_master],
            :rollup => [:solo,:app,:app_master]) do |app_name, role, rails_env|

  current_dir = zz_env.current_dir + "/eventmachine"
  num_workers = 1

  template "/etc/monit.d/eventmachine_#{app_name}.monitrc" do
    owner root_user
    group root_group
    mode 0644
    source "monitrc.conf.erb"
    variables({
      :group => deploy_group,
      :user => deploy_user,
      :num_workers => num_workers,
      :app_name => app_name,
      :current_dir =>  current_dir,
      :rails_env => rails_env
      })
    notifies :run, "execute[monit-reload-config]"
  end

end