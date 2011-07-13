puts "Restart Now........."

cmd = "echo `date` > #{zz_env.release_dir}/tmp/restart-2.txt"
puts cmd
`#{cmd}`

# look recipe code within a hook
execute "restart_fake" do
    cwd zz_env.release_dir
    command "echo `date` > tmp/restart.txt"
    action :run
end
