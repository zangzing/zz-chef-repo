# run the chef scripts locally against the data in dna.json
#
# testing with local .json for now
sudo bundle exec chef-solo -l debug -c chef-local/remote-solo.rb -j chef-local/remote-deploy-config.json
