# TODO
# make the /var/spool/rsyslog directory
# add device to loggly with something like (use appropriate input id and figure out a way to do only once):
# curl -X POST http://zangzing:share1001photos@zangzing.loggly.com/api/inputs/4310/adddevice/
# restart rsyslog service only if we made config file changes
# Can we use attribute files to help with config???

# see config on app master

# set up loggly info based on app and env

gcfg = node[:zz][:group_config]
app_name = gcfg[:app_name]
rails_env = gcfg[:rails_env]

loggly_port = 0
loggly_id = 0
case app_name
  when 'photos'
    case rails_env
      when 'photos_production'
        loggly_port = 37253
        loggly_id = 4307

      when 'photos_staging'
        loggly_port = 19189
        loggly_id = 4308
    end

  when 'rollup'
    case rails_env
      when 'production'
        loggly_port = 25284
        loggly_id = 4309

      when 'staging'
        loggly_port = 40130
        loggly_id = 4310

    end
end

directory "/var/spool/rsyslog" do
  owner root_user
  group root_group
  mode "0755"
  action :create
end

template "/etc/rsyslog.conf" do
  source "rsyslog.conf.erb"
  owner root_user
  group root_group
  mode "0644"
  variables({
      :loggly_port => loggly_port,
      :loggly_id => loggly_id
  })
  notifies :restart, "service[rsyslog]", :immediately
  notifies :run, "execute[register_loggly]", :immediately
end

service "rsyslog" do
  supports :restart => true, :status => true
  action :nothing
end


execute "register_loggly" do
  command "curl -d input_id=#{loggly_id} -d ip=#{ec2[:local_ipv4]} http://zangzing:share1001photos@zangzing.loggly.com/api/devices/"
  action :nothing
end

