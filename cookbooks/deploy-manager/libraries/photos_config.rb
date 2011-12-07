# do custom environment setup for photos
# determine relationship of machines and
# store back into zz node, once configured
# we output the zz node data as json which
# can be used by the app to pull in custom
# configuration - this data will hang under
# zz{:photos_config]
#
class Chef::Recipe::PhotosConfig
  # figure out any custom data we
  # want to set up on the node
  def self.init(node)
    @@node = node

    zz_env = Chef::Recipe::ZZDeploy.env
    puts zz_env
    # see if we should host redis
    node[:zz][:app_config] = {}
    node[:zz][:app_config][:redis_host] = calc_redis_host
    node[:zz][:app_config][:redis_servers] = calc_redis_all
    node[:zz][:app_config][:redis_slaves] = calc_redis_slaves
    node[:zz][:app_config][:we_host_redis] = calc_we_host_redis
    node[:zz][:app_config][:we_host_redis_slave] = calc_we_host_redis_slave

    node[:zz][:app_config][:resque_cpus] = calc_resque_cpus
    node[:zz][:app_config][:we_host_resque_cpu] = calc_we_host_resque_cpu

    node[:zz][:app_config][:all_servers] = calc_all_servers

    node[:zz][:app_config][:util_servers] = calc_util_servers

    node[:zz][:app_config][:app_servers] = calc_app_servers
    node[:zz][:app_config][:we_host_app_server] = calc_we_host_app_server

    node[:zz][:app_config][:resque_workers] = calc_resque_workers
    node[:zz][:app_config][:we_host_resque_worker] = calc_we_host_resque_worker

    node[:zz][:app_config][:resque_scheduler] = calc_resque_scheduler
    node[:zz][:app_config][:we_host_resque_scheduler] = calc_we_host_resque_scheduler

    node[:zz][:app_config][:resque_worker_count] = zz_env.worker_count
    node[:zz][:app_config][:resque_cpu_worker_count] = zz_env.cpu_worker_count

    node[:zz][:app_config][:eventmachine_worker_count] = zz_env.eventmachine_worker_count

  end

  def self.node
    @@node
  end

  def self.zz
    node[:zz]
  end

  def self.config
    zz[:app_config]
  end

  def self.instances
    zz[:instances]
  end

  # match all roles given in the roles array of strings
  def self.find_matching(roles)
    hosts = []
    instances.each_value do |instance|
      if roles.include?(instance[:role])
        host = instance[:local_hostname]
        hosts << host
      end
    end
    hosts
  end

  # returns the first match as a single string
  def self.find_one_match(roles)
    hosts = find_matching(roles)
    hosts.length == 0 ? "" : hosts[0]
  end

  # determine which host runs redis
  def self.calc_redis_host
    find_one_match(['db','solo', 'local'])
  end

  # master and slaves
  def self.calc_redis_all
    find_matching(['db','db_slave','solo','local'])
  end

  def self.calc_redis_slaves
    find_matching(['db_slave'])
  end

  def self.calc_we_host_redis
    config[:redis_host] == zz[:local_hostname]
  end

  def self.calc_we_host_redis_slave
    config[:redis_slaves].include?(zz[:local_hostname])
  end


  def self.calc_resque_cpus
    find_matching(['util','solo', 'local'])
  end

  def self.calc_we_host_resque_cpu
    config[:resque_cpus].include?(zz[:local_hostname])
  end

  def self.calc_all_servers
    hosts = []
    instances.each_value do |instance|
      host = instance[:local_hostname]
      hosts << host
    end
    hosts
  end

  def self.calc_util_servers
    find_matching(['util'])
  end

  def self.calc_app_servers
    find_matching(['app','app_master','solo', 'local'])
  end

  def self.calc_we_host_app_server
    config[:app_servers].include?(zz[:local_hostname])
  end

  def self.calc_resque_workers
    find_matching(['app','app_master','solo', 'local'])
  end

  def self.calc_we_host_resque_worker
    config[:resque_workers].include?(zz[:local_hostname])
  end

  def self.calc_resque_scheduler
    find_one_match(['app_master','solo', 'local'])
  end

  def self.calc_we_host_resque_scheduler
    config[:resque_scheduler] == zz[:local_hostname]
  end

end