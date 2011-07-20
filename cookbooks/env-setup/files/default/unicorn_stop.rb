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
# ./unicorn_stop.rb /var/run/zangzing/unicorn_rollup.pid
if ARGV.length != 1
  abort("usage: unicorn_start.rb PID")
end

pid_file = ARGV[0]

pid = `cat #{pid_file}`

if !pid.empty?
  do_cmd "kill #{pid}"
end


