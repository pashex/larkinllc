class Order < ActiveRecord::Base
  belongs_to :origin, class_name: 'Location'
  belongs_to :destination, class_name: 'Location'

  validates :origin, :destination, presence: true
  validate :check_difference_of_locations

  enum shift: { not_specified: 0, morning: 1, noon: 2, evening: 3 }

  private

  def check_difference_of_locations
    if origin == destination
      errors.add :destination, :same
    end
  end
end
