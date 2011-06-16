# inject our custom code into recipes
ZZDeploy.init(node)

# see if we have the deploy group we need for local and create it if needed
# this can be done cleanly with a recipe - so change later
#todo change this
if is_local_dev?
  `sudo dseditgroup -o read ec2-user`
  if $?.exitstatus != 0
    `sudo dseditgroup -o create ec2-user`
  end
  `sudo dseditgroup -o edit -t user -a #{current_user} ec2-user`
end


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