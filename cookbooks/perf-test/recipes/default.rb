# install image-magick

cookbook_file "/home/ec2-user/test.jpg" do
  source "test.jpg"
  mode 0755
  owner "ec2-user"
  group "ec2-user"
end

cookbook_file "/home/ec2-user/test.rb" do
  source "test.rb"
  mode 0755
  owner "ec2-user"
  group "ec2-user"
end
