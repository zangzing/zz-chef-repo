# run the chef scripts locally against the data in dna.json
#
# testing with local .json for now
sudo chef-solo -l debug -c chef-local/remote-solo.rb -j chef-local/local-deploy.json
