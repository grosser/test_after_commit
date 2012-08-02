require 'spec_helper'

describe TestAfterCommit do
  it "has a VERSION" do
    TestAfterCommit::VERSION.should =~ /^[\.\da-z]+$/
  end
end
