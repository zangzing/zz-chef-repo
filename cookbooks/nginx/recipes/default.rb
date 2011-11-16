run_for_app(:photos => [:solo,:app,:app_master,:local],
            :rollup => [:solo,:app,:app_master,:local]) do |app_name, role, rails_env|

  # The path prefix for the photos service
  photos_path_prefix = '/service'
  photos_api_path_prefix = '/zz_api'

  # local dev skips most of the config
  is_local_dev = role == :local

  # see if we should install nginx
  # install nginx if needed
  version =  "1.0.6"
  # do a version check to avoid having to install if we already have proper version
  `/usr/sbin/nginx -v 2>&1 | grep 1\.0\.6`
  already_installed = $?.exitstatus == 0
  `/usr/sbin/nginx -V 2>&1 | grep mod_zip`
  already_installed = already_installed && $?.exitstatus == 0

  directory "/var/log/nginx" do
    owner deploy_user
    group deploy_group
    mode "1777"
    action :create
    recursive true
  end

  if !is_local_dev
    # put the base level package on the machine, we will upgrade via the compile below
    package "nginx" do
      action :install
      not_if {already_installed}
    end
  end

  name = "nginx"
  files_at = "nginx-all-#{version}"
  work_dir = "/tmp"

  # pull the file out of the cookbook and move to a temp dir
  cookbook_file "#{work_dir}/#{files_at}.zip" do
    source "#{files_at}.zip"
    action :create_if_missing
    not_if {already_installed}
  end

  # Compile and Install
  bash "compile_#{name}_source" do
    Chef::Log.info( "ZangZing=> #{name} building from source and installing")
    cwd "#{work_dir}"
    code <<-EOH
      unzip #{files_at}.zip
      cd #{files_at}/#{name}-#{version}
      ./configure --with-cc-opt="-Wno-deprecated-declarations -Wno-uninitialized" --prefix=/usr --pid-path=/var/run/nginx.pid --conf-path=/etc/nginx/nginx.conf \
          --http-log-path=/var/log/nginx/access_log \
          --error-log-path=/var/log/nginx/error_log --with-http_ssl_module --add-module=../nginx_upload_module-2.2.0 \
          --add-module=../mod_zip-1.1.6 \
          --with-http_realip_module --with-http_gzip_static_module \
          --add-module=../nginx-upload-progress-module --with-pcre=../pcre-8.12
      make && sudo make install && sudo rm -rf /usr/local/nginx
    EOH
    not_if {already_installed}
  end

  # Clean Up Tmp File
  execute "Clean Up #{work_dir}/#{name} files" do
    command "rm -rf #{work_dir}/#{files_at}*"
    not_if {already_installed}
  end

  if is_local_dev
    case app_name
      when :photos
        nginx_conf_dir = full_path(project_root_dir() + "/../server/config/nginx")

      when :rollup
        nginx_conf_dir = full_path(project_root_dir() + "/../rollup/config/nginx")
    end
    nginx_tmp = "/data/tmp/nginx"
    photos_tmp = "/data/tmp"
    v3_homepage_dir = "/data/v3homepage"
  else
    nginx_conf_dir = "/etc/nginx"
    nginx_tmp = "/media/ephemeral0/nginx"
    photos_tmp = "/data/tmp"
    v3_homepage_dir = "/data/v3homepage"
  end

  # make sure tmp dir created and give proper permissions
  directory nginx_tmp do
    owner deploy_user
    group deploy_group
    mode "1777"
    action :create
    recursive true
  end

  # make sure photo tmp dir created and give proper permissions
  # this directory is expected to be on an EBS volume to survive restarts
  # with that image
  directory photos_tmp do
    owner deploy_user
    group deploy_group
    mode "1777"
    action :create
    recursive true
  end

  # make sure photo tmp dir created and give proper permissions
  # this directory is expected to be on an EBS volume to survive restarts
  # with that image
  directory "#{photos_tmp}/nginx" do
    owner deploy_user
    group deploy_group
    mode "1777"
    action :create
  end

  directory "/var/run/zz" do
    mode "0755"
    action :create
  end

  # create the fast uploads tmp dirs that nginx needs
  (0..9).each do |dir|
     directory "#{photos_tmp}/nginx/fast_uploads/#{dir}" do
        mode 0775
        owner deploy_user
        group deploy_group
        action :create
        recursive true
     end
  end

  #
  # On amazon we will have a load balancer as a general rule.
  # The load balancer takes care of ssl but we still want
  # to support ssl for development so we keep support in the
  # configuration.
  #
  group_config = zz[:group_config]
  amazon_elb = group_config[:amazon_elb]
  ssl_supported = amazon_elb.empty?   # when we have an elb we don't need to turn on our own ssl
  host_port = ""
  listen_port = 80 # default port
  ssl_listen_port = 443
  ssl_key = "localhost.key"
  ssl_crt = "localhost.crt"

  host_name = group_config[:vhost]
  asset_host_name = nil # default, no asset host
  remap_error_pages = false
  dev_upstream_port = 3001

  case app_name
    when :photos
      nginx_erb = "photos-shared-server.conf.erb"
      case rails_env
        when :photos_production
          site_host_name = 'site.zangzing.com'
          asset_host_name = "*.assets.photos.zangzing.com"
          remap_error_pages = true
          ssl_key = "star_zangzing_com.key"
          ssl_crt = "star_zangzing_com.crt"
        when :photos_staging
          site_host_name = 'staging.site.zangzing.com'
          asset_host_name = "*.assets.#{host_name}"
          remap_error_pages = true
          ssl_key = "staging.key"
          ssl_crt = "staging.crt"
        when :development
          remap_error_pages = false
          remap_error_pages = false
          listen_port = 80
          ssl_listen_port = 443
          dev_upstream_port = 3001
          site_host_name = 'staging.site.zangzing.com'
      end

    when :rollup
      nginx_erb = "rollup-shared-server.conf.erb"
      case rails_env
        when :production
          remap_error_pages = true
          ssl_key = "star_zangzing_com.key"
          ssl_crt = "star_zangzing_com.crt"
        when :staging
          remap_error_pages = true
          ssl_key = "staging.key"
          ssl_crt = "staging.crt"
        when :development
          remap_error_pages = false
          listen_port = 80
          ssl_listen_port = 443
          dev_upstream_port = 3001
      end
  end

  config_vars = {
      :app_name => app_name.to_s,
      :host_name => host_name,
      :asset_host_name => asset_host_name,
      :host_port => host_port,
      :listen_port => listen_port,
      :site_host_name => site_host_name,
      :remap_error_pages => remap_error_pages,
      :is_local_dev => is_local_dev,
      :photos_path_prefix => photos_path_prefix,
      :photos_api_path_prefix => photos_api_path_prefix,
      :ssl_supported => ssl_supported,
      :ssl_listen_port => ssl_listen_port,
      :ssl_key => ssl_key,
      :ssl_crt => ssl_crt,
      :nginx_tmp => nginx_tmp,
      :nginx_photos => photos_tmp + "/nginx",
      :nginx_conf_dir => nginx_conf_dir,
      :v3_homepage_dir => v3_homepage_dir,
      :dev_upstream_port => dev_upstream_port,
      :amazon_elb => amazon_elb
  }

  # copy ssl related files
  template nginx_conf_dir + "/" + ssl_key do
    source ssl_key + ".erb"
    owner root_user
    group root_group
    mode 0640
    only_if { ssl_supported }
  end

  template nginx_conf_dir + "/" + ssl_crt do
    source ssl_crt + ".erb"
    owner root_user
    group root_group
    mode 0640
    only_if { ssl_supported }
  end


  # if you send delayed actions to another resource
  # multiple times they will only execute once
  # this only holds for delayed actions but is
  # the behavior we want

  #install custom locations for application
  template nginx_conf_dir + "/nginx.conf" do
    source "nginx.conf.erb"
    owner deploy_user
    group root_group
    mode 0644
    variables(config_vars)
    notifies :restart, "service[nginx]" if is_local_dev == false
    notifies :enable, "service[nginx]" if is_local_dev == false
  end

  template nginx_conf_dir + "/nginx-shared-server.conf" do
    source nginx_erb
    owner deploy_user
    group root_group
    mode 0644
    variables(config_vars)
    notifies :restart, "service[nginx]" if is_local_dev == false
    notifies :enable, "service[nginx]" if is_local_dev == false
  end

  if is_local_dev == false
    service "nginx" do
      supports :status => true, :stop => true, :restart => true
      action :nothing
    end
  end

end
