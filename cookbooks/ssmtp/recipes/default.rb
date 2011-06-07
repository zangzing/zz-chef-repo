package "ssmtp" do
  action :install
end

Chef::Log.info("ZangZing=> Setting up SSMTP to send mail through SendGrid")
template "/etc/ssmtp/ssmtp.conf" do
  source "ssmtp.conf.erb"
  owner "ec2-user"
  group "ec2-user"
  mode "0640"
end

execute "do-something" do
  command "ls -al"
  action :run
end

execute "do-something2" do
  command "ls -al | grep willnotfind"
  action :run
end

