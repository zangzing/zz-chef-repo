run_for_app(:photos => [:solo,:app,:app_master],
            :rollup => [:solo,:app,:app_master]) do |app_name, role, rails_env|


  if deploy_shutdown?
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
end