run_for_app(:photos => [:solo,:util,:app,:app_master,:db,:db_slave],
            :rollup => [:solo,:util,:app,:app_master,:db,:db_slave]) do |app_name, role, rails_env|
  # set up loggly info based on app and env

  loggly_port = 0
  loggly_id = 0
  case app_name
    when :photos
      case rails_env
        when :photos_production
          loggly_port = 37253
          loggly_id = 4307

        when :photos_staging
          loggly_port = 19189
          loggly_id = 4308
      end

    when :rollup
      case rails_env
        when :production
          loggly_port = 25284
          loggly_id = 4309

        when :staging
          loggly_port = 40130
          loggly_id = 4310

      end
  end

  if deploy_shutdown?
    begin
      # remove ourselves from loggly
      json = `curl -u zangzing:share1001photos http://zangzing.loggly.com/api/devices/`
      devices = JSON.parse(json)
      device_ids = []
      devices.each do |device|
        device_ip = device["ip"]
        if device_ip == ec2[:public_ipv4]
          # found a match
          device_ids << device["id"]
        end
      end

      # now tell loggly to remove from the list
      device_ids.each do |device_id|
         `curl -X DELETE http://zangzing:share1001photos@zangzing.loggly.com/api/devices/#{device_id}`
      end
    rescue Exception => ex
      # ignore
    end
  else
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
      notifies :run, "execute[loggly_register]", :immediately
      notifies :run, "execute[loggly_ready_msg]", :immediately
    end

    service "rsyslog" do
      supports :restart => true, :status => true
      action :nothing
    end


    execute "loggly_register" do
      command "curl -d input_id=#{loggly_id} -d ip=#{ec2[:public_ipv4]} http://zangzing:share1001photos@zangzing.loggly.com/api/devices/"
      action :nothing
    end

    execute "loggly_ready_msg" do
      command "logger -t chef.deploy rsyslog configured to use loggly"
      action :nothing
    end

  end

end

