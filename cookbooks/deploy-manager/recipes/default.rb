# inject our custom code into recipes
ZZDeploy.init(node)

if deploy_config?
  if is_local_dev?

    require_recipe "show-node"

  else

    case deploy_role
      when "app", "app_master", "solo"
        require_recipe "show-node"

      when "db"

      when "util"

    end

  end
end

# see if we should go ahead and deploy the app
if deploy_app?

end