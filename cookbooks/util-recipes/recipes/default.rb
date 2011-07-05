run_for_all do |app_name, role, rails_env|
  base_dir = "/data/#{app_name}"
  public_dir = "#{base_dir}/current/public"
  system_dir = "#{base_dir}/shared/system"

  # put maint link in system to tell nginx we are in maint mode
  execute "maint_mode_on" do
    command "cp #{public_dir}/maintenance.html #{system_dir}/maintenance.html && chown #{deploy_user}:#{deploy_group} #{system_dir}/maintenance.html"
    action :nothing
  end

  # remove the link to take us out of maint mode
  execute "maint_mode_off" do
    command "rm -f #{system_dir}/maintenance.html"
    action :nothing
  end

end