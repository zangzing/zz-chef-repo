puts "Preparing to terminate instance - Shutting down all work."

# don't want to monitor anymore
run "sudo monit unmonitor all"

# stop all resque workers
run "sudo /usr/bin/zzscripts/#{zz_app}_resque_stop_all"

# stop unicorn
run "sudo /usr/bin/zzscripts/unicorn_stop.rb /var/run/zz/unicorn_#{zz_app}.pid 60"

# try to stop all monit tasks
run "sudo monit stop all"

6.times do
  put "letting monit jobs stop"
  sleep 5
end



