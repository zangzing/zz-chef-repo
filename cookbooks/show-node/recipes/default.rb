j = JSON.pretty_generate(node)
m = {
    :test => 5,
    :instances => [
        :first => "first one",
        :second => "second one",
        :third => {
          :nested => 5,
          :data => "nested data"
        }
    ]
}
#j = JSON.pretty_generate(m)

template "/tmp/node.json" do
  source "pretty.json.erb"
  owner deploy_user
  group deploy_user
  mode "0640"
  variables({
    :pretty_json => j
  })
end
