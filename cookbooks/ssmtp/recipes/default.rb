package "ssmtp" do
  action :install
end

template "/etc/ssmtp/ssmtp.conf" do
  source "ssmtp.conf.erb"
  owner deploy_user
  group deploy_group
  mode "0644"
end
