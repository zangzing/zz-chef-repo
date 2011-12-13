#!/usr/bin/env ruby
# tag the current code and then upload and bake on each of the given config groups
#

require 'optparse'
require 'timeout'

# handy util commands for server side
class ChefDeploy
  VERSION             = '0.1'
  COMMANDS            = %w(deploy)

  # Parsed options
  attr_accessor :options

  # Name of the command to be runned.
  attr_accessor :command

  # Arguments to be passed to the command.
  attr_accessor :arguments

  # Return all available commands
  def self.commands
    COMMANDS
  end

  def initialize(argv)
    @argv = argv

    # Default options values
    @options = {
      :groups                  => nil,
      :tag                     => nil,
      :create                  => false,
      :upload                  => false,
      :deploy                  => false,
    }

    parse!
    validate
  end

  def parser
    # NOTE: If you add an option here make sure the key in the +options+ hash is the
    # same as the name of the command line option.
    # +option+ keys are used to build the command line to launch other processes,
    # see <tt>lib/thin/command.rb</tt>.
    @parser ||= OptionParser.new do |opts|
      opts.banner = "Usage: chef_deploy.rb [options] #{self.class.commands.join('|')}"

      opts.separator ""
      opts.separator "Options:"

      opts.on("-t", "--tag TAG", "required: Tag")                                       { |val| @options[:tag] = val }
      opts.on("-c", "--create", "create this tag")                                      { |val| @options[:create] = true }
      opts.on("-u", "--upload", "upload this tag")                                      { |val| @options[:upload] = true }
      opts.on("-d", "--deploy", "deploy (chef_bake) this tag implies upload also")      { |val| @options[:upload] = true; @options[:deploy] = true }
      opts.on("-g", "--groups group1,group2,etc", Array, "required if upload or deploy: groups to deploy")           { |val| @options[:groups] = val }
      opts.on_tail('-v', '--version', "Show version")                                   { puts VERSION; exit }
    end
  end

  def validate
    non_nil = [:tag]
    non_nil << :groups if @options[:upload] || @options[:deploy]
    non_nil.each do |option|
      if @options[option].nil?
        puts "Missing required option: #{option}"
        exit
      end
    end
  end

  # Parse the options.
  def parse!
    parser.parse! @argv
    @command   = @argv.shift
    @arguments = @argv
  end

  def do_cmd(cmd, exit_on_error = false)
    puts cmd
    Kernel.system(cmd)
    exit! if exit_on_error && $?.exitstatus != 0
  end

  # do the tag and deploy
  def do_deploy
    tag = @options[:tag]
    groups = @options[:groups]
    upload = @options[:upload]
    deploy = @options[:deploy]
    create = @options[:create]
    if create
      do_cmd("git tag #{tag}", true)
      do_cmd("git push origin #{tag}", true)
    end
    if upload
      groups.each do |group|
        # upload to all first
        do_cmd("zz chef_upload -g #{group} -t #{tag}", true)
      end
    end
    if deploy
      groups.each do |group|
        # upload to all first
        do_cmd("zz chef_bake -g #{group}", true)
      end
    end
  end

  def run_command
    case command
      when 'deploy'
        do_deploy
    end
  end

  # Parse the current shell arguments and run the command.
  # Exits on error.
  def run!
    if self.class.commands.include?(@command)
      run_command
    elsif @command.nil?
      puts "Command required"
      puts @parser
      exit 1
    else
      abort "Unknown command: #{@command}. Use one of #{self.class.commands.join(', ')}"
    end
  end
end

ChefDeploy.new(ARGV).run!

# sample command:
# ./chef_deploy.rb tag -g photos_greg,photos_jeremy -d -t 2011-12-12-02
# above tags and deploys to given groups