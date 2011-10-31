run_for_app(:photos => [:solo,:util,:app,:app_master],
            :rollup => [:solo,:util,:app,:app_master]) do |app_name, role, rails_env|

  # set up any items we want to pass into the hooks via the for_hook hash
  base_dir = "/data/#{app_name}"
  chef_base = ZZDeploy.env.project_root_dir
  old_release_path = File.readlink(ZZDeploy.env.current_dir)

  # set up symlinks wanted based on app
  # common ones first
  # the key is the location of the shared file
  # and the value is the location relative to the current
  # release directory that should symlink to back to the
  # shared dir
  cust_symlinks = {
      "config/database.yml" => "config/database.yml",
      "config/memcached.yml" => "config/memcached.yml",
      "config/unicorn.rb" => "config/unicorn.rb",
      "system" => "public/system",
      "log" => "log",
  }
  case app_name
    when :photos
      cust_symlinks["config/database-cache.yml"] = "sub_migrates/cache_builder/config/database.yml"
      cust_symlinks["config/redis.yml"] = "config/redis.yml"
      cust_symlinks["config/resque.yml"] = "config/resque.yml"
      cust_symlinks["config/newrelic.yml"] = "config/newrelic.yml"

    when :rollup
      cust_symlinks["config/database-photos.yml"] = "config/database-photos.yml"
      cust_symlinks["config/database-zza.yml"] = "config/database-zza.yml"
  end

  deploy base_dir do
    repo zz[:group_config][:app_git_url]
    revision zz[:app_deploy_tag]
    user deploy_user
    group deploy_group
    symlinks({})    # empty map, not a code block
    symlink_before_migrate cust_symlinks
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
      env = Chef::Recipe::ZZDeploy.env
      #
      # Since we do the actual restart in a separate phase, create a pre_stage link to the release
      # dir.
      #
      # In deploy-manager libraries we have monkey patched out the link_current_release_to_production method
      # so that it does nothing - this way, the current directory stays unlinked until we explicitly link it
      # in the restart phase.  This means that the switch over to the current directory will be more
      # closely synced to the actual restart of the app.  This is especially important if we have
      # a long running task such as a migration in the first phase to more closely sync all the app servers
      # switch over point.  Note: there will still be a window of time where the app servers are restarting
      # and we have already mapped current so new web resources can begin being served even though the app
      # servers are not fully switched over. The solution to this problem is some sort of asset versioning
      # so the old and new assets can coexist for some period of time.
      #
      env.sym_link(release_path, env.pre_stage_dir, env.deploy_user, env.deploy_group)

    end
    restart_command do
    end
  end

end