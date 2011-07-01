# run the chef scripts locally against the data in dna.json
#
# testing with local .json for now
sudo bundle exec chef-solo -l debug -c chef-local/remote_solo.rb -j chef-local/remote_app_restart.json
