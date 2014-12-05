#!/usr/bin/env ruby
require "bundler"
Bundler.setup
require_relative "../lib/dyn_dns_r"
require "optparse"
default_opts = DynDnsR.options
shortopts = []
OptionParser.new do |opts|
  opts.banner
  opts.separator ""
  default_opts.each_option do |(key, value)|
    shortopt = key.to_s[0,1]
    if !shortopts.include? shortopt
      opts.on("-#{shortopt}", "--#{key} #{key.upcase}", ("%s (Default: '%s')" % [value[:doc], value[:value]])) { |val| DynDnsR.options[key] = val }
      shortopts << shortopt
    else
      opts.on("--#{key} #{key.to_s.upcase}", ("%s (Default: '%s')" % [value[:doc], value[:value]])) { |val| DynDnsR.options[key] = val }
    end
  end
  opts.separator ""
  opts.on("--help", "Show this help") { |h| puts opts; exit }
end.parse!(ARGV)
