# run this which sets up a remote debug session that can be attached to from the RubyMine IDE.
# this will terminate after each run so you need to rerun each time you debug.  Make sure to set the
# corresponding RubyMind debug configuration with:
#
# To set up a remote debug configuration select the run menu/Edit Configurations.
# Hit the + sign and add a Ruby Remote Debug config.  In this config set:
# Remote host: localhost
# Port: 7000
# Remote Root Folder: .
# Local Root Folder: .
#
sudo rdebug-ide -p 7000 -- `which chef-solo` -l debug -c chef-local/local-solo.rb -j chef-local/local-deploy.json
