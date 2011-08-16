require "rubygems"
require "bundler/setup"
require 'right_aws'
require 'zzsharedlib'
require 'logger'

# the amazon keys are expected to be in /var/chef/amazon.json
json = File.open("/var/chef/amazon.json", 'r') {|f| f.read }
ak = JSON.parse(json)
opts = ZZSharedLib::Options.global_options
opts[:access_key] = ak["aws_access_key_id"]
opts[:secret_key] = ak["aws_secret_access_key"]
opts[:log_level] = Logger::Severity::DEBUG

amazon = ZZSharedLib::Amazon.new

# inject our custom code into recipes
ZZDeploy.init(node, amazon)

# now the custom data based on the app type
app_name = node[:zz][:app_name]
case app_name
  when "photos"
    PhotosConfig.init(node)

  when "rollup"
    RollupConfig.init(node)
end

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


# common recipes for all, all have
# deferred execution states
require_recipe "util-recipes"

if deploy_config?
  require_recipe "show-node"
  require_recipe "env-setup"
  require_recipe "rsyslog"
  require_recipe "monit"
  require_recipe "nginx"
  require_recipe "memcached"
  require_recipe "database"
  require_recipe "ssmtp"
  require_recipe "redis"
  require_recipe "resque"
  require_recipe "v3homepage-prep"
  require_recipe "exiftool"
  require_recipe "imagemagick"
  require_recipe "unicorn"
end

# see if we should go ahead and deploy the app
if deploy_app?
  require_recipe "show-node"
  require_recipe "app-deploy"
  require_recipe "new-relic"
end

# see if we should go ahead and restart the app
if deploy_app_restart?
  require_recipe "app-restart"
end

if deploy_maint?
  require_recipe "app-maint"
end

if deploy_shutdown?
  require_recipe "app-shutdown"
  require_recipe "rsyslog"
end