run_for_app(:photos => [:solo,:util,:app,:app_master,:db],
            :rollup => [:solo,:util,:app,:app_master,:db]) do |app_name, role, rails_env|

  base_dir = "/data/#{app_name}"
  shared_dir = "#{base_dir}/shared"
  current_dir = "#{base_dir}/current"
  for_hook = {
      :base_dir => base_dir,
      :shared_dir => shared_dir,
      :current_dir => current_dir,
      :zz => node[:zz]
  }

  deploy base_dir do
    repo zz[:group_config][:app_git_url]
    revision zz[:app_deploy_tag]
    user deploy_user
    group deploy_group
    migrate false
    migration_command "rake db:migrate"
    action :deploy # or :rollback
    before_migrate do
      hv = for_hook
      hv[:release_dir] = release_path

      ruby_code = File.open("/var/chef/cookbooks/zz-chef-repo/cookbooks/app-deploy/helpers/prep_hook_vars.rb", 'r') {|f| f.read }
      instance_eval(ruby_code)

      # read the file to reference
      ruby_code = File.open("/var/chef/cookbooks/zz-chef-repo/cookbooks/app-deploy/testing/before_migrate.rb", 'r') {|f| f.read }
      puts "******************* EVAL RUBY CODE *****************"
      instance_eval(ruby_code)


      ruby_code = File.open("/var/chef/cookbooks/zz-chef-repo/cookbooks/app-deploy/testing/before_migrate_sub.rb", 'r') {|f| f.read }
      puts "******************* EVAL RUBY CODE *****************"
      instance_eval(ruby_code)

    end
    before_symlink {}
    before_restart {}
    after_restart {}
    restart_command "echo `date` > tmp/restart.txt"
  end

end