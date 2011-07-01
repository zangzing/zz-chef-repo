puts "-----TEST_BEFORE_MIGRATE------"
puts zz[:app_name]
puts zz_base_dir
puts zz_shared_dir
puts zz_current_dir
puts zz_release_dir
puts "-----TEST_BEFORE_MIGRATE------"


# install the bundle
execute "bundle_install" do
  user deploy_user
  group deploy_group
  command "bundle install"
  action :run
end
