
source :gemcutter

if true || File.dirname(__FILE__) == "/var/chef-solo/cookbooks/zz-chef-repo"
  # amazon machine
  gem "zzsharedlib", :git => 'git@github.com:zangzing/zzsharedlib.git'
else
  # local testing
  gem "zzsharedlib", :path => "../zzsharedlib"
end
gem "right_aws"
gem "chef"
gem "ruby-debug-ide"
gem "ruby-debug-base"