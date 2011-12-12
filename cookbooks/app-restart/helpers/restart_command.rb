Chef::Log.info "Restarting EventMachine Now....."
emworkers = zz_env.eventmachine_worker_count
#
# We start them directly rather than via monit because the start mechanism
# will gracefully kill the previous instance - so graceful in fact, it will
# remain running until it finishes any pending work.  This is important because
# it may have a long running download such as a zipfile in progress.  The only
# time we do a hard kill of the previous instance is if it will not give up
# its network address.  In this case it is assumed to be stuck and we terminate it.
#
emworkers.times do |num|
  em_dir = "#{zz_release_dir}/eventmachine"
  run("sudo RAILS_ENV=#{zz_rails_env} ./emstart.rb start -n #{num} -g #{zz_deploy_group} -u #{zz_deploy_user} &", em_dir)
end
# we are ready to have monit monitor the state again
run "sudo monit monitor -g em_#{zz_app}"



Chef::Log.info "Restarting Unicorn Now........."

# call the re/start script
run "/usr/bin/zzscripts/unicorn_start.rb #{zz_rails_env} #{zz_current_dir} /var/run/zz/unicorn_#{zz_app}.pid 180"
# we are ready to have monit monitor the state again
run "sudo monit monitor -g unicorn_#{zz_app}"

