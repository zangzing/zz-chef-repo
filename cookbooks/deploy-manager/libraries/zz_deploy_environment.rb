require "json"

class Chef::Recipe::ZZDeployEnvironment
  def initialize(node)
    @node = node
    zz = node[:zz]

    # move ec2 data under zz
    ec2 = node[:ec2]
    ec2 = ec2.to_hash unless ec2.nil?
    zz[:ec2] = ec2

    # determine our role
    if is_local_dev?
      instance_id = "local"
      local_hostname = "localhost"
      public_hostname = "localhost"
    else
      # find our instance id and set it
      ec2 = zz[:ec2]
      instance_id = ec2[:instance_id]
      local_hostname = ec2[:local_hostname]
      public_hostname = ec2[:public_hostname]
    end

    zz[:instance_id] = instance_id
    zz[:local_hostname] = local_hostname
    zz[:public_hostname] = public_hostname

    instance = node[:zz][:instances][instance_id]
    raise "Could not find our instance in config - our instance id is #{instance_id}" if instance.nil?
    zz[:deploy_role] = instance[:role]
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

  # determine if this instance should host
  # the redis server
  # true - yes we should install redis here
  #
  def should_host_redis?
#    return @should_host_redis if @should_host_redis != nil
#    if redis_host_name == this_host_name
#      @should_host_redis = true
#    else
#      @should_host_redis = false
#    end
  end

  # get the address of the host where
  # our redis isntance is - on single
  # deploy it will be us, on multi
  # it currently will live on the soon
  # to be useless db_master since we will
  # use Amazon RDS for db
  def redis_host_name
#    return @redis_host_name if @redis_host_name != nil
#
#    instances = ey['environment']['instances']
#    # assume solo machine
#    @redis_host_name = this_host_name
#
#    # not solo so see if we are db_master which
#    # is where we host redis
#    instances.each do |instance|
#      if instance['role'] == 'db_master'
#        @redis_host_name = instance['private_hostname']
#        break
#      end
#    end
#    @redis_host_name
  end

  # determine if this instance should host
  # the resque cpu job instance
  #
  def should_host_resque_cpu?
#    return @should_host_resque_cpu if @should_host_resque_cpu != nil
#    if resque_cpu_host_names.include?(this_host_name)
#      @should_host_resque_cpu = true
#    else
#      @should_host_resque_cpu = false
#    end
  end

  # get the resque cpu bound jobs hosts
  def resque_cpu_host_names
#    return @resque_cpu_host_names if @resque_cpu_host_names != nil
#
#    instances = ey['environment']['instances']
#    # assume solo machine
#    @resque_cpu_host_names = []
#
#    # not solo so see if we are util which
#    # is where we host resquecpujobs
#    instances.each do |instance|
#      if instance['role'] == 'util' && instance['name'] =~ /^resquecpujobs/
#        @resque_cpu_host_names << instance['private_hostname']
#      end
#    end
#    if (@node['instance_role'] != 'solo')
#      if @resque_cpu_host_names.length == 0
#        # no resque cpu hosts found
#      end
#    else
#      # solo machine so run here
#      @resque_cpu_host_names << this_host_name
#    end
#    @resque_cpu_host_names
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
    return zz[:deploy_app]
  end

  def deploy_config?
    return zz[:deploy_config]
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
  def self.init(node)
    @@zz_environ ||= Chef::Recipe::ZZDeployEnvironment.new(node)
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

