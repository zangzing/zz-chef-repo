# take the current directory of this file and return a fully
# qualified path based on the relative path passed in
def expand_path rel_path
  cur_dir = Dir.pwd
  path = File.dirname(__FILE__) + "/" + rel_path
  Dir.chdir path
  full_path = Dir.pwd
  Dir.chdir cur_dir
  return full_path
end

cookbook_path    expand_path('../cookbooks')
log_level         :info
file_store_path  expand_path('../.chefpaths')
file_cache_path  expand_path('../.chefpaths')
role_path        expand_path('../roles')
Chef::Log::Formatter.show_time = false


# FYI
# To create a group on Mac use
#
# sudo dseditgroup -o create groupname
#
# we can use this to add a user to a group
#
# sudo dseditgroup -o edit -t user -a username deploy
#
# and to check membership
#
# dseditgroup -o checkmember -m username groupname
#




