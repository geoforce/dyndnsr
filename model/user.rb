module DynDnsR
  User = Class.new(Sequel::Model)
  class User
    set_dataset :users
  end
end
