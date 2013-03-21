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

  it "does not fire multiple times in nested transactions" do
    Car.transaction do
      Car.transaction do
        Car.create!
        Car.called.should == []
      end
      Car.called.should == []
    end
    Car.called.should == [:create, :always]
  end

  it "does not raises errors" do
    car = Car.new
    car.raise_error = true
    car.save!
  end

  it "can do 1 save in after_commit" do
    if !ENV['REAL']
      pending "this results in infinite loop in REAL mode except on 4.0 but works in tests except for rails 3.0"
    end

    car = Car.new
    car.do_after_create_save = true
    car.save!

    expected = if ActiveRecord::VERSION::MAJOR >= 4
      [:update, :always, :save_once, :always] # some kind of loop prevention ... investigate we must
    else
      [:save_once, :create, :always, :save_once, :create, :always]
    end
    Car.called.should == expected
    car.counter.should == 3
  end

  it "returns on create and on create of associations" do
    Car.create!.class.should == Car
    Car.create!.cars.create.class.should == Car
  end

  it "returns on create and on create of associations without after_commit" do
    Bar.create!.class.should == Bar
    Bar.create!.bars.create.class.should == Bar
  end

  context "Observer" do
    before do
      CarObserver.recording = true
    end

    it "should record commits" do
      Car.transaction do
        Car.create
      end
      Car.called.should == [:observed_after_commit, :create, :always]
    end
  end
end
