puts "Preparing to terminate instance - Shutting down all work."

# don't want to monitor anymore
run "sudo monit unmonitor all"

# stop all resque workers
run "sudo /usr/bin/zzscripts/#{zz_app}_resque_stop_all"

# stop unicorn
run "sudo /usr/bin/zzscripts/unicorn_stop.rb /var/run/zz/unicorn_#{zz_app}.pid 60"

# stop eventmachines
em_workers = zz_env.eventmachine_worker_count
em_workers.each do |num|
  run "sudo /usr/bin/zzscripts/zz_cmds.rb stop -p /var/run/zz/em_#{zz[:app_name]}_#{num}.pid -t 5"
end

# try to stop all remaining monit tasks
run "sudo monit stop all"

6.times do
  put "letting monit jobs stop"
  sleep 5
end



