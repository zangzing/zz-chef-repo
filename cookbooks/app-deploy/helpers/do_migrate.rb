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
public_dir = "#{zz_current_dir}/public"
system_dir = "#{zz_shared_dir}/system"

if downtime
  # put maint link in system to tell nginx we are in maint mode
  puts "Maintenance mode on until restart."
  run "cp #{public_dir}/maintenance.html #{system_dir}/maintenance.html && chown #{zz_deploy_user}:#{zz_deploy_group} #{system_dir}/maintenance.html"

  # now stop unicorn
  if [:app_master, :app, :solo].include?(zz_role)
    run "/usr/bin/zzscripts/unicorn_stop.rb /var/run/zz/unicorn_#{zz_app}.pid 60"
  end
end

if [:app_master, :solo].include?(zz_role) && do_migrate
  puts "Migrating with: #{migrate_command}"
  run "bundle exec #{migrate_command}"
end
