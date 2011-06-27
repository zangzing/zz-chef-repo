# call like this
run_for_app(:photos => [:solo,:util,:app,:app_master]) do |app_name, role, rails_env|

  package "ImageMagick" do
    action :install
  end

end
