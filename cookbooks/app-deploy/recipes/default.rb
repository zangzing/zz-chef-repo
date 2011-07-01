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
      :zz => node[:zz]
  }
  chef_base = ZZDeploy.env.project_root_dir

  deploy base_dir do
    repo zz[:group_config][:app_git_url]
    revision zz[:app_deploy_tag]
    user deploy_user
    group deploy_group
    migrate false
    migration_command "rake db:migrate"
    action :rollback # or :rollback
    before_migrate do
      hv = for_hook
      hv[:release_dir] = release_path

      # prep vars we want to pass
      ruby_code = File.open("#{chef_base}/cookbooks/app-deploy/helpers/prep_hook_vars.rb", 'r') {|f| f.read }
      instance_eval(ruby_code)

      # now our own hook code
      ruby_code = File.open("#{chef_base}/cookbooks/app-deploy/helpers/before_migrate.rb", 'r') {|f| f.read }
      instance_eval(ruby_code)

      # and finally the app code if it has a hook in the deploy dir
      ruby_code = File.open("#{release_path}/deploy/before_migrate.rb", 'r') {|f| f.read } rescue nil
      #instance_eval(ruby_code) if !ruby_code.nil?
    end
    before_symlink do
      hv = for_hook
      hv[:release_dir] = release_path

      # prep vars we want to pass
      ruby_code = File.open("#{chef_base}/cookbooks/app-deploy/helpers/prep_hook_vars.rb", 'r') {|f| f.read }
      instance_eval(ruby_code)

      # now our own hook code
      ruby_code = File.open("#{chef_base}/cookbooks/app-deploy/helpers/before_symlink.rb", 'r') {|f| f.read }
      instance_eval(ruby_code)

      # and finally the app code if it has a hook in the deploy dir
      ruby_code = File.open("#{release_path}/deploy/before_symlink.rb", 'r') {|f| f.read } rescue nil
      #instance_eval(ruby_code) if !ruby_code.nil?
    end
    before_restart do
      hv = for_hook
      hv[:release_dir] = release_path

      # prep vars we want to pass
      ruby_code = File.open("#{chef_base}/cookbooks/app-deploy/helpers/prep_hook_vars.rb", 'r') {|f| f.read }
      instance_eval(ruby_code)

      # now our own hook code
      ruby_code = File.open("#{chef_base}/cookbooks/app-deploy/helpers/before_restart.rb", 'r') {|f| f.read }
      instance_eval(ruby_code)

      user_id = Etc.getpwnam(node[:zz][:deploy_user]).uid
      group_id = Etc.getgrnam(node[:zz][:deploy_group]).gid
      Process::UID.change_privilege(user_id)
      Process::GID.change_privilege(group_id)


      # and finally the app code if it has a hook in the deploy dir
      ruby_code = File.open("#{release_path}/deploy/before_restart.rb", 'r') {|f| f.read } rescue nil
      #instance_eval(ruby_code) if !ruby_code.nil?
    end
    after_restart do
      hv = for_hook
      hv[:release_dir] = release_path

      # prep vars we want to pass
      ruby_code = File.open("#{chef_base}/cookbooks/app-deploy/helpers/prep_hook_vars.rb", 'r') {|f| f.read }
      instance_eval(ruby_code)

      # now our own hook code
      ruby_code = File.open("#{chef_base}/cookbooks/app-deploy/helpers/after_restart.rb", 'r') {|f| f.read }
      instance_eval(ruby_code)

      # and finally the app code if it has a hook in the deploy dir
      ruby_code = File.open("#{release_path}/deploy/after_restart.rb", 'r') {|f| f.read } rescue nil
      #instance_eval(ruby_code) if !ruby_code.nil?
    end
    restart_command do
      hv = for_hook
      hv[:release_dir] = release_path

      # prep vars we want to pass
      ruby_code = File.open("#{chef_base}/cookbooks/app-deploy/helpers/prep_hook_vars.rb", 'r') {|f| f.read }
      instance_eval(ruby_code)

      # now our own hook code
      ruby_code = File.open("#{chef_base}/cookbooks/app-deploy/helpers/restart_command.rb", 'r') {|f| f.read }
      instance_eval(ruby_code)
    end
  end

end