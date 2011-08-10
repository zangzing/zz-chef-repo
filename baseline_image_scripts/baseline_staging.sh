# This file is the template from which we generate a new baseline image.
#
# use something like this to copy to remote machine we are going to make an image from (from your machine)
#
# step 1 - launch image from amazon linux 32 bit ami, pass the size of the ebs volume wanted, and expose the ephemeral block device (use the Amazon Command Util instance to do this since it has been set up with the command line utils):
# ec2-run-instances --key amazon_staging --group security_staging -b /dev/sda1=:16 -b '/dev/sda2=ephemeral0' -t c1.medium ami-8c1fece5
#
# use the console to get the public ip info for the instance you started in step 1 and ssh into that instance (substitute the actual ip into the sample command lines below)
#
# step 2 - copy the baseline script onto that instance you just created (use the appropriate baseline_staging or baseline_production)
# scp -i ~/.ssh/amazon_staging.pem /Users/gseitz/Develop/ZZ/zz-chef-repo/baseline_image_scripts/baseline_staging.sh ec2-user@ec2-67-202-26-165.compute-1.amazonaws.com:/home/ec2-user
# (on remote machine)
#
# step 3 - ssh into the instance you created
# ssh -i ~/.ssh/amazon_staging.pem ec2-user@ec2-67-202-26-165.compute-1.amazonaws.com
#
# step 4 - resize the ebs volume to use the size you passed in
# sudo resize2fs /dev/sda1
#
# step 5 - run the baseline creation script
# chmod a+x ~/baseline_staging.sh
# ./baseline_staging.sh
#
# step 6 start the amazon aws console from a web browser
#
# step 7 create the new baseline image from the instance you prepped
#
# step 8 manually tag the name of the image to be baseline_staging or baseline_production from the AWS console
#

# install extra package manager repositories for items not found in amazon repos
sudo rpm -Uvh http://download.fedoraproject.org/pub/epel/5/i386/epel-release-5-4.noarch.rpm

sudo yum -y groupinstall "Development Tools"

sudo yum -y install git

sudo yum -y install zlib-devel

sudo yum -y install openssl-devel

sudo yum -y install readline-devel

sudo yum -y install perl-ExtUtils-MakeMaker

sudo yum -y install libxml2-devel

sudo yum -y install libxslt-devel

sudo yum -y install mysql

sudo yum -y install mysql-devel

sudo cp /usr/share/zoneinfo/US/Pacific /etc/localtime


#sudo bash < <(curl -s https://rvm.beginrescueend.com/install/rvm)

#echo '[[ -s "/usr/local/rvm/scripts/rvm" ]] && . "/usr/local/rvm/scripts/rvm" # Load RVM function' >> ~/.bash_profile

#source ~/.bash_profile

# default Ruby to REE
(
cat <<'EOP'
export PATH="/opt/ree/bin:$PATH"
EOP
) > temp
sudo cp temp /etc/profile.d/ree.sh
source /etc/profile
export PATH="/opt/ree/bin:$PATH"

#rvm install 1.8.7

#rvm install ree

#rvm --default use ree

sudo mkdir /var/chef
sudo chown ec2-user:ec2-user /var/chef

(
cat <<'EOP'
{
  "aws_access_key_id": "AKIAJZR7WODGPXONMRVA",
  "aws_secret_access_key": "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"
}
EOP
) > temp
sudo cp temp /var/chef/amazon.json
sudo chmod 0644 /var/chef/amazon.json


(
cat <<'EOP'
-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEAu5pSnXtnZf8QVc47kZIt2pQOjuX6wXFLCsEK3Pfp/ruF/lMd
tWqwb/xq2I+WZPgIz7UUlElGuXo38C/tR5/VmTxSi7MYNpRsRYkytxXtgQk+zu6O
5plnpNE9+oQRrpfwFq0Rw9HwOsLIqRV713WnFjkg1pi915/p1qm5h4HkBgLXO6qM
BKS9AXNalWowEydFe5CsrNGLFbVG/aT5UIA3v/1RZeNTedRlug8ujgViEZCLD1pv
yP2o7rFgeLWdjNQVvKHeUAH3XEF2a8NG39V4Gq0DKy3W6uswn978yAYhx6mOfO7p
dZu27jpFUp9TAG29Cf+aGi3s8B1QhAPtfX/2dwIBIwKCAQA69fy1Jsi5p+8w6Qto
Q+KGhk234eEYOYyc+teHRpn/mgWKceTD/PWfidhv8pz7KWHa4SO5k19e3UTH1Ixm
97go2HG24IPz5YEdKx6RUAjQyGQyaDuKTXhYXwTZtHqV9TzT7UAY+NZ43iHOvZvz
QjvTyM/OaoTOvTrdEMVH2F2bfLJqO8EwY68GgbHR/01Kw/X31meFQ8E4WFP5DTFJ
Zmt3r67RG13HV4oVG9N3Yz8hDbjH9mlk0sQHy5pQ56h0H3TIbGTbr4vtfwxYjgVB
Ew1JkpJkmymmkZGE3hYX8ENZFfPafVvBqwkKrhvPZz0uimbtC0hwy08wuORvH1qt
kETTAoGBAOYgT0LHr2NunjoIR77YP7jl3PNFK9oLoPmkf6YTcVWBXt77JeMk4Lsb
V7eZg+vNTTZPrvkPnNLQdUbHzW0LGfIaO21bYG+9zoZicaUU5sPP6lLKH6gU3rxW
1CGQLoSEohR9ArXBDfjCzcf5bRv2EYIlHGyA16PEKCxIQBDRMZYbAoGBANCyEYV0
cls4T7w2x5KS1SDeOBLuKzL5tXC1Ep8k94xNb3S6IIvDaMS4pL7Vugp+AGXmVZu+
ZSCREV07Hl5WEDuwU16WuMpk9fdMpQVwPbiPNiRmw2R+PUgt6yCOlVKb8CxIumzX
+S0JcQ2Wuy6NjJZPv0cbLHu/ek1l1HZVg1bVAoGBAJc5za+KiTK2Z/o/9KH70hpr
Ksu/vbssNpVsGV6BziI/EnVF9FNwAWUDVuZdkTSOOg2/Vbmci6B6W7Irhv6Do1Xz
+yqbIh2LW9SnF3scXSGXQjZnkSVPiw4NLFCR8q7a0Ojkb37AsWj1CuJ/VlQz/OB+
yYkhd8NjpV7tpnFzhvw9AoGBAMTFJnaDvEdg+rjF715P7YVjzng/pRLOLrq5WrNO
vYRJAq/isPjOL5Tom1TYJHBK6m60mdv8qH3Km1fnSITUzXobR0qOG/IHa5FlhaYK
vdnmHRsBziuM9/OZAkNEm2slUCnA6kld6u/y9ZB4LNQfD4ZocoTfG1Aa76gPjc6o
ZeQnAoGAfXzdCSq5YdxwLxKeU8sZYBMr/wVSV20fMGTxCgqTifhBh7owIWdIlzKx
UvhR+xaARJ2aWD+10x0f/jqFG8CUiS98t8m7LfJy17Jr8n3Q3/e/B/eqfCIWYVju
cDwXJwI9hjpbP/ZgBnybONwhEZrANJE+mLLRZkwNIns/TZwfvMk=
-----END RSA PRIVATE KEY-----
EOP
) > temp
sudo cp temp /etc/ssh/github_rsa
sudo chmod 0600 /etc/ssh/github_rsa
sudo chown ec2-user:ec2-user /etc/ssh/github_rsa

cat /etc/ssh/ssh_config > temp
(
cat <<'EOP'
# Added to support github account
StrictHostKeyChecking no
Host github.com
    IdentityFile /etc/ssh/github_rsa
    User git
EOP
) >> temp
sudo cp temp /etc/ssh/ssh_config

(
cat <<'EOP'
## Sudoers allows particular users to run various commands as
## the root user, without needing the root password.
##
## Examples are provided at the bottom of the file for collections
## of related commands, which can then be delegated out to particular
## users or groups.
##
## This file must be edited with the 'visudo' command.

## Host Aliases
## Groups of machines. You may prefer to use hostnames (perhaps using
## wildcards for entire domains) or IP addresses instead.
# Host_Alias     FILESERVERS = fs1, fs2
# Host_Alias     MAILSERVERS = smtp, smtp2

## User Aliases
## These aren't often necessary, as you can use regular groups
## (ie, from files, LDAP, NIS, etc) in this file - just use %groupname
## rather than USERALIAS
# User_Alias ADMINS = jsmith, mikem


## Command Aliases
## These are groups of related commands...

## Networking
# Cmnd_Alias NETWORKING = /sbin/route, /sbin/ifconfig, /bin/ping, /sbin/dhclient, /usr/bin/net, /sbin/iptables, /usr/bin/rfcomm, /usr/bin/wvdial, /sbin/iwconfig, /sbin/mii-tool

## Installation and management of software
# Cmnd_Alias SOFTWARE = /bin/rpm, /usr/bin/up2date, /usr/bin/yum

## Services
# Cmnd_Alias SERVICES = /sbin/service, /sbin/chkconfig

## Updating the locate database
# Cmnd_Alias LOCATE = /usr/bin/updatedb

## Storage
# Cmnd_Alias STORAGE = /sbin/fdisk, /sbin/sfdisk, /sbin/parted, /sbin/partprobe, /bin/mount, /bin/umount

## Delegating permissions
# Cmnd_Alias DELEGATING = /usr/sbin/visudo, /bin/chown, /bin/chmod, /bin/chgrp

## Processes
# Cmnd_Alias PROCESSES = /bin/nice, /bin/kill, /usr/bin/kill, /usr/bin/killall

## Drivers
# Cmnd_Alias DRIVERS = /sbin/modprobe

# Defaults specification

#
# Disable "ssh hostname sudo <cmd>", because it will show the password in clear.
#         You have to run "ssh -t hostname sudo <cmd>".
#
#Defaults    requiretty

#
# Preserving HOME has security implications since many programs
# use it when searching for configuration files.
#
Defaults    always_set_home

Defaults    env_reset
Defaults    env_keep =  "COLORS DISPLAY HOSTNAME HISTSIZE INPUTRC KDEDIR LS_COLORS"
Defaults    env_keep += "MAIL PS1 PS2 QTDIR USERNAME LANG LC_ADDRESS LC_CTYPE"
Defaults    env_keep += "LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES"
Defaults    env_keep += "LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE"
Defaults    env_keep += "LC_TIME LC_ALL LANGUAGE LINGUAS _XKB_CHARSET XAUTHORITY"

#
# Adding HOME to env_keep may enable a user to run unrestricted
# commands via sudo.
#
# Defaults   env_keep += "HOME"

Defaults    secure_path = /sbin:/bin:/usr/sbin:/opt/ree/bin:/usr/bin

## Next comes the main part: which users can run what software on
## which machines (the sudoers file can be shared between multiple
## systems).
## Syntax:
##
##  user    MACHINE=COMMANDS
##
## The COMMANDS section may have other options added to it.
##
## Allow root to run any commands anywhere
root    ALL=(ALL)   ALL

## Allows members of the 'sys' group to run networking, software,
## service management apps and more.
# %sys ALL = NETWORKING, SOFTWARE, SERVICES, STORAGE, DELEGATING, PROCESSES, LOCATE, DRIVERS

## Allows people in group wheel to run all commands
# %wheel    ALL=(ALL)   ALL

## Same thing without a password
# %wheel    ALL=(ALL)   NOPASSWD: ALL

## Allows members of the users group to mount and unmount the
## cdrom as root
# %users  ALL=/sbin/mount /mnt/cdrom, /sbin/umount /mnt/cdrom

## Allows members of the users group to shutdown this system
# %users  localhost=/sbin/shutdown -h now
ec2-user ALL = NOPASSWD: ALL
EOP
) > temp
sudo cp temp /etc/sudoers
sudo chmod 440 /etc/sudoers


sudo mkdir -p /opt/ree
sudo chown ec2-user:ec2-user /opt/ree

wget http://rubyenterpriseedition.googlecode.com/files/ruby-enterprise-1.8.7-2011.03.tar.gz
tar xzvf ruby-enterprise-1.8.7-2011.03.tar.gz
./ruby-enterprise-1.8.7-2011.03/installer --auto /opt/ree --dont-install-useful-gems
rm -rf ruby-enterprise*


gem update --system

(
cat <<'EOP'
gem: --no-ri --no-rdoc
EOP
) > ~/.gemrc

gem install bundler

gem install chef

# chef solo setup
sudo mkdir -p /etc/chef
sudo chown ec2-user:ec2-user /etc/chef

mkdir -p /var/chef/cookbooks
cd /var/chef/cookbooks
git clone git@github.com:zangzing/zz-chef-repo.git
cd /var/chef/cookbooks/zz-chef-repo
bundle install --path /var/chef/cookbooks/zz-chef-repo_bundle --deployment
cd ~




