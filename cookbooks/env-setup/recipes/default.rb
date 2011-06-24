# set up the ruby env
#cookbook_file "/home/ec2-user/test.jpg" do
#  source "test.jpg"
#  mode 0755
#  owner deploy_user
#  group deploy_group
#end

template "/etc/profile.d/rubyenv.sh" do
  source "rubyenv.sh.erb"
  owner deploy_user
  group deploy_user
  mode "0644"
  variables({
    :rails_env => node[:zz][:group_config][:rails_env]
  })
end
