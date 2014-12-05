require 'innate'

# Main namespace for dyndnser
module DynDnsR
  @default_options = { db: 'postgres://dyndnser:foo@localhost/dyndnser',
                       log_level: Logger::INFO,
                       env: 'development',
                       db_log: nil,
                       max_log_files: 10,
                       max_log_size: 10_240_000,
                       logfile: $stdout }

  class << self
    attr_reader :default_options
  end

  def self.loaded_options
    config_options = begin
                       JSON.load(File.read(File.join(best_config_path,
                                                     best_config_filename)))
                     rescue
                       {}
                     end
    @default_options.merge(config_options.symbolize_keys)
  end

  # rubocop:disable Metrics/LineLength
  # disable line length linting because multiline || chaining is worse than long lines
  def self.best_config_path
    return ENV['DynDnsR_APP_ROOT'] unless ENV['DynDnsR_APP_ROOT'].nil? || ENV['DynDnsR_APP_ROOT'] == ''
    if File.exist?(File.join(Dir.pwd, best_config_filename))
      Dir.pwd
    else
      File.dirname(__FILE__)
    end
  end

  def self.best_config_filename
    "config/#{ENV['DynDnsR_ENV'] || @default_options[:env]}.json"
  end

  include Innate::Optioned

  options.dsl do
    loaded_options = DynDnsR.loaded_options
    o 'Environment', :env, DynDnsR.options.env || ENV['DynDnsR_ENV'] || loaded_options[:env]

    o 'Database', :db, DynDnsR.options.db || ENV['DynDnsR_DB'] || loaded_options[:db]

    o 'Database Log', :db_log, DynDnsR.options.db_log || ENV['DynDnsR_DB_LOG'] || loaded_options[:db_log] || STDOUT

    o 'Logfile', :logfile, DynDnsR.options.logfile || ENV['DynDnsR_LOG'] || loaded_options[:logfile]

    o 'Log Level', :log_level, DynDnsR.options.log_level || ENV['DynDnsR_LogLevel'] || loaded_options[:log_level]

    o 'Maximum Log Size', :max_log_size, DynDnsR.options.max_log_size || ENV['DynDnsR_MaxLogSize'] || DynDnsR.loaded_options[:max_log_size]

    o 'Maximum Log Files', :max_log_files, DynDnsR.options.max_log_files || ENV['DynDnsR_MaxLogFiles'] || DynDnsR.loaded_options[:max_log_files]
  end
end
