run_for_app(:photos => [:solo,:util,:app,:app_master,:db],
            :rollup => [:solo,:util,:app,:app_master,:db]) do |app_name, role, rails_env|


  base_dir = "/data/#{app_name}"
  release_dir = File.readlink("#{base_dir}/current")
  hv = ZZDeploy.env.prep_hook_data(app_name, release_dir)
  chef_base = ZZDeploy.env.project_root_dir

  ruby_code = File.open("#{chef_base}/cookbooks/app-restart/helpers/prep_hook_vars.rb", 'r') {|f| f.read }
  instance_eval(ruby_code)

  # now our own restart code (check to see if user has custom code)
  ruby_code = File.open("#{chef_base}/cookbooks/app-restart/helpers/restart_command.rb", 'r') {|f| f.read }
  instance_eval(ruby_code)

  log "Deploy complete" do
    notifies :run, "execute[maint_mode_off]", :immediately
  end


  # now register this instance with the elb if we are of the proper type
  amazon_elb = zz[:group_config][:amazon_elb]
  if !amazon_elb.empty? && [:solo,:app,:app_master].include?(role)
    # run in a ruby block so this happens in recipe convergence
    ruby_block "reload_client_config" do
      block do
        elb = Chef::Recipe::ZZDeploy.env.elb
        elb.register_instances_with_load_balancer(amazon_elb, zz[:instance_id])
      end
    end
  end
end