# this class is used to track the number of licenses granted
# and which machines get them and which don't
# This ensures that we do not overuse our NewRelic Licenses
#
class LicenseAllocator
  attr_accessor :license_count, :all_apps, :all_utils, :pick_apps, :pick_utils

  # set up the license count and track the app and util internal host names
  # used to determine which hosts get licenses and which do not
  # we allocate the licenses evenly across the app and util machines
  # if we have fewer than an even split of one type the other will
  # get the extra instances.  So for example if we have 8 licenses
  # but only 3 app servers and 5 util, we will give 3 to the app and 5
  # to the util. If we have 5 app and 5 util the split will be 4 4
  #
  # We sort the lists to ensure that the algorithm is deterministic
  # given the same inputs since this has to operate on multiple
  # physically separate machines and produce consistent results
  #
  def initialize(license_count, app_hostnames, util_hostnames)
    self.license_count = license_count
    self.all_apps = app_hostnames.sort
    self.all_utils = util_hostnames.sort
    self.pick_apps = []
    self.pick_utils = []

    # now divide them up
    apps_remaining = self.all_apps.count
    utils_remaining = self.all_utils.count
    total_hosts = apps_remaining + utils_remaining
    remaining = license_count > total_hosts ? total_hosts : license_count
    while remaining > 0
      if apps_remaining > 0
        apps_remaining -= 1
        remaining -= 1
        pick_apps << all_apps[apps_remaining]
      end
      if utils_remaining > 0
        utils_remaining -= 1
        remaining -= 1
        pick_utils << all_utils[utils_remaining]
      end
    end
  end

  # returns true if this hostname should get a license
  def use_license?(hostname)
    return pick_apps.include?(hostname) || pick_utils.include?(hostname)
  end
end

#apps = ['app3', 'app2', 'app5', 'app4', 'app1']
#utils = ['util5', 'util2', 'util1', 'util4', 'util3']
#
#l = LicenseAllocator.new(8, apps, utils)
#puts l.all_apps
#puts l.all_utils
#
#puts "picks"
#puts l.pick_apps
#puts l.pick_utils
#
#myname = 'app1'
#
#puts l.use_license?(myname)
#
#puts l.use_license?('util3')

