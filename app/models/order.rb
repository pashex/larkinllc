class Order < ActiveRecord::Base
  belongs_to :origin, class_name: 'Location'
  belongs_to :destination, class_name: 'Location'
  belongs_to :load
  acts_as_list scope: :load
  counter_culture :load,
    column_name: Proc.new {|order| order.reverse? ? :reverse_volume : :volume },
    delta_column: :volume

  counter_culture :load,
    column_name: Proc.new {|order| order.reverse? ? :reverse_quantity : :quantity },
    delta_column: :quantity

  validates :origin, :destination, presence: true
  validate :check_difference_of_locations
  validate :check_load_delivery_date, if: :load
  validate :check_load_shift, if: :load
  validate :check_load_volume, if: :load

  enum shift: { not_specified: 0, morning: 1, noon: 2, evening: 3 }

  scope :shifted, -> { where.not(shift: 0) }
  scope :by_date, -> (date_str) { where(delivery_date: (Date.parse(date_str) rescue nil)) }

  private

  def check_difference_of_locations
    if origin == destination
      errors.add :destination, :same
    end
  end

  def check_load_delivery_date
    if delivery_date && delivery_date != load.delivery_date
      errors.add :load, :invalid_delivery_date
    end
  end

  def check_load_shift
    unless shift == 'not_specified' || shift == load.shift
      errors.add :load, :invalid_shift
    end
  end

  def check_load_volume
    if (reverse? ? volume + load.reverse_volume : volume + load.volume) > Load::MAX_VOLUME
      errors.add :load, :max_volume_exceeded
    end
  end
end
