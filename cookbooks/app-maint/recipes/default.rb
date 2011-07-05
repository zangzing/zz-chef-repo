run_for_app(:photos => [:solo,:app,:app_master],
            :rollup => [:solo,:app,:app_master]) do |app_name, role, rails_env|


  maint = zz[:deploy_maint]
  base_dir = "/data/#{app_name}"
  public_dir = "#{base_dir}/current/public"
  system_dir = "#{public_dir}/system"

  if maint
    # put maint link in system to tell nginx we are in maint mode
    link "#{system_dir}/maintenance.html" do
      to "#{public_dir}/maintenance.html"
    end
  else
    # remove the link to take us out of maint mode
    link "#{system_dir}/maintenance.html" do
      action :delete
    end
  end

end