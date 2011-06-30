run_for_app(:photos => [:solo,:app,:app_master],
            :rollup => [:solo,:app,:app_master]) do |app_name, role, rails_env|

  # only override default yml on app servers
  # we depend on a symlink in the before_restart
  # deploy hook to symlink to this file
  template "/data/#{app_name}/shared/config/unicorn.rb" do
    source "unicorn.rb.erb"
    owner deploy_user
    group deploy_group
    mode 0644
    variables({
      :app_name => app_name
      })
  end

end