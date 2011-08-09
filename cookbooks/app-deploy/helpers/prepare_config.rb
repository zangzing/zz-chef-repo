puts "-----TEST_PREPARE_CONFIG------"
puts zz[:app_name]
puts zz_base_dir
puts zz_shared_dir
puts zz_current_dir
puts zz_release_dir
puts "-----TEST_PREPARE_CONFIG------"

# copy zz_app_dna.json directly into app config directory
# since it is specific to that deploy configuration and we
# don't want to possibly change a running app by linking from
# the shared config directory
dna_src = "#{zz_env.shared_dir}/config/zz_app_dna.json"
dna_dst = "#{zz_env.release_dir}/config/zz_app_dna.json"

e = execute "copy_zza_app_dna" do
  command "cp #{dna_src} #{dna_dst} && chown #{deploy_user}:#{deploy_group} #{dna_dst}"
  action :nothing
end
e.run_action(:run)  # execute in the compile phase so happens right now


# install the bundle - need to use su since just calling it directly
# causes it to work out of our chef directory even though we cd to the
# proper directory.  Must be something about how it looks at the environment
#
e = execute "bundle_install" do
  cwd zz_env.release_dir
  command "su -l #{zz_env.deploy_user} -c 'cd #{zz_env.release_dir} && bundle install --path /var/chef/cookbooks/zz-chef-repo_bundle --deployment'"
  action :nothing
end
e.run_action(:run)  # execute in the compile phase so happens right now
