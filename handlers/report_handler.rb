module ZZ
  class ReportHandler < Chef::Handler

    def initialize(a,b)
      puts "MAKING ReportHandler - #{a} - #{b}"
    end

    def report
      puts "REPORT HANDLER RUN"
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