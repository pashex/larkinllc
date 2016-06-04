class Location < ActiveRecord::Base
  validates :name, :address, :city, :state, :country, :zip, presence: true
end
