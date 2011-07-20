#!/usr/bin/env ruby

def do_cmd(cmd)
  puts cmd
  Kernel.system(cmd)
end

# expects
# resque_stop.rb PID_FILE TIMEOUT
#
# Stop the resque job specified by the PID file, if we hit
# the timeout, we will forcibly kill the task
#
# sample:
# ./resque_stop.rb /var/run/zz/resque/worker.pid 30
if ARGV.length != 2
  abort("usage: resque_stop.rb PID_FILE TIMEOUT")
end

pid_file = ARGV[0]
timeout = ARGV[1].to_i

# make sure nothing running under existing pid, if so try gracefully first then forcefully
pid = File.read(pid_file).to_i rescue 0
running = false
if pid != 0
  do_cmd "ps -fp #{pid}"
  running = $?.exitstatus == 0
end
if running
  max_wait_till = Time.now.to_f + timeout
  while running do
    # try to shut down gracefully first we do this repeatedly since it may not yet be listing to signals
    # doesn't hurt to send multiple times
    do_cmd "kill -s QUIT #{pid}"
    break if Time.now.to_f >= max_wait_till
    sleep 1
    do_cmd "ps -fp #{pid}"
    running = $?.exitstatus == 0
  end

  # ok, we tried gracefully if it's still running finish the job
  do_cmd "kill -s SIGKILL #{pid}" if running
end

# always clean up the pid file
do_cmd "rm -f #{pid_file}"

