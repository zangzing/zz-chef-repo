run_for_app(:photos => [:solo,:app,:app_master],
            :rollup => [:solo,:app,:app_master]) do |app_name, role, rails_env|


  maint = zz[:deploy_maint]

  # we have a symbolic link from the apps public/system dir to the shared system dir
  # so need to move the file into the shared dir to turn on maint and remove to turn off
  if maint
    # put maint link in system to tell nginx we are in maint mode
    log "Maint mode on" do
      notifies :run, "execute[maint_mode_on]"
    end
  else
    # remove the link to take us out of maint mode
    log "Maint mode off" do
      notifies :run, "execute[maint_mode_off]"
    end
  end

end