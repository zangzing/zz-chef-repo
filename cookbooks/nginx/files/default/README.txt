
For simplicity we combine all the dependent directories into one.  For example in the nginx zip we also include PCRE and the various plugins we use.  This way we only have to download and unzip a single file to get everything we need.  If you need to add new dependencies you would unzip the current nginx.zip, add the directories of the dependencies and then rezip, and place here.


NOTE: Unless a fix has been made by the nginx team to the real_ip module we need to apply the following patch.  Proceed with caution since you must verify that the patch still makes sense for whatever version you are patching.  To apply the patch, expand the nginx-1.x.x.zip file and then copy the patch to the root.  Run the following command from that directory:

patch -p 0 -d . < real_ip_forwarded_fix.patch

Now you can zip the entire contents along with the plugins into the nginx-all-1.x.x.zip


Note: we also changed the following files in mod_zip-1.1.6 to turn off char set conversion which does not work on the mac (at least with standard libraries) and is not needed.

config: changed ngx_feature_libs= to be blank in case of non unix.

ngx_http_zip_file.c: added conditional around static ngx_str_t ngx_http_zip_header_charset_name = ngx_string("upstream_http_x_archive_charset");
 so it is not declared when NGX_ZIP_HAVE_ICONV is not set.
