module ZZ
  class ReportHandler < Chef::Handler

    def initialize
      puts "MAKING ReportHandler"
    end

    def report
      puts "REPORT HANDLER RUN"
      env = Chef::Recipe::ZZDeploy.env
      zz = env.zz
      amazon = env.amazon
      utils = ZZSharedLib::Utils.new(amazon)
      instances = [ env.this_amazon_instance ]
      # determine if we were deploying the app or chef
      state_tag = env.deploy_config? ? :deploy_chef : :deploy_app
      if failed?
        # mark the status of the machine as an error
        utils.mark_deploy_state(instances, state_tag, ZZSharedLib::Utils::ERROR)
        # +run_status+ is a value object with all of the run status data
        #message << "#{run_status.formatted_exception}\n"
        # Join the backtrace lines. Coerce to an array just in case.
        #message << Array(backtrace).join("\n")
      else
        # run was ok so mark state as ready
        utils.mark_deploy_state(instances, state_tag, ZZSharedLib::Utils::READY)
      end
      puts "Chef run completed on #{node.name}\n"
    end
  end
end