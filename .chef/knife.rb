current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "gseitz"
client_key               "#{current_dir}/gseitz.pem"
validation_client_name   "zangzing-validator"
validation_key           "#{current_dir}/zangzing-validator.pem"
chef_server_url          "https://api.opscode.com/organizations/zangzing"
cache_type               'BasicFile'
cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
cookbook_path            ["#{current_dir}/../cookbooks"]
# EC2:
knife[:aws_access_key_id]     = "AKIAJZR7WODGPXONMRVA"
knife[:aws_secret_access_key] = "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"
