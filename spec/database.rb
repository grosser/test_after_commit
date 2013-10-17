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
    t.integer :car_id
    t.timestamps
  end

  create_table "addresses", :force => true do |t|
    t.integer :number_of_residents, :default => 0, :null => false
    t.timestamps
  end

  create_table "people", :force => true do |t|
    t.belongs_to :address
    t.timestamps
  end
end

module Called
  def called(x=nil)
    @called ||= []
    if x
      @called << x
    else
      @called
    end
  end
end

class Car < ActiveRecord::Base
  extend Called

  has_many :cars

  after_commit :simple_after_commit
  after_commit :simple_after_commit_on_create, :on => :create
  after_commit :save_once, :on => :create, :if => :do_after_create_save
  after_commit :simple_after_commit_on_update, :on => :update
  after_commit :maybe_raise_errors

  after_save :trigger_rollback

  attr_accessor :make_rollback, :raise_error, :do_after_create_save

  def trigger_rollback
    raise ActiveRecord::Rollback if make_rollback
  end

  def self.returning_method_with_transaction
    Car.transaction do
      return Car.create
    end
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

class Bar < ActiveRecord::Base
  self.table_name = "cars"
  has_many :bars, :foreign_key => :car_id
end

class MultiBar < ActiveRecord::Base
  extend Called

  self.table_name = "cars"

  after_commit :one, :on => :create
  after_commit :two, :on => :create

  def one
    self.class.called << :one
  end

  def two
    self.class.called << :two
  end
end

class Address < ActiveRecord::Base
  has_many :people

  after_commit :create_residents, :on => :create

  def create_residents
    if ActiveRecord::VERSION::MAJOR == 3
      # stupid hack because nested after_commit is broken on rails 3 and loops
      return if @create_residents
      @create_residents = true
    end

    Person.create!(:address => self)
    Person.create!(:address => self)
  end
end

class Person < ActiveRecord::Base
  belongs_to :address

  after_commit :update_number_of_residents_on_address, :on => :create

  def update_number_of_residents_on_address
    address.update_attributes(:number_of_residents => address.number_of_residents + 1)
  end
end
