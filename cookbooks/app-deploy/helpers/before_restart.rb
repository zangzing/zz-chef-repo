# we don't really restart here since we have a separate recipe to do that
# coordinated by the deploy command line tool
#
# use this however as an opportunity to go into maint mode if
# this is a downtime deploy
#
# we also do the migration here if it is requested since we want
# to wait until we are marked as down if downtime was specified
# before migrating.  Therefore, we do not use the deploy resource
# migration command directly.
#
downtime = zz[:deploy_downtime]
migrate_command = zz[:deploy_migrate_command]
do_migrate = migrate_command.empty? == false

if downtime
  log "Downtime deploy" do
    notifies :run, "execute[maint_mode_on]", :immediately
  end
end

if [:app_master, :solo].include?(role) && do_migrate
  execute "migrate" do
    command "su -l #{zz_deploy_user} -c 'cd #{zz_release_dir} && bundle exec #{migrate_command}'"
#    command "bundle exec #{migrate_command}"
    cwd zz_release_dir
  end
end
