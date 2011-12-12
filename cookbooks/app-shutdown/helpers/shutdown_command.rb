Chef::Log.info "Preparing to terminate instance - Shutting down all work."


if [:app, :app_master, :solo].include?(zz_role)
  # stop unicorn
  run "sudo monit unmonitor -g unicorn_#{zz_app}" rescue nil
  Chef::Log.info "Stopping unicorn"
  run "sudo /usr/bin/zzscripts/unicorn_stop.rb /var/run/zz/unicorn_#{zz_app}.pid 60" rescue nil

  # stop eventmachines
  Chef::Log.info "Stopping eventmachine"
  run "sudo monit unmonitor -g em_#{zz_app}" rescue nil
  em_workers = zz_env.eventmachine_worker_count
  em_workers.times do |num|
    run "sudo /usr/bin/zzscripts/zz_cmds.rb stop -p /var/run/zz/em_#{zz_app}_#{num}.pid -t 5" rescue nil
  end
end

sleep_count = 10
sleep_count.times do |i|
  Chef::Log.info "Bleeding off remaining local work - waiting #{i+1} out of #{sleep_count}"
  sleep 6
end

# stop all resque workers
Chef::Log.info "Stopping resque workers"
run "sudo monit unmonitor -g resque_#{zz_app}" rescue nil
run "sudo /usr/bin/zzscripts/#{zz_app}_resque_stop_all" rescue nil

# try to stop all remaining monit tasks
run "sudo monit stop all" rescue nil




