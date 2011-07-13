# this is helper code just to expose some handy zz_ vars to the custom deploy hooks

def zz_env
  Chef::Recipe::ZZDeploy.env
end

def zz
  zz_env.zz
end


def zz_base_dir
  Chef::Recipe::ZZDeploy.env.base_dir
end

def zz_shared_dir
  Chef::Recipe::ZZDeploy.env.shared_dir
end

def zz_current_dir
  Chef::Recipe::ZZDeploy.env.current_dir
end

def zz_release_dir
  Chef::Recipe::ZZDeploy.env.release_dir
end

def zz_deploy_user
  Chef::Recipe::ZZDeploy.env.deploy_user
end

def zz_deploy_group
  Chef::Recipe::ZZDeploy.env.deploy_group
end

def zz_app
  zz[:app_name].to_sym
end

def zz_role
  zz[:deploy_role].to_sym
end

def zz_rails_env
  zz[:group_config][:rails_env].to_sym
end



def run(cmd)
  env = Chef::Recipe::ZZDeploy.env
  zz = env.zz
  user = env.deploy_user
  dir = env.release_dir
  e = execute cmd do
    cwd dir
    command "su -l #{user} -c 'cd #{dir} && #{cmd}'"
    action :nothing
  end
  e.run_action(:run)  # execute right now
end