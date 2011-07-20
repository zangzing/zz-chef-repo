#!/usr/bin/env ruby

# shut down unicorn master and workers

def do_cmd(cmd)
  puts cmd
  Kernel.system(cmd)
end

# usage
# unicorn_stop.rb PID
#
# sample:
# ./unicorn_stop.rb /var/run/zangzing/unicorn_rollup.pid TIMEOUT
if ARGV.length != 2
  abort("usage: unicorn_start.rb PID TIMEOUT")
end

pid_file = ARGV[0]
timeout = ARGV[1].to_i

# make sure nothing running under existing pid, if so forcibly kill
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

  # ok, we tried gracefully so if it's still running finish the job
  if running
    # one last semi graceful attempt
    do_cmd "kill -s TERM #{pid}"
    sleep 3
    # and finally kill it for good
    do_cmd "kill -s SIGKILL #{pid}"
  end
end

# always clean up the pid file
do_cmd "rm -f #{pid_file}"
