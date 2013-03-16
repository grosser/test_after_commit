# setup database
require 'active_record'

if ActiveRecord::VERSION::MAJOR > 3
  require "rails/observers/activerecord/active_record"
end

ActiveRecord::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database => ':memory:'
)

ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define(:version => 1) do
  create_table "cars", :force => true do |t|
    t.integer :counter, :default => 0, :null => false
    t.timestamps
  end
end

class Car < ActiveRecord::Base
  after_commit :simple_after_commit
  after_commit :simple_after_commit_on_create, :on => :create
  after_commit :save_once, :on => :create, :if => :do_after_create_save
  after_commit :simple_after_commit_on_update, :on => :update
  after_commit :maybe_raise_errors

  after_save :trigger_rollback

  attr_accessor :make_rollback, :raise_error, :do_after_create_save

  def self.called(x=nil)
    @called ||= []
    if x
      @called << x
    else
      @called
    end
  end

  def trigger_rollback
    raise ActiveRecord::Rollback if make_rollback
  end

  private

  def save_once
    update_attributes(:counter => 3) unless counter == 3
    self.class.called :save_once
  end

  def maybe_raise_errors
    if raise_error
      # puts "MAYBE RAISE" # just debugging, but it really does not work ...
      raise "Expected error"
    end
  end

  def simple_after_commit
    self.class.called :always
  end

  def simple_after_commit_on_create
    self.class.called :create
  end

  def simple_after_commit_on_update
    self.class.called :update
  end
end

class CarObserver < ActiveRecord::Observer
  cattr_accessor :recording

  [:after_commit, :after_rollback].each do |action|
    define_method action do |record|
      return unless recording
      Car.called << :observed_after_commit
    end
  end
end

Car.observers = :car_observer
Car.instantiate_observers
