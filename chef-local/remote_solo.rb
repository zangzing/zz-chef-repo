cookbook_path "/var/chef/cookbooks/zz-chef-repo/cookbooks"
role_path "/var/chef/cookbooks/zz-chef-repo/roles"

handler_path = "/var/chef/cookbooks/zz-chef-repo/handlers/report_handler"
require handler_path
handler = ZZ::ReportHandler.new
report_handlers << handler
exception_handlers << handler


