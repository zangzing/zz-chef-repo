puts "Restarting Unicorn Now........."

# call the re/start script
run "/usr/bin/zzscripts/unicorn_start.rb #{zz_rails_env} #{zz_current_dir} /var/run/zz/unicorn_#{zz_app}.pid 120"
# we are ready to have monit monitor the state again
run "sudo monit monitor -g unicorn_#{zz_app}"

puts "Restarting EventMachine Now....."
emworkers = zz_env.eventmachine_worker_count
#
# We start them directly rather than via monit because the start mechanism
# will gracefully kill the previous instance - so graceful in fact, it will
# remain running until it finishes any pending work.  This is important because
# it may have a long running download such as a zipfile in progress.  The only
# time we do a hard kill of the previous instance is if it will not give up
# its network address.  In this case it is assumed to be stuck and we terminate it.
#
emworkers.each do |num|
  #run "cd #{zz_current_dir} && RAILS_ENV=#{zz_rails_env} sudo #{zz_current_dir}/emstart.rb start -n #{num} -g #{zz_deploy_group} -u #{zz_deploy_user} &"
end
