run_for_app(:photos => [:solo,:app,:app_master,:util],
            :rollup => [:solo,:app,:app_master,:util]) do |app_name, role, rails_env|

  env = ZZDeploy.env
  chef_base = env.project_root_dir

  run_external_code("#{chef_base}/cookbooks/app-deploy/helpers", "prep_hook_vars.rb", true)

  if deploy_shutdown?
    if [:solo,:app,:app_master].include?(role)
      begin
        # deregister ourselves from the elb if there is one
        amazon_elb = zz[:group_config][:amazon_elb]
        if !amazon_elb.empty?
          elb = Chef::Recipe::ZZDeploy.env.amazon.elb
          elb.deregister_instances_with_load_balancer(amazon_elb, zz[:instance_id])
        end
      rescue Exception => ex
        # ignore
      end
    end
    # out of the front end pool, stop all work
    run_external_code("#{chef_base}/cookbooks/app-shutdown/helpers", "shutdown_command.rb", true)
  end
end