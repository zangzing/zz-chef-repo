puts "-----TEST_BEFORE_MIGRATE------"
puts zz[:app_name]
puts zz_base_dir
puts zz_shared_dir
puts zz_current_dir
puts zz_release_dir
puts "-----TEST_BEFORE_MIGRATE------"

cmd = "ls -al #{zz_release_dir}"
puts cmd
`#{cmd}`
cmd = "su #{zz_deploy_user} -c 'cd #{zz_release_dir} && bundle install --gemfile=#{zz_release_dir}/Gemfile'"
puts cmd
puts `#{cmd}`

#
## install the bundle
#execute "bundle_install" do
#  cwd zz_release_dir
#  user deploy_user
#  group deploy_group
#  command "cd #{zz_release_dir} && bundle install && pwd"
#  action :run
#end
