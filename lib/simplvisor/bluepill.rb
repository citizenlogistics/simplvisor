require 'bluepill'
FileUtils.mkdir_p 'log'

module Simplvisor
  WATCHES = []
  PWD     = ENV['PWD']

  def self.run_bluepill
    Bluepill.application(ARGV[0] || 'app',
      :log_file => "#{PWD}/log/bluepill.log",
      :base_dir => '/tmp',
      :foreground => true
    ) do |app|
      WATCHES.each do |cmdline, options|
        name = options[:name] || File.basename(cmdline.split.first)
        app.process(name) do |x|
          x.working_dir   = PWD
          x.start_command = cmdline
          x.pid_file      = options[:pid] || "#{PWD}/log/#{name}.pid"
          x.daemonize     = true unless options[:reckless]
          x.stdout        = "#{PWD}/log/#{name}-out.log"
          x.stderr        = "#{PWD}/log/#{name}-err.log"
        end
      end
    end
  end
end

def watch cmdline, options = {}
  Simplvisor::WATCHES << [cmdline, options]
end

at_exit{ Simplvisor.run_bluepill }
