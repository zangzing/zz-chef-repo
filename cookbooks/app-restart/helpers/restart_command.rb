puts "Restart Unicorn Now........."

# call the re/start script
run "/bin/su - #{zz[:deploy_user]} -c '/data/global/bin/unicorn_start.rb #{zz_rails_env} #{zz_current_dir} /var/run/zz/unicorn_#{zz_app}.pid 60'"
