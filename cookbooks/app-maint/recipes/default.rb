run_for_app(:photos => [:solo,:app,:app_master],
            :rollup => [:solo,:app,:app_master]) do |app_name, role, rails_env|


  maint = zz[:deploy_maint]
  base_dir = "/data/#{app_name}"
  public_dir = "#{base_dir}/current/public"
  system_dir = "#{base_dir}/shared/system"

  # we have a symbolic link from the apps public/system dir to the shared system dir
  # so need to move the file into the shared dir to turn on maint and remove to turn off
  if maint
    # put maint link in system to tell nginx we are in maint mode
    puts "copy to: #{system_dir}/maintenance.html from #{public_dir}/maintenance.html"
    execute "copy_maint" do
      command "cp #{public_dir}/maintenance.html #{system_dir}/maintenance.html"
    end
  else
    # remove the link to take us out of maint mode
    file "#{system_dir}/maintenance.html" do
      action :delete
    end
  end

end