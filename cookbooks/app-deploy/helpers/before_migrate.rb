puts "-----TEST_BEFORE_MIGRATE------"
puts zz[:app_name]
puts zz_base_dir
puts zz_shared_dir
puts zz_current_dir
puts zz_release_dir
puts "-----TEST_BEFORE_MIGRATE------"

#cmd = "ls -al #{zz_release_dir}"
#puts cmd
#`#{cmd}`
#cmd = "su -l #{zz_deploy_user} -c 'cd #{zz_release_dir} && bundle install'"
#puts cmd
#puts `#{cmd}`


# install the bundle - need to use su since just calling it directly
# causes it to work out of our chef directory even though we cd to the
# proper directory.  Must be something about how it looks at the environment
#
execute "bundle_install" do
  cwd zz_release_dir
  user deploy_user
  group deploy_group
  command "su -l #{zz_deploy_user} -c 'cd #{zz_release_dir} && bundle install'"
  action :run
end
