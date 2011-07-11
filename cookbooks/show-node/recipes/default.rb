run_for_all() do |app_name, role, rails_env|

  j = JSON.pretty_generate(node[:zz].to_hash)

  if deploy_config?
    template "/var/chef/zz_config_dna.json" do
      source "pretty.json.erb"
      owner deploy_user
      group deploy_user
      mode "0644"
      variables({
        :pretty_json => j
      })
    end
  end

  if deploy_app?
    template "#{ZZDeploy.env.shared_config_dir}/zz_app_dna.json" do
      source "pretty.json.erb"
      owner deploy_user
      group deploy_user
      mode "0644"
      variables({
        :pretty_json => j
      })
    end
  end
end