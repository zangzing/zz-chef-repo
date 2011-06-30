puts "Restart Now........."

# look recipe code within a hook
execute "restart_fake" do
    cwd zz_release_dir
    command "echo `date` > tmp/restart.txt"
    action :run
end
