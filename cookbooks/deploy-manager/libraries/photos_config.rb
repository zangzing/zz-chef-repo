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
    # see if we should host redis
    node[:zz][:app_config] = {}
    node[:zz][:app_config][:redis_host] = calc_redis_host
    node[:zz][:app_config][:we_host_redis] = calc_we_host_redis

    node[:zz][:app_config][:resque_cpus] = calc_resque_cpus
    node[:zz][:app_config][:we_host_resque_cpu] = calc_we_host_resque_cpu

    node[:zz][:app_config][:app_servers] = calc_app_servers
    node[:zz][:app_config][:we_host_app_server] = calc_we_host_app_server

    node[:zz][:app_config][:resque_workers] = calc_resque_workers
    node[:zz][:app_config][:we_host_resque_worker] = calc_we_host_resque_worker

    node[:zz][:app_config][:resque_scheduler] = calc_resque_scheduler
    node[:zz][:app_config][:we_host_resque_scheduler] = calc_we_host_resque_scheduler

    node[:zz][:app_config][:db] = calc_db
    node[:zz][:app_config][:we_host_db] = calc_we_host_db
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

  # determine which host runs redis
  def self.calc_redis_host
    host = ""
    instances.each_value do |instance|
      if ['db','solo', 'local'].include?(instance[:role])
        host = instance[:local_hostname]
        break
      end
    end
    host
  end

  def self.calc_we_host_redis
    config[:redis_host] == zz[:local_hostname]
  end

  def self.calc_resque_cpus
    hosts = []
    instances.each_value do |instance|
      if ['util','solo', 'local'].include?(instance[:role])
        host = instance[:local_hostname]
        hosts << host
      end
    end
    hosts
  end

  def self.calc_we_host_resque_cpu
    config[:resque_cpus].include?(zz[:local_hostname])
  end

  def self.calc_app_servers
    hosts = []
    instances.each_value do |instance|
      if ['app','app_master','solo', 'local'].include?(instance[:role])
        host = instance[:local_hostname]
        hosts << host
      end
    end
    hosts
  end

  def self.calc_we_host_app_server
    config[:app_servers].include?(zz[:local_hostname])
  end

  def self.calc_resque_workers
    hosts = []
    instances.each_value do |instance|
      if ['app','app_master','solo', 'local'].include?(instance[:role])
        host = instance[:local_hostname]
        hosts << host
      end
    end
    hosts
  end

  def self.calc_we_host_resque_worker
    config[:resque_workers].include?(zz[:local_hostname])
  end

  def self.calc_resque_scheduler
    host = ""
    instances.each_value do |instance|
      if ['app_master','solo', 'local'].include?(instance[:role])
        host = instance[:local_hostname]
        break
      end
    end
    host
  end

  def self.calc_we_host_resque_scheduler
    config[:resque_scheduler] == zz[:local_hostname]
  end

  def self.calc_db
    host = ""
    instances.each_value do |instance|
      if ['db','solo', 'local'].include?(instance[:role])
        host = instance[:local_hostname]
        break
      end
    end
    host
  end

  def self.calc_we_host_db
    config[:db] == zz[:local_hostname]
  end


end