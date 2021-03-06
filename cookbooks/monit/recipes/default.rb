run_for_app(:photos => [:solo,:util,:app,:app_master,:db,:db_slave],
            :rollup => [:solo,:util,:app,:app_master,:db,:db_slave]) do |app_name, role, rails_env|

  package "monit" do
    action :install
  end

  template "/etc/monit.conf" do
    source "monit.conf.erb"
    owner root_user
    group root_group
    mode "0600"
    notifies :restart, "service[monit]", :immediately
    notifies :enable, "service[monit]", :immediately
  end

  service "monit" do
    supports :restart => true, :status => true
    action :nothing
  end

  execute "monit-reload-config" do
      command "monit reload"
      action :nothing
  end

end