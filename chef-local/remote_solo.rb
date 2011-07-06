cookbook_path "/var/chef/cookbooks/zz-chef-repo/cookbooks"
role_path "/var/chef/cookbooks/zz-chef-repo/roles"

handler_path = "/var/chef/cookbooks/zz-chef-repo/handlers/report_handler"

require handler_path

t = ZZ::ReportHandler.new(4,5)
t2 = ZZ::ReportHandler.new(6,7)
report_handlers << t
exception_handlers << t2


