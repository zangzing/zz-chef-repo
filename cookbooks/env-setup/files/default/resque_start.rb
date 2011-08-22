#!/usr/bin/env ruby

# start resque worker or scheduler

def do_cmd(cmd)
  puts cmd
  Kernel.system(cmd)
end

# expects
# resque_start.rb RAILS_ENV APP_DIR PID TYPE(work/scheduler) TIMEOUT QUEUE_FILE
#
# QUEUE is just a placeholder when running as scheduler
#
# sample:
# ./resque_start.rb development /Users/gseitz/Develop/ZZ/server /var/run/zz/resque/scheduler.pid scheduler 30 ''
# ./resque_start.rb development /Users/gseitz/Develop/ZZ/server /var/run/zz/resque/worker.pid work 30 ./resque_queue
if ARGV.length != 6
  abort("usage: resque_start.rb RAILS_ENV APP_DIR PID_FILE TYPE(work/scheduler) TIMEOUT QUEUE_FILE")
end

rails_env = ARGV[0]
app_dir = ARGV[1]
pid_file = ARGV[2]
type = ARGV[3]
timeout = ARGV[4].to_i
queue_file = ARGV[5]

valid_types = ['work', 'scheduler']
abort("Must be type work or scheduler, was #{type}") unless valid_types.include?(type)

# ok, make absolutely sure that the previous instance is dead and buried.  If we get here
# and we find somebody else in the process list with our PIDFILE we must kill it because
# it is a rogue from a previous run

# first see if we have one or more instances that use the same PIDFILE as us running
procs = `ps -eo pid,ppid,command --cols 500 | grep PIDFILE`.map
kill_pids = []
procs.each do |proc|
  if proc.match(pid_file).nil? == false
    # ok, this one matches our pidfile so add to list of parents
    kill_pids << proc.split[0]
  end
end

# now we have a list of parents so find the children, combined will give us the complete kill list
if kill_pids.empty? == false
  worker_parents = kill_pids.join(',')
  workers = `ps --no-headers --ppid #{worker_parents} -o pid`.split
  workers.each do |worker|
    kill_pids << worker
  end
end

# ok, once we get here see if we have any pids to kill and do so
if kill_pids.empty? == false
  `kill -s SIGKILL #{kill_pids.join(' ')}`
end

# should be no other copy running now due to forced kill above it there was one running
begin
  # start it
  qs = type == 'scheduler' ? '' : File.read(queue_file).strip
  base_cmd = "cd #{app_dir} && APP_ROOT=#{app_dir} RACK_ENV=#{rails_env} RAILS_ENV=#{rails_env} #{qs} PIDFILE=#{pid_file} bundle exec rake -f #{app_dir}/Rakefile resque:#{type}"
  do_cmd "cd #{app_dir} && #{base_cmd} >> #{app_dir}/log/resque.log 2>&1 &"
  raise "The resque job failed to start." if $?.exitstatus != 0
rescue Exception => ex
  msg = ex.message
  abort msg
end
