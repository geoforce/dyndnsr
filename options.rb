require "innate"

module DynDnsR
  include Innate::Optioned

  options.dsl do
    o "Database", :db, ENV["DynDnsR_DB"] || "postgres://dyndnser:foo@localhost/dyndnser"

    o "Logfile", :logfile, ENV["DynDnsR_LOG"] || $stdout

    o "Log Level", :log_level, ENV["DynDnsR_LogLevel"] || Logger::INFO
  end

end

