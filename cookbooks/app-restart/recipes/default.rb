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

end