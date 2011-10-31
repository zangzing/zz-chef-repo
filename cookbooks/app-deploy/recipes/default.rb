# patch deploy code to not create current link
# since we control that ourselves in app restart phase
class Chef
  class Provider
    class Deploy < Chef::Provider
      def link_current_release_to_production
        puts "***** LINKING NOTHING *****"
      end
    end
  end
end

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
      # since we do the actual restart in a separate phase, create a staging link to the release
      # dir and map current to the previous current
      # map release dir to pre_staged dir
      env.sym_link(release_path, env.pre_stage_dir)

      # now revert the link from current to release dir to previous one since we do that in the next phase of the
      # deploy and some machines may finish faster (i.e. if doing a migrate that machine will trail the others)
      # so we don't want to have current mapped yet - better would be to monkey patch deploy code to
      # not create the current link at all
      #env.sym_link(old_release_path, env.current_dir)

    end
    restart_command do
    end
  end

end