run_for_app(:photos => [:solo,:util,:app,:app_master],
            :rollup => [:solo,:util,:app,:app_master]) do |app_name, role, rails_env|


  release_dir = File.readlink(ZZDeploy.env.current_dir)
  hv = ZZDeploy.env.prep_hook_data(app_name, release_dir)
  chef_base = ZZDeploy.env.project_root_dir

  ruby_code = File.open("#{chef_base}/cookbooks/app-restart/helpers/prep_hook_vars.rb", 'r') {|f| f.read }
  instance_eval(ruby_code)

  # now our own restart code (check to see if user has custom code)
  ruby_code = File.open("#{chef_base}/cookbooks/app-restart/helpers/restart_command.rb", 'r') {|f| f.read }
  instance_eval(ruby_code)

  # and finally the app code if it has a hook in the deploy dir
  ruby_code = File.open("#{release_path}/deploy/custom_restart.rb", 'r') {|f| f.read } rescue ruby_code = nil
  instance_eval(ruby_code) if !ruby_code.nil?

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