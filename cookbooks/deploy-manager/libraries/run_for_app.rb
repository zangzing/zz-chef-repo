class Chef
  class Recipe
    # run for a given app only if the specified
    # role map matches the role
    def run_for_app(*apps, &block)
      the_app = node[:zz][:app_name]
      the_role = node[:zz][:deploy_role]
      rails_env = node[:zz][:group_config][:rails_env]
      apps.each do |app|
        app.each do |name, roles|
          app_name = name.to_s
          if app_name == the_app
            roles.map! {|a| a.to_s }
            if roles.include?(the_role)
                block.call(the_app.to_sym, the_role.to_sym, rails_env.to_sym)
            end
          end
        end
      end
    end

    # this form takes the list of apps but runs
    # in all roles
    def run_for_app_all_roles(*apps, &block)
      the_app = node[:zz][:app_name]
      the_role = node[:zz][:deploy_role]
      rails_env = node[:zz][:group_config][:rails_env]
      apps.each do |app|
        app_name = app.to_s
        if app_name == the_app
          block.call(the_app.to_sym, the_role.to_sym, rails_env.to_sym)
        end
      end
    end

    # this form runs for all apps and all roles
    def run_for_all(&block)
      the_app = node[:zz][:app_name]
      the_role = node[:zz][:deploy_role]
      rails_env = node[:zz][:group_config][:rails_env]
      block.call(the_app.to_sym, the_role.to_sym, rails_env.to_sym)
    end

  end
end

class ZZChefUtils
  # load and run external ruby code within our current context
  # returns true if was able to load false otherwise
  def self.run_external_code(dir, file, required)
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

# call like this
#run_for_app(:photos => [:solo,:util,:local], :rollup => [:solo, :app, :local]) do |app_name, role, rails_env|
#  puts app_name, role
#end