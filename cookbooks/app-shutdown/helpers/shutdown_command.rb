Chef::Log.info "Preparing to terminate instance - Shutting down all work."

# don't want to monitor anymore
run "sudo monit unmonitor all" rescue nil

# stop all resque workers
run "sudo /usr/bin/zzscripts/#{zz_app}_resque_stop_all" rescue nil

if [:app, :app_master, :solo].include?(zz_role)
  # stop unicorn
  Chef::Log.info "Stopping unicorn"
  run "sudo /usr/bin/zzscripts/unicorn_stop.rb /var/run/zz/unicorn_#{zz_app}.pid 60" rescue nil

  # stop eventmachines
  Chef::Log.info "Stopping eventmachine"
  em_workers = zz_env.eventmachine_worker_count
  em_workers.each do |num|
    run "sudo /usr/bin/zzscripts/zz_cmds.rb stop -p /var/run/zz/em_#{zz[:app_name]}_#{num}.pid -t 5" rescue nil
  end
end

# try to stop all remaining monit tasks
run "sudo monit stop all" rescue nil

sleep_count = 10
sleep_count.times do |i|
  Chef::Log.info "letting monit jobs stop - waiting #{i+1} out of #{sleep_count}"
  sleep 6
end



