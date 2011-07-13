class Chef
  module Mixin
    module ZZUtils


      # load and run external ruby code within our current context
      # returns true if was able to load false otherwise
      def run_external_code(dir, file, required)
        full_path = "#{dir}/#{file}"
        ruby_code = File.open(full_path, 'r') {|f| f.read } rescue ruby_code = nil
        if !ruby_code.nil?
          begin
            Chef::Log.info("ZangZing=> Running application hook #{file}")
            instance_eval(ruby_code, full_path)
          rescue Exception => ex
            Chef::Log.error("ZangZing=> Exception while running application hook #{file}")
            Chef::Log.error(ex.message)
            raise ex
          end
          return true
        else
          raise "Required hook code for #{full_path} was not found." if required
          return false
        end
      end

    end
  end
end
