require 'spec_helper'

describe TestAfterCommit do
  before do
    CarObserver.recording = false
    Car.called.clear
  end

  it "has a VERSION" do
    TestAfterCommit::VERSION.should =~ /^[\.\da-z]+$/
  end

  it "fires on create" do
    Car.create
    Car.called.should == [:create, :always]
  end

  it "fires on update" do
    car = Car.create
    Car.called.clear
    car.save!
    Car.called.should == [:update, :always]
  end

  it "does not fire on rollback" do
    car = Car.new
    car.make_rollback = true
    car.save.should == nil
    Car.called.should == []
  end

  it "raises errors" do
    car = Car.new
    car.raise_error = true
    pending do
      expect{
        car.save!
      }.to raise_error "Expected error"
    end
  end

  it "can save in after_commit" do
    pending "this does not work in REAL mode but in tests except for rails 3.0"
    car = Car.new
    car.do_after_create_save = true
    car.save!
    Car.called.should == [:save_once, :create, :always]
    car.counter.should == 3
  end

  context "Observer" do
    before do
      CarObserver.recording = true
    end

    it "should record commits" do
      Car.transaction do
        Car.create
      end
      pending do
        Car.called.should == [:update, :observed_after_commit, :always]
      end
    end
  end
end
