run_for_app(:photos => [:solo,:util,:app,:app_master]) do |app_name, role, rails_env|

  # divide up the license count between staging and production
  # combined should equal number of new relic licenses we have
  licenses = 0
  case rails_env
    when :photos_production
      licenses = 0
    when :photos_staging
      # only gets the licenses if for the photos_staging group as well (i.e. don't use them on photos_hacktest)
      licenses = 0 if zz[:deploy_group_name] == 'photos_staging'
  end

  # compute the proper license distribution and hold
  # state internally.  Use the use_license? method to
  # see if we are a match
  app_config = zz[:app_config]
  apps = app_config[:app_servers]
  utils = app_config[:util_servers]
  la = LicenseAllocator.new(licenses, apps, utils)
  # see if we are amongst the chosen few...
  monitor = la.use_license?(zz[:local_hostname])

  template "#{zz_env.shared_config_dir}/newrelic.yml" do
    source "newrelic.yml.erb"
    owner deploy_user
    group deploy_group
    mode 0644
    variables({
      :monitor => monitor
      })
  end
end