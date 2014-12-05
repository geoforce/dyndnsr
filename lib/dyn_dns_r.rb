require 'pathname'
require 'logger'

# Allows for pathnames to be easily added to
class Pathname
  def /(other)
    join(other.to_s)
  end
end

# A simple DYNDNS framework build on djbdns and roda
# This sets all the globals and creates our main namespace
module DynDnsR
  LIBROOT = Pathname(__FILE__).dirname.expand_path
  ROOT = LIBROOT / '..'
  MIGRATION_ROOT = ROOT / 'db/migrate'
  TOPLEVEL = ROOT / 'data/DYNDNS'
  MODEL_ROOT = ROOT / :model
  SPEC_HELPER_PATH = ROOT / :spec
  autoload :VERSION, (LIBROOT / 'dyn_dns_r/version').to_s

  class << self
    # rubocop:disable Style/MethodName
    # We want some UPCASE methods here
    #
    # Helper method to load models
    # @model String The model you wish to load
    def M(model)
      require MODEL_ROOT.join(model).to_s
    end

    # Helper method to load files from ROOT
    # @file String The file you wish to load
    def R(file)
      require ROOT.join(file).to_s
    end

    # Helper method to load files from lib/dyn_dns_r/
    # @file String The file you wish to load
    def L(file)
      require((LIBROOT / :dyn_dns_r).join(file).to_s)
    end

    # Attempt to change options
    def reoption
      options[:db] = nil
      options[:db_log] = nil
      options[:env] = nil
      load((ROOT / 'options.rb').to_s)
    end

    def env
      options.env
    end

    def env=(other)
      ENV['DynDnsR_ENV'] = other
      reoption
    end

    def Run(*args) # rubocop:disable Metrics/MethodLength
      require 'open3'
      Open3.popen3(*args) do |sin, sout, serr|
        o = Thread.new do
          sout.each_line { |l| puts l.chomp }
        end
        e = Thread.new do
          serr.each_line { |l| $stderr.puts l.chomp }
        end
        sin.close
        o.join
        e.join
      end
    end
    # rubocop:enable Style/MethodName
    # resume caring about method names

    def log_location(other) # rubocop:disable Metrics/MethodLength
      if other.is_a?(String)
        case other
        when /STDOUT/i # Special case for STDOUT
          STDOUT
        when /^\// # If we have a leading slash, return it as given
          other
        else # Otherwise prepend ROOT
          ROOT.join(other).to_s
        end
      else # We didn't get a string, assuming an IO/Stream object
        other
      end
    end

    def make_data
      require 'fileutils'
      FileUtils.rm_rf TOPLEVEL
      R 'db/models'
      A.each { |a| a.write! true }
      Equal.each { |e| e.write! true }
      Run((ROOT / 'bin/tinydns-data.sh').to_s)
    end
  end
end
Dir[DynDnsR::LIBROOT.join('core_ext', '*.rb').to_s].each { |f| require f }
DynDnsR::R 'options'
opt = DynDnsR.options
DynDnsR::Log = Logger.new(opt.logfile,
                          opt.max_log_files,
                          opt.max_log_size) unless DynDnsR.const_defined?('Log')
DynDnsR::Log.level = DynDnsR.options.log_level
