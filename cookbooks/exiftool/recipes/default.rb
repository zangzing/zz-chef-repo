run_for_app(:photos => [:solo,:util,:app,:app_master,:local]) do |app_name, role, rails_env|

  is_local_dev = role == :local

  # install exiftool if out of date
  name = "Image-ExifTool"
  version =  "8.60"

  # do a version check to avoid having to install if we already have proper version
  `exiftool -ver | grep ^'8\.60'`
  already_installed = $?.exitstatus == 0

  work_dir = "/tmp"

  #Download remote source into /tmp directory
  cookbook_file "#{work_dir}/#{name}-#{version}.tar.gz" do
    source "#{name}-#{version}.tar.gz"
    action :create_if_missing
    not_if {already_installed}
  end

  # Compile and Install
  bash "compile_#{name}_source" do
    cwd "#{work_dir}"
    code <<-EOH
      tar zxf #{name}-#{version}.tar.gz
      cd #{name}-#{version}
      perl Makefile.PL
      make test
      sudo make install
    EOH
    not_if {already_installed}
  end

  # Clean Up Tmp File
  execute "Clean Up #{work_dir}/#{name} files" do
    command "rm -rf #{work_dir}/#{name}-#{version}*"
    not_if {already_installed}
  end

end