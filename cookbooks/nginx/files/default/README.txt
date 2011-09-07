
For simplicity we combine all the dependent directories into one.  For example in the nginx zip we also include PCRE and the various plugins we use.  This way we only have to download and unzip a single file to get everything we need.  If you need to add new dependencies you would unzip the current nginx.zip, add the directories of the dependencies and then rezip, and place here.


NOTE: Unless a fix has been made by the nginx team to the real_ip module we need to apply the following patch.  Proceed with caution since you must verify that the patch still makes sense for whatever version you are patching.  To apply the patch, expand the nginx-1.x.x.zip file and then copy the patch to the root.  Run the following command from that directory:

patch -p 0 -d . < real_ip_forwarded_fix.patch

Now you can zip the entire contents along with the plugins into the nginx-all-1.x.x.zip


