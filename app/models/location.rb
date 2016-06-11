class Location < ActiveRecord::Base
  validates :name, :address, :city, :state, :country, :zip, presence: true
  validates :zip, format: { with: /\A\d{5}(\-\d{4})?\Z/, message: :invalid_format }

  def info
    [name, address, city, state, country, zip].join(", ")
  end
end
