# patch deploy code to not create current link
# since we control that ourselves in app restart phase
class Chef
  class Provider
    class Deploy < Chef::Provider
      def link_current_release_to_production
        puts "***** LINKING NOTHING *****"
      end
    end
  end
end

