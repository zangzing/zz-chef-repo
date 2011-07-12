run_for_app(:photos => [:solo,:util,:app,:app_master,:db],
            :rollup => [:solo,:util,:app,:app_master,:db]) do |app_name, role, rails_env|
  # set up loggly info based on app and env

  username = zz[:group_config][:database_username]
  password = zz[:group_config][:database_password]
  host = zz[:group_config][:database_host]
  schema = zz[:group_config][:database_schema]

  template "#{ZZDeploy.env.shared_config_dir}/database.yml" do
    source "database.yml.erb"
    owner deploy_user
    group deploy_group
    mode 0644
    variables({
      :rails_env => rails_env,
      :schema => schema,
      :username => username,
      :password => password,
      :host => host,
      })
  end

  # now extra database configuration based on app
  if app_name == :photos
    # photos has a cache database, it is defined in the custom_config section of the node
    username = zz[:custom_config][:cachedb_username]
    password = zz[:custom_config][:cachedb_password]
    host = zz[:custom_config][:cachedb_host]
    schema = zz[:custom_config][:cachedb_schema]
    template "#{ZZDeploy.env.shared_config_dir}/database-cache.yml" do
      source "database.yml.erb"
      owner deploy_user
      group deploy_group
      mode 0644
      variables({
        :rails_env => rails_env,
        :schema => schema,
        :username => username,
        :password => password,
        :host => host,
        })
    end
  end

  if app_name == :rollup
    # rollup has definitions for read only production and zza
    username = zz[:custom_config][:photosdb_username]
    password = zz[:custom_config][:photosdb_password]
    host = zz[:custom_config][:photosdb_host]
    schema = zz[:custom_config][:photosdb_schema]
    template "#{ZZDeploy.env.shared_config_dir}/database-photos.yml" do
      source "database.yml.erb"
      owner deploy_user
      group deploy_group
      mode 0644
      variables({
        :rails_env => rails_env,
        :schema => schema,
        :username => username,
        :password => password,
        :host => host,
        })
    end

    # read only zza
    username = zz[:custom_config][:zzadb_username]
    password = zz[:custom_config][:zzadb_password]
    host = zz[:custom_config][:zzadb_host]
    schema = zz[:custom_config][:zzadb_schema]
    template "#{ZZDeploy.env.shared_config_dir}/database-zza.yml" do
      source "database.yml.erb"
      owner deploy_user
      group deploy_group
      mode 0644
      variables({
        :rails_env => rails_env,
        :schema => schema,
        :username => username,
        :password => password,
        :host => host,
        })
    end

  end

end

