desc 'Run all bacon specs with TAP output'
task :tap do
  ENV['DynDnsR_ENV'] = 'test'
  load File.expand_path(File.join(File.dirname(__FILE__), '../options.rb'))
  DynDnsR.reoption
  require 'open3'
  require 'scanf'
  require 'matrix'
  require 'fileutils'

  specs = PROJECT_SPECS

  if specs.size == 0
    $stderr.puts 'You have no specs!  Put a spec in spec/ before running this task'
    exit 1
  end

  Rake::Task['db:migrate'].invoke
  bacon_cmd = "bacon -o Tap #{specs.join(' ')}"
  val = nil
  Open3.popen3(bacon_cmd) do |_sin, sout, serr, thr|
    out = Thread.new do
      sout.each_line do |o|
        puts o.chomp
        $stdout.flush
      end
    end
    err = Thread.new do
      serr.each_line do |e|
        $stderr.puts e.chome
        $stderr.flush
      end
    end
    out.join
    err.join
    val = thr.value
  end
  exit val.exitstatus
end
