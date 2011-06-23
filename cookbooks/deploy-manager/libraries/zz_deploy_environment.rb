
class Chef::Recipe::ZZDeployEnvironment
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

    # determine our role
    if is_local_dev?
      instance_id = "local"
      local_hostname = "localhost"
      public_hostname = "localhost"
      instances = make_local_instances
    else
      # find our instance id and set it
      act_as = zz[:act_as]  # for testing, pretend to be this id
      if act_as.nil?
        ec2 = zz[:ec2]
        instance_id = ec2[:instance_id]
        local_hostname = ec2[:local_hostname]
        public_hostname = ec2[:public_hostname]
      else
        instance_id = act_as
        # look up info about this instance
        instances = amazon.find_named_instances(nil,nil)
        instance = instances[instance_id.to_sym]
        local_hostname = instance[:local_hostname]
        public_hostname = instance[:public_hostname]
        node[:zz][:dev_machine] = true
      end
      instance_id = act_as.nil? ? ec2[:instance_id] : act_as
      group_name = find_deploy_group_name(instance_id)
      node[:zz][:deploy_group_name] = group_name.to_s
      grp = find_deploy_group(group_name)
      node[:zz][:recipes_deploy_tag] = grp.recipes_deploy_tag
      node[:zz][:app_deploy_tag] = grp.app_deploy_tag
      node[:zz][:deploy_group] = grp.config
      node[:zz][:app_name] = node[:zz][:deploy_group][:app_name]
      instances = make_ec2_instances(group_name)
    end

    node[:zz][:instance_id] = instance_id
    node[:zz][:local_hostname] = local_hostname
    node[:zz][:public_hostname] = public_hostname
    node[:zz][:instances] = instances

    instance = zz[:instances][instance_id]
    raise "Could not find our instance in config - our instance id is #{instance_id}" if instance.nil?
    node[:zz][:deploy_role] = instance[:role]
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

  def make_local_instances
    {
        'local' =>  {
            :public_hostname => "localhost",
            :local_hostname => "localhost",
            :role => 'solo'
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

  def deploy_config?
    return zz[:deploy_what] == 'config'
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

  def deploy_user
    if is_local_dev?
      return current_user
    else
      return "ec2-user"
    end
  end

  def deploy_group
    if is_local_dev?
      return "ec2-user"
    else
      return "ec2-user"
    end
  end

  def root_group
    if is_local_dev?
      "admin"
    else
      "root"
    end
  end

  def root_user
    return "root"
  end


  def log_info
#    Chef::Log.info("ZangZing=> should_host_redis? is " + should_host_redis?.to_s)
#    Chef::Log.info("ZangZing=> redis_host_name is " + redis_host_name)
#    Chef::Log.info("ZangZing=> this_instance_id is " + this_instance_id)
#    Chef::Log.info("ZangZing=> this_host_name is " + this_host_name)
#    Chef::Log.info("ZangZing=> should_host_resque_cpu? is " + should_host_resque_cpu?.to_s)
#    Chef::Log.info("ZangZing=> resque_cpu_host_names is " + resque_cpu_host_names.to_s)
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
    # take the current directory of this file and return a fully
    # qualified path based on the relative path passed in
    def relative_path rel_path
      full_path(File.dirname(__FILE__) + "/" + rel_path)
    end

    # give the root of this project
    def project_root_dir
      dir = relative_path('../../..')
    end

    # generate a fully qualified path with
    # relative paths removed since Chef doesn't
    # seem to like relative paths in some cases
    def full_path path
      cur_dir = Dir.pwd
      Dir.chdir path
      full_path = Dir.pwd
      Dir.chdir cur_dir
      return full_path
    end

    def is_local_dev?
      Chef::Recipe::ZZDeploy.env.is_local_dev?
    end

    def deploy_app?
      Chef::Recipe::ZZDeploy.env.deploy_app?
    end

    def deploy_config?
      Chef::Recipe::ZZDeploy.env.deploy_config?
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

