require 'bluepill'
FileUtils.mkdir_p 'log'

Simplvisor::WATCHES = []

def watch cmdline, options = {}
  Simplvisor::WATCHES << [cmdline, options]
end

at_exit do
  Bluepill.application(ARGV[0] || 'app',
    :log_file => 'log/bluepill.log',
    :base_dir => '.',
    :foreground => true
  ) do |app|
    Simplvisor::WATCHES.each do |cmdline, options|
      name = options[:name] || cmdline.split.first
      app.process(name) do |x|
        x.start_command = cmdline
        x.pid_file      = options[:pid] || "log/#{name}.pid"
        x.daemonize     = true unless options[:reckless]
        x.stdout        = "log/#{name}-out.log"
        x.stderr        = "log/#{name}-err.log"
      end
    end
  end
end
