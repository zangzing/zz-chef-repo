puts "Restarting Unicorn Now........."

# call the re/start script
run "/usr/bin/zzscripts/unicorn_start.rb #{zz_rails_env} #{zz_current_dir} /var/run/zz/unicorn_#{zz_app}.pid 60"
