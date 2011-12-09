#!/usr/bin/env ruby

require 'optparse'
require 'timeout'

# handy util commands for server side
class ZZUtilsCommands
  VERSION             = '0.1'
  COMMANDS            = %w(stop)

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
      :timeout                 => 5,
      :signal                  => 'QUIT',
    }

    parse!
  end

  def parser
    # NOTE: If you add an option here make sure the key in the +options+ hash is the
    # same as the name of the command line option.
    # +option+ keys are used to build the command line to launch other processes,
    # see <tt>lib/thin/command.rb</tt>.
    @parser ||= OptionParser.new do |opts|
      opts.banner = "Usage: zz_cmds.rb [options] #{self.class.commands.join('|')}"

      opts.separator ""
      opts.separator "Options:"

      opts.on("-p", "--pid_file PIDFILE", "required PIDFILE to use, removed when complete ")    { |val| @options[:pid_file] = val }
      opts.on("-s", "--signal SIGNAL", "signal to use for nice kill stage " +
                                      "(default: #{@options[:signal]})")                        { |val| @options[:signal] = val }
      opts.on("-t", "--timeout TIMEOUT", "time in seconds before forced kill " +
                                      "(default: #{@options[:timeout]})")                       { |val| @options[:timeout] = val.to_i }
      opts.on_tail('-v', '--version', "Show version")                                           { puts VERSION; exit }
    end
  end

  # Parse the options.
  def parse!
    parser.parse! @argv
    @command   = @argv.shift
    @arguments = @argv
  end

  # read the pid file
  # return the pid or nil
  def read_pid_file(file)
    pid = File.read(file).to_i rescue nil
  end

  def remove_pid_file(file)
    File.delete(file) rescue nil
  end

  # stolen from daemons gem
  # we want this file standalone so don't
  # want any non standard dependencies
  def process_running?(pid)
    return false unless pid

    # Check if process is in existence
    # The simplest way to do this is to send signal '0'
    # (which is a single system call) that doesn't actually
    # send a signal
    begin
      Process.kill(0, pid)
      return true
    rescue Errno::ESRCH
      return false
    rescue ::Exception   # for example on EPERM (process exists but does not belong to us)
      return true
    #rescue Errno::EPERM
    #  return false
    end
  end

  def send_signal(signal, pid, timeout=60)
    puts "Sending #{signal} signal to process #{pid} ... "
    Process.kill(signal, pid)
    Timeout.timeout(timeout) do
      sleep 0.1 while process_running?(pid)
    end
  rescue Exception => ex
    puts ex.message
  end

  def stop
    pid_file = @options[:pid_file]
    signal = @options[:signal]
    timeout = @options[:timeout]
    pid = read_pid_file(pid_file)
    if pid
      send_signal(signal, pid, timeout)
      # if still running after nice attempt, kill immediately
      send_signal('KILL', pid, timeout) if process_running?(pid)
      remove_pid_file(pid_file)
    end
  end

  def run_command
    case command
      when 'stop'
        stop
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

ZZUtilsCommands.new(ARGV).run!