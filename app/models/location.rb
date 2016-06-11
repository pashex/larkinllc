class Location < ActiveRecord::Base
  ZIP_FORMAT = /\A\d{5}(\-\d{4})?\Z/
  validates :name, :address, :city, :state, :country, :zip, presence: true
  validates :zip, format: { with: ZIP_FORMAT, message: :invalid_format }

  def info
    [name, address, city, state, country, zip].join(", ")
  end
end
