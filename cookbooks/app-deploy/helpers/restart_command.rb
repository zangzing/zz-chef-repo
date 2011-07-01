puts "Restart Now........."

# File.readlink("/data/photos/current")
# gives us link, we should record this before deploy
# in case we have to revert

cmd = "echo `date` > #{zz_release_dir}/tmp/restart-2.txt"
`#{cmd}`

# look recipe code within a hook
execute "restart_fake" do
    cwd zz_release_dir
    command "echo `date` > tmp/restart.txt"
    action :run
end
