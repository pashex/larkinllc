class Location < ActiveRecord::Base
  validates :name, :address, :city, :state, :country, :zip, presence: true

  def info
    [name, address, city, state, country, zip].join(", ")
  end
end
