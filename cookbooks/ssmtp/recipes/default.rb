run_for_app(:photos => [:solo,:util,:app,:app_master,:db],
            :rollup => [:solo,:util,:app,:app_master,:db]) do |app_name, role, rails_env|

  service "sendmail" do
    action [:stop, :disable]
  end

  package "ssmtp" do
    action :install
  end

  link "/usr/sbin/sendmail" do
    to "/usr/sbin/ssmtp"
  end

  template "/etc/ssmtp/ssmtp.conf" do
    source "ssmtp.conf.erb"
    owner deploy_user
    group deploy_group
    mode "0640"
  end

end