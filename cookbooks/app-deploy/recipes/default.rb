run_for_app(:photos => [:solo,:util,:app,:app_master,:db],
            :rollup => [:solo,:util,:app,:app_master,:db]) do |app_name, role, rails_env|

  deploy "/data/#{app_name}" do
    repo zz[:group_config][:app_git_url]
    revision zz[:app_deploy_tag]
    user deploy_user
    group deploy_group
    migrate false
    migration_command "rake db:migrate"
    action :deploy # or :rollback
    before_migrate do
      zz = node[:zz]
      require "/var/chef/cookbooks/zz-chef-repo/cookbooks/app-deploy/testing/before_migrate.rb"
    end
    before_symlink {}
    before_restart {}
    after_restart {}
    restart_command "touch tmp/restart.txt"
  end

end