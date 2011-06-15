Chef::Log.info("ZangZing=> Updating chef directory from git ...")

root_dir = project_root_dir

bash "git-self" do
  cwd "#{root_dir}"
  user "gseitz"
  code <<-EOH
    git fetch
  EOH
end
