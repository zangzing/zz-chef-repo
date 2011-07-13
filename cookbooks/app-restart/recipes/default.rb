run_for_app(:photos => [:solo,:util,:app,:app_master],
            :rollup => [:solo,:util,:app,:app_master]) do |app_name, role, rails_env|


  release_dir = File.readlink(ZZDeploy.env.current_dir)
  Chef::Recipe::ZZDeploy.env.release_dir = release_dir
  chef_base = ZZDeploy.env.project_root_dir

  ZZChefUtils.run_external_code("#{chef_base}/cookbooks/app-deploy/helpers", "prep_hook_vars.rb", true)

  # run any app before restart custom code
  ZZChefUtils.run_external_code("#{release_dir}/deploy", "zz_before_restart.rb", false)

  # see if we have a custom restart override - if this file exists
  # we do not run our normal restart code, instead we leave it up to the
  # app override_restart code to properly restart
  loaded = ZZChefUtils.run_external_code("#{release_dir}/deploy", "zz_override_restart.rb", false)

  if loaded == false
    # no override code so do the standard restart
    Chef::Log.info("Code deployed, now restarting application.")
    run_external_code("#{chef_base}/cookbooks/app-restart/helpers", "restart_command.rb", true)
  end


  if [:solo,:app,:app_master].include?(role)
    log "Deploy complete" do
      notifies :run, "execute[maint_mode_off]", :immediately
    end

    # now register this instance with the elb if we are of the proper type
    amazon_elb = zz[:group_config][:amazon_elb]
    if !amazon_elb.empty?
      # run in a ruby block so this happens in recipe convergence
      ruby_block "attach_elb" do
        block do
          elb = Chef::Recipe::ZZDeploy.env.amazon.elb
          elb.register_instances_with_load_balancer(amazon_elb, zz[:instance_id])
        end
      end
    end
  end

end