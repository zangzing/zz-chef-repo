# run the chef scripts locally against the data in dna.json
#
sudo chef-solo -l debug -c chef-local/local-solo.rb -j chef-local/local-deploy.json
