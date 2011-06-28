run_for_app(:photos => [:solo,:util,:app,:app_master,:db],
            :rollup => [:solo,:util,:app,:app_master,:db]) do |app_name, role, rails_env|

  package "monit" do
    action :install
  end

#  template "/etc/ssmtp/ssmtp.conf" do
#    source "ssmtp.conf.erb"
#    owner deploy_user
#    group deploy_group
#    mode "0644"
#  end

end