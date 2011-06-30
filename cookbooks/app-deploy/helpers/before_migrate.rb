puts "-----TEST_BEFORE_MIGRATE------"
puts zz[:app_name]
puts zz_base_dir
puts zz_shared_dir
puts zz_current_dir
puts zz_release_dir
puts "-----TEST_BEFORE_MIGRATE------"


# look recipe code within a hook
execute "recipe_from_hook" do
    command "ls -al #{zz_release_dir}"
    action :run
end
