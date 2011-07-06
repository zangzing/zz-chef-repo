module ZZ
  class ReportHandler < Chef::Handler

    def initialize
      puts "MAKING ReportHandler"
    end

    def report
      puts "REPORT HANDLER RUN"
      env = Chef::Recipe::ZZDeploy.env
      amazon = env.amazon
      puts amazon
      # The Node is available as +node+
      message = "Chef run completed on #{node.name}\n"
      if failed?
        # +run_status+ is a value object with all of the run status data
        message << "#{run_status.formatted_exception}\n"
        # Join the backtrace lines. Coerce to an array just in case.
        message << Array(backtrace).join("\n")
      end
      puts message
    end
  end
end