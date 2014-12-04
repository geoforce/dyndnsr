require "pathname"
require "logger"

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
  ROOT = LIBROOT/".."
  MIGRATION_ROOT = ROOT/:migrations
  TOPLEVEL = ROOT/:DYNDNS
  MODEL_ROOT = ROOT/:model
  SPEC_HELPER_PATH = ROOT/:spec
  autoload :VERSION, (LIBROOT/"dyn_dns_r/version").to_s
  # Helper method to load models
  # @model String The model you wish to load
  def self.M(model)
    require DynDnsR::MODEL_ROOT.join(model).to_s
  end

  # Helper method to load files from ROOT
  # @file String The file you wish to load
  def self.R(file)
    require DynDnsR::ROOT.join(file).to_s
  end

  # Helper method to load files from lib/yrb
  # @file String The file you wish to load
  def self.L(file)
    require (DynDnsR::LIBROOT/:dyn_dns_r).join(file).to_s
  end

  def self.Run(*args)
    require "open3"
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

  def self.log_location(other)
    if other.is_a?(String)
      # We got a pathname
      case other
      when /STDOUT/i # Special case for STDOUT
        STDOUT
      when %r{^/} # If we have a leading slash, return it as given
        other
      else # Otherwise prepend ROOT
        ROOT.join(other).to_s
      end
    else # We didn't get a string, assuming an IO object or something that can accept text streams
      other
    end
  end

end
DynDnsR::R "options"
DynDnsR::Log = Logger.new(DynDnsR.options.logfile, 10, 10240000) unless DynDnsR.const_defined?("Log")
DynDnsR::Log.level = DynDnsR.options.log_level

