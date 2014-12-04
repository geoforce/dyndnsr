require "pathname"
begin
  require "bacon"
rescue LoadError
  require "rubygems"
  require "bacon"
end

begin
  if (local_path = Pathname.new(__FILE__).dirname.join("..", "lib", "dyn_dns_r.rb")).file?
    require local_path
  else
    require "dyn_dns_r"
  end
rescue LoadError
  require "rubygems"
  require "dyn_dns_r"
end

Bacon.summary_on_exit

describe "Spec Helper" do
  it "Should bring our library namespace in" do
    DynDnsR.should == DynDnsR
  end
end


