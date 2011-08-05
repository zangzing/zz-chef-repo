run_for_app(:photos => [:solo,:app,:app_master,:local]) do |app_name, role, rails_env|

  is_local_dev = role == :local

  repo_root = "/data"

  directory "#{repo_root}" do
    owner deploy_user
    group deploy_group
    mode "1755"
    action :create
  end

  bash "git clone v3homepage" do
    Chef::Log.info( "ZangZing=> setting up git for v3homepage")
    cwd "#{repo_root}"
    creates "#{repo_root}/v3homepage"
    code <<-EOH
      su -l #{deploy_user} -c 'cd #{repo_root} && git clone git@github.com:zangzing/v3homepage.git'
    EOH
  end

end