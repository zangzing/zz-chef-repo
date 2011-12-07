puts "Shutting down all work."

# stop all resque workers
run "sudo /usr/bin/zzscripts/#{zz_app}_resque_stop_all"

# stop unicorn
run "sudo monit unmonitor -g unicorn_#{zz_app}"
run "/usr/bin/zzscripts/unicorn_stop.rb /var/run/zz/unicorn_#{zz_app}.pid 60"

# now stop all other monit tasks
run "sudo monit stop all"

10.times do
  sleep 3
  put "letting monit jobs stop"
end



