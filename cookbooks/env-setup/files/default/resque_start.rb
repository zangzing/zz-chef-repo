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

# if already running do nothing, use resque_stop to stop
pid = File.read(pid_file).strip.to_i rescue 0
running = false
if pid != 0
  do_cmd "ps -fp #{pid}"
  running = $?.exitstatus == 0
end
if running == false
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
end
