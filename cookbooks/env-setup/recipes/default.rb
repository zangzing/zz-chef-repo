# set up the ruby env
#cookbook_file "/home/ec2-user/test.jpg" do
#  source "test.jpg"
#  mode 0755
#  owner deploy_user
#  group deploy_group
#end

run_for_app(:photos => [:solo,:util,:app,:app_master,:db,:local],
            :rollup => [:solo,:util,:app,:app_master,:db,:local]) do |app_name, role, rails_env|

  # we do each part to get the right permissions at each node
  directory "/data" do
    owner deploy_user
    group deploy_group
    mode "0755"
    action :create
  end

  directory "/data/#{app_name}" do
    owner deploy_user
    group deploy_group
    mode "0755"
    action :create
  end

  directory "/data/#{app_name}/shared" do
    owner deploy_user
    group deploy_group
    mode "0755"
    action :create
  end

  directory "/data/#{app_name}/shared/config" do
    owner deploy_user
    group deploy_group
    mode "0755"
    recursive true
    action :create
  end

  if role != :local
    template "/etc/profile.d/rubyenv.sh" do
      source "rubyenv.sh.erb"
      owner deploy_user
      group deploy_user
      mode "0644"
      variables({
        :rails_env => rails_env
      })
    end
  end

end
