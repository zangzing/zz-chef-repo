# this is helper code just to expose some handy zz_ vars to the custom deploy hooks
zz = hv[:zz]
zz_base_dir = hv[:base_dir]
zz_shared_dir = hv[:shared_dir]
zz_current_dir = hv[:current_dir]
zz_release_dir = hv[:release_dir]
zz_deploy_user = hv[:deploy_user]
zz_deploy_group = hv[:deploy_group]
zz_app = zz[:app_name].to_sym
zz_role = zz[:deploy_role].to_sym
zz_rails_env = zz[:group_config][:rails_env].to_sym
Chef::Recipe::ZZDeploy.env.release_dir = zz_release_dir

def run(cmd)
  env = Chef::Recipe::ZZDeploy.env
  zz = env.zz
  user = env.deploy_user
  dir = env.release_dir
  e = execute cmd do
    cwd zz_release_dir
    command "su -l #{user} -c 'cd #{dir} && #{cmd}'"
    action :nothing
  end
  e.run_action(:run)  # execute right now
end