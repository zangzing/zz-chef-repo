run_for_app(:photos => [:solo,:util,:app,:app_master],
            :rollup => [:solo,:util,:app,:app_master]) do |app_name, role, rails_env|

  # set up any items we want to pass into the hooks via the for_hook hash
  base_dir = "/data/#{app_name}"
  chef_base = ZZDeploy.env.project_root_dir

  # set up symlinks wanted based on app
  # common ones first
  symlinks = {
      "config/database.yml" => "config/database.yml",
      "config/memcached.yml" => "config/memcached.yml",
      "config/unicorn.rb" => "config/unicorn.rb",
      "system" => "public/system",
      "log" => "log",
  }
  case app_name
    when :photos
      symlinks["config/database-cache.yml"] = "sub_migrates/cache_builder/config/database.yml"
      symlinks["config/redis.yml"] = "config/redis.yml"
      symlinks["config/resque.yml"] = "config/resque.yml"

    when :rollup
      symlinks["config/database-photos.yml"] = "config/database-photos.yml"
      symlinks["config/database-zza.yml"] = "config/database-zza.yml"
  end

  deploy base_dir do
    repo zz[:group_config][:app_git_url]
    revision zz[:app_deploy_tag]
    user deploy_user
    group deploy_group
    symlink_before_migrate symlinks
    migrate false
    action :deploy
    before_migrate do
    end
    before_symlink do
      # this code is here rather than before_migrate because we want the symlinks from the migrate
      # hooked up - any failure here does not change current
      Chef::Recipe::ZZDeploy.env.release_dir = release_path  # now that we know the release path set it

      # prep vars we want to pass
      run_external_code("#{chef_base}/cookbooks/app-deploy/helpers", "prep_hook_vars.rb", true)

      # now our own hook code
      run_external_code("#{chef_base}/cookbooks/app-deploy/helpers", "prepare_config.rb", true)

      # call app specific hook if it exists
      run_external_code("#{release_path}/deploy", "zz_before_migrate.rb", false)

      # now our own hook code
      run_external_code("#{chef_base}/cookbooks/app-deploy/helpers", "do_migrate.rb", true)
    end
    before_restart do
    end
    after_restart do
    end
    restart_command do
    end
  end

end