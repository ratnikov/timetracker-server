class Event < ActiveRecord::Base
  attr_accessible :ended_at, :name, :started_at

  validates_presence_of :name
end
