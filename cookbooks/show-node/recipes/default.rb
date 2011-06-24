j = JSON.pretty_generate(node[:zz].to_hash)

template "/var/chef/zzdna.json" do
  source "pretty.json.erb"
  owner deploy_user
  group deploy_user
  mode "0644"
  variables({
    :pretty_json => j
  })
end
