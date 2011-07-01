run_for_app(:photos => [:solo,:util,:app,:app_master,:db],
            :rollup => [:solo,:util,:app,:app_master,:db]) do |app_name, role, rails_env|

  # set up any items we want to pass into the hooks via the for_hook hash
  base_dir = "/data/#{app_name}"
  shared_dir = "#{base_dir}/shared"
  current_dir = "#{base_dir}/current"
  for_hook = {
      :base_dir => base_dir,
      :shared_dir => shared_dir,
      :current_dir => current_dir,
      :deploy_user => deploy_user,
      :deploy_group => deploy_group,
      :release_dir => '', #todo get this from fs
      :zz => node[:zz]
  }
  chef_base = ZZDeploy.env.project_root_dir

  ruby_code = File.open("#{chef_base}/cookbooks/app-restart/helpers/prep_hook_vars.rb", 'r') {|f| f.read }
  instance_eval(ruby_code)

  # now our own restart code (check to see if user has custom code)
  ruby_code = File.open("#{chef_base}/cookbooks/app-restart/helpers/restart_command.rb", 'r') {|f| f.read }
  instance_eval(ruby_code)

end