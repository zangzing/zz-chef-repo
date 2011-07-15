class Chef
  module Mixin
    module ZZUtils


      # load and run external ruby code within our current context
      # returns true if was able to load false otherwise
      def run_external_code(dir, file, required)
        full_path = "#{dir}/#{file}"
        ruby_code = File.open(full_path, 'r') {|f| f.read } rescue ruby_code = nil
        if !ruby_code.nil?
          begin
            Chef::Log.info("ZangZing=> Running application hook #{file}")
            instance_eval(ruby_code, full_path)
          rescue Exception => ex
            Chef::Log.error("ZangZing=> Exception while running application hook #{file}")
            Chef::Log.error(ex.message)
            raise ex
          end
          return true
        else
          raise "Required hook code for #{full_path} was not found." if required
          return false
        end
      end

    end
  end
end

class Chef::Provider
  include Chef::Mixin::ZZUtils
end

class Chef::Recipe
  include Chef::Mixin::ZZUtils
end

class Chef::Recipe::ZZDeployEnvironment
  attr_accessor :release_dir

  def initialize(node, amazon)
    @node = node
    @amazon = amazon
    zz = node[:zz]

    # move ec2 data under zz
    ec2 = node[:ec2]
    if !ec2.nil?
      ec2 = ec2.to_hash unless ec2.nil?
      zz[:ec2] = ec2
    end

    instances = self.amazon_instances

    act_as = zz[:act_as]  # for testing, pretend to be this id
    if act_as.nil? == false
      instance_id = act_as
      # look up info about this instance
      instance = instances[instance_id.to_sym]
      self.this_amazon_instance = instance
      local_hostname = instance[:local_hostname]
      public_hostname = instance[:public_hostname]
      set_local_accounts  # since we are only acting as remote, use local account names
    end

    # determine our role
    if is_local_dev?
      if act_as.nil?
        instance_id = "local"
        local_hostname = "localhost"
        public_hostname = "localhost"
        instances = make_local_instances
        set_local_accounts
      end
    else
      # find our instance id and set it
      if act_as.nil?
        set_remote_accounts
        ec2 = zz[:ec2]
        instance_id = ec2[:instance_id]
        instance = instances[instance_id.to_sym]
        self.this_amazon_instance = instance
        local_hostname = ec2[:local_hostname]
        public_hostname = ec2[:public_hostname]
      end
      group_name = find_deploy_group_name(instance_id)
      node[:zz][:deploy_group_name] = group_name.to_s
      grp = find_deploy_group(group_name)
      node[:zz][:recipes_deploy_tag] = grp.recipes_deploy_tag
      node[:zz][:app_deploy_tag] = grp.app_deploy_tag
      node[:zz][:group_config] = grp.config
      node[:zz][:app_name] = node[:zz][:group_config][:app_name]
      instances = make_ec2_instances(group_name)
    end

    node[:zz][:instance_id] = instance_id
    node[:zz][:local_hostname] = local_hostname
    node[:zz][:public_hostname] = public_hostname
    node[:zz][:instances] = instances

    instance = zz[:instances][instance_id]
    raise "Could not find our instance in config, our instance id is #{instance_id}" if instance.nil?
    node[:zz][:deploy_role] = instance[:role]

    # now see if we have any custom json data to associate with the node
    cust_file_path = "#{project_root_dir}/cookbooks/deploy-manager/custom/#{node[:zz][:app_name]}_#{node[:zz][:group_config][:rails_env]}.json"
    json = nil
    begin
      json = File.open(cust_file_path, 'r') {|f| f.read }
    rescue Exception => ex
      # just ignore if file not found
    end
    if !json.nil?
      # if we got json data back then parse, in this case we want to know if it fails
      custom = JSON.parse(json)
      node[:zz][:custom_config] = custom
    end
  end

  def zz
    @zz ||= @node[:zz]
  end

  def ec2
    @ec2 ||= zz[:ec2]
  end

  def node
    @node
  end

  def amazon
    @amazon
  end

  def amazon_instances
    @amazon_instances ||= amazon.find_named_instances(nil,nil)
  end

  def this_amazon_instance
    @this_amazon_instance
  end

  def this_amazon_instance=(instance)
    @this_amazon_instance = instance
  end

  def set_local_accounts
    node[:zz][:deploy_user] = current_user
    node[:zz][:deploy_group] = "ec2-user" # yes, this is our local group
    node[:zz][:root_user] = "root"
    node[:zz][:root_group] = "admin"
  end

  def set_remote_accounts
    node[:zz][:deploy_user] = "ec2-user"
    node[:zz][:deploy_group] = "ec2-user"
    node[:zz][:root_user] = "root"
    node[:zz][:root_group] = "root"
  end

  def make_local_instances
    {
        'local' =>  {
            :public_hostname => "localhost",
            :local_hostname => "localhost",
            :role => 'local'
        }
    }
  end

  # fetch and make the instances
  # also discovers the deploy group
  def make_ec2_instances(group_name)
    instances = amazon.find_named_instances(group_name,nil)
  end

  # discover our deploy group name based on our id
  def find_deploy_group_name(instance_id)
    tags = amazon.flat_tags_for_resource(instance_id)
    group_name = tags[:group]
    raise "Could not find deploy group for this instance #{instance_id}" if group_name.nil?
    group_name
  end

  # get our deploy group
  def find_deploy_group(deploy_group_name)
    deploy_group = amazon.find_deploy_group(deploy_group_name)
  end


  def this_instance_id
    return zz[:instance_id]
  end

  # get our own private host name
  def this_local_hostname
    return zz[:local_hostname]
  end

  # get our own private host name
  def this_public_hostname
    return zz[:public_hostname]
  end

  def is_local_dev?
    return zz[:dev_machine]
  end

  def deploy_app?
    return zz[:deploy_what] == 'app'
  end

  def deploy_app_restart?
    return zz[:deploy_what] == 'app_restart'
  end

  def deploy_maint?
    return zz[:deploy_what] == 'app_maint'
  end

  def deploy_config?
    return zz[:deploy_what] == 'config'
  end

  def deploy_shutdown?
    return zz[:deploy_what] == 'shutdown'
  end

  def deploy_role
    return zz[:deploy_role]
  end

  def current_user
    node[:current_user]
#    return @current_user if @current_user != nil
#
#    # we use who instead of whoami because whoami will
#    # return root if you are running as sudo whereas who -m
#    # returns the actual user that started the run
#    me = `who -m`
#    parts = me.split(' ')
#    @current_user = parts[0]
  end

  def this_host_name
    zz[:local_hostname]
  end

  def deploy_user
    zz[:deploy_user]
  end

  def deploy_group
    zz[:deploy_group]
  end

  def root_group
    zz[:root_group]
  end

  def root_user
    zz[:root_user]
  end

  # take the current directory of this file and return a fully
  # qualified path based on the relative path passed in
  def relative_path rel_path
    full_path(File.dirname(__FILE__) + "/" + rel_path)
  end

  # give the root of this project
  def project_root_dir
    dir = relative_path('../../..')
  end

  def base_dir
    "/data/#{zz[:app_name]}"
  end

  def current_dir
    "/data/#{zz[:app_name]}/current"
  end

  def current_config_dir
    "#{current_dir}/config"
  end

  def shared_dir
    "/data/#{zz[:app_name]}/shared"
  end

  def shared_config_dir
    "#{shared_dir}/config"
  end

  # generate a fully qualified path with
  # relative paths removed since Chef doesn't
  # seem to like relative paths in some cases
  def full_path path
    File.expand_path('.', path)
  end


  def log_info
#    Chef::Log.info("ZangZing=> should_host_redis? is " + should_host_redis?.to_s)
#    Chef::Log.info("ZangZing=> redis_host_name is " + redis_host_name)
#    Chef::Log.info("ZangZing=> this_instance_id is " + this_instance_id)
#    Chef::Log.info("ZangZing=> this_host_name is " + this_host_name)
#    Chef::Log.info("ZangZing=> should_host_resque_cpu? is " + should_host_resque_cpu?.to_s)
#    Chef::Log.info("ZangZing=> resque_cpu_host_names is " + resque_cpu_host_names.to_s)
  end

  # record the sym link that current uses
  # in case we fail during the deploy
  def deploy_started app_base_dir

  end
end

class Chef::Recipe::ZZDeploy
  def self.init(node, amazon)
    @@zz_environ ||= Chef::Recipe::ZZDeployEnvironment.new(node, amazon)
  end

  def self.env
    @@zz_environ
  end
end


class Chef
  class Recipe
    def zz_env
      Chef::Recipe::ZZDeploy.env
    end

    # take the current directory of this file and return a fully
    # qualified path based on the relative path passed in
    def relative_path rel_path
      Chef::Recipe::ZZDeploy.env.relative_path(rel_path)
    end

    # give the root of this project
    def project_root_dir
      Chef::Recipe::ZZDeploy.env.project_root_dir
    end

    # generate a fully qualified path with
    # relative paths removed since Chef doesn't
    # seem to like relative paths in some cases
    def full_path path
      Chef::Recipe::ZZDeploy.env.full_path(path)
    end

    def zz
      Chef::Recipe::ZZDeploy.env.zz
    end

    def ec2
      Chef::Recipe::ZZDeploy.env.ec2
    end

    def is_local_dev?
      Chef::Recipe::ZZDeploy.env.is_local_dev?
    end

    def deploy_app?
      Chef::Recipe::ZZDeploy.env.deploy_app?
    end

    def deploy_app_restart?
      Chef::Recipe::ZZDeploy.env.deploy_app_restart?
    end

    def deploy_maint?
      Chef::Recipe::ZZDeploy.env.deploy_maint?
    end

    def deploy_config?
      Chef::Recipe::ZZDeploy.env.deploy_config?
    end

    def deploy_shutdown?
      Chef::Recipe::ZZDeploy.env.deploy_shutdown?
    end

    def deploy_role
      Chef::Recipe::ZZDeploy.env.deploy_role
    end

    def root_group
      Chef::Recipe::ZZDeploy.env.root_group
    end

    def root_user
      Chef::Recipe::ZZDeploy.env.root_user
    end

    def deploy_user
      Chef::Recipe::ZZDeploy.env.deploy_user
    end

    def deploy_group
      Chef::Recipe::ZZDeploy.env.deploy_group
    end

    def current_user
      Chef::Recipe::ZZDeploy.env.current_user
    end

  end
end

class Chef
  class Resource
    def zz_env
      Chef::Recipe::ZZDeploy.env
    end

    def zz
      Chef::Recipe::ZZDeploy.env.zz
    end

    def ec2
      Chef::Recipe::ZZDeploy.env.ec2
    end

    def is_local_dev?
      Chef::Recipe::ZZDeploy.env.is_local_dev?
    end

    def root_group
      Chef::Recipe::ZZDeploy.env.root_group
    end

    def root_user
      Chef::Recipe::ZZDeploy.env.root_user
    end

    def deploy_user
      Chef::Recipe::ZZDeploy.env.deploy_user
    end

    def deploy_group
      Chef::Recipe::ZZDeploy.env.deploy_group
    end

  end
end

class Chef::Recipe::NotifyHelper
  # remote_only should be set to false
  # if you want local to be notified
  def initialize(remote_only = true)
    @notify_count = 0
    @remote_only = remote_only
  end

  def current_count
    @notify_count
  end

  # indicates if you should do action
  # will return false if we've already done it
  # once or the local filter is set
  # because we always get called the first time
  # with action nothing, we treat the second
  # call as the one that should do the action
  # the resource being notified must always
  # sets its action to nothing for this to work
  def should_run?
    @notify_count += 1
    return false if (@remote_only && Chef::Recipe::ZZDeploy.env.is_local_dev?)
    return @notify_count == 2
  end
end

