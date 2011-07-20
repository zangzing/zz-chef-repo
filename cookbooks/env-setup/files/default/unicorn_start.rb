#!/usr/bin/env ruby

# we either restart unicorn if it is running with USR2 or if not running
# we start it

def do_cmd(cmd)
  puts cmd
  Kernel.system(cmd)
end

# expects
# unicorn_start.rb RAILS_ENV APP_DIR PID TIMEOUT
#
# sample:
# ./unicorn_start.rb development /Users/gseitz/Develop/ZZ/rollup /var/run/zangzing/unicorn_rollup.pid 30
if ARGV.length != 4
  abort("usage: unicorn_start.rb RAILS_ENV APP_DIR PID TIMEOUT")
end

rails_env = ARGV[0]
app_dir = ARGV[1]
pid_file = ARGV[2]
old_pid_file = "#{pid_file}.oldbin"
timeout = ARGV[3].to_i


pid = File.read(pid_file).to_i rescue 0
running = false

if pid != 0
  do_cmd "ps -fp #{pid}"
  running = $?.exitstatus == 0
end

begin
  if running
    # restart gracefully by sending USR2 signal
    do_cmd "kill -s USR2 #{pid}"
    sleep 2
    print "Signaling Unicorn(#{pid}) an hot restart"

    # now wait for the old pid file to go away indicating the restart phase
    # is complete.  If we end up with the same pid the server failed to restart
    max_wait_till = Time.now.to_f + timeout
    while true
      old_pid = File.read(old_pid_file).to_i rescue 0
      #puts old_pid
      if old_pid == 0
        break # we are done, move on to see if server pid changed
      else
        print '.'
        STDOUT.flush
        #puts "Old app still running: #{old_pid}"
      end
      sleep 1
      raise "Timeout while waiting for new app to start." if Time.now.to_f >= max_wait_till
    end
    # ok, lets see if the pid changed indicating a successful restart
    new_pid = File.read(pid_file).to_i rescue 0
    if new_pid == 0
      raise "The app did not start and the old app does not appear to be running anymore."
    end
    puts "new: #{new_pid}, orig: #{pid}"
    if new_pid == pid
      raise "The app did not successfully an hot restart - your old app should still be running."
    else
      puts "Your app has been successfully an hot restarted."
    end
  else
    # start from scratch
    do_cmd "cd #{app_dir} && bundle exec unicorn -D -E #{rails_env} -c #{app_dir}/config/unicorn.rb #{app_dir}/config.ru"
    raise "The app failed to start." if $?.exitstatus != 0
    puts "Your app has been successfully an cold restarted."
  end
rescue Exception => ex
  puts "The application did not start, tail from unicorn.stderr.log:"
  do_cmd "tail -n 40 #{app_dir}/log/unicorn.stderr.log"
  msg = ex.message
  puts
  puts
  abort msg
end

