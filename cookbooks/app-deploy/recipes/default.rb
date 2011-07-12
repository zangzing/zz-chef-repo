run_for_app(:photos => [:solo,:util,:app,:app_master],
            :rollup => [:solo,:util,:app,:app_master]) do |app_name, role, rails_env|

  # set up any items we want to pass into the hooks via the for_hook hash
  base_dir = "/data/#{app_name}"
  for_hook = ZZDeploy.env.prep_hook_data(app_name, nil)
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
      hv = for_hook
      hv[:release_dir] = release_path

      # prep vars we want to pass
      ruby_code = File.open("#{chef_base}/cookbooks/app-deploy/helpers/prep_hook_vars.rb", 'r') {|f| f.read }
      instance_eval(ruby_code)

      # now our own hook code
      ruby_code = File.open("#{chef_base}/cookbooks/app-deploy/helpers/prepare_config.rb", 'r') {|f| f.read }
      instance_eval(ruby_code)

      # now our own hook code
      ruby_code = File.open("#{chef_base}/cookbooks/app-deploy/helpers/do_migrate.rb", 'r') {|f| f.read }
      instance_eval(ruby_code)

      # and finally the app code if it has a hook in the deploy dir
      ruby_code = File.open("#{release_path}/deploy/prepare_config.rb", 'r') {|f| f.read } rescue ruby_code = nil
      if !ruby_code.nil?
        begin
          Chef::Log.info("ZangZing=> Running application hook prepare_config.rb")
          instance_eval(ruby_code)
        rescue Exception => ex
          Chef::Log.info("ZangZing=> Exception while running application hook prepare_config.rb")
          Chef::Log.info(ex.message)
          raise ex
        end
      end
    end
    before_restart do
    end
    after_restart do
    end
    restart_command do
    end
  end

end