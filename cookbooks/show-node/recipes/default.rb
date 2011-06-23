j = JSON.pretty_generate(node[:zz].to_hash)

template "/tmp/node.json" do
  source "pretty.json.erb"
  owner deploy_user
  group deploy_user
  mode "0640"
  variables({
    :pretty_json => j
  })
end
