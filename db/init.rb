require_relative '../lib/dyn_dns_r'
require 'sequel'
module DynDnsR
  L 'log'
  L 'db'
  unless ::Object.const_defined?('DB')
    log.info "Setting DB to #{name}.db"
    ::DB = db
  end
end
