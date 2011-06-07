# install image-magick

Chef::Log.info("ZangZing=> Checking for ImageMagick ...")
package "ImageMagick" do
  action :install
end
