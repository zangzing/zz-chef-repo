cookbook_path "/var/chef/cookbooks/zz-chef-repo/cookbooks"
role_path "/var/chef/cookbooks/zz-chef-repo/roles"

handler_path = "/var/chef/cookbooks/zz-chef-repo/handlers/report_handler"
require handler_path
report_handlers << ZZ::ReportHandler.new


