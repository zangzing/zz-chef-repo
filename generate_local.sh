# run the chef scripts locally against the data in dna.json
#
bundle exec sudo chef-solo -l debug -c chef-local/local_solo.rb -j chef-local/local_deploy.json
