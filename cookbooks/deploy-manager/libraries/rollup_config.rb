# do custom environment setup for app
# determine relationship of machines and
# store back into zz node, once configured
# we output the zz node data as json which
# can be used by the app to pull in custom
# configuration - this data will hang under
# zz{:app_config]
#
class Chef::Recipe::RollupConfig
  # figure out any custom data we
  # want to set up on the node
  def self.init(node)
    @@node = node
    # see if we should host redis
    config = {}

    node[:zz][:app_config] = config
  end

  def self.node
    @@node
  end

  def self.config
    node[:zz][:app_config]
  end

  def self.host_redis?
    config[:host_redis]
  end

end