class Load < ActiveRecord::Base
  MAX_VOLUME = 1400.0
  BASE_DATE =

  has_many :orders
  enum shift: { morning: 1, noon: 2, evening: 3 }

  validates :delivery_date, presence: true
  validates :shift, uniqueness: { scope: :delivery_date }

  validate :check_orders_delivery_date
  validate :check_orders_shift
  validate :check_reverse_orders_position

  scope :by_date, -> (date) { where(delivery_date: date) }

  def self.for_truck_and_date(truck_number, date)
    shifts = ((date - Date.parse('2014-01-01')).to_i + truck_number).odd? ? [1, 3] : [2]
    self.where(delivery_date: date, shift: shifts)
  end

  private

  def check_orders_delivery_date
    unless orders.pluck(:delivery_date).compact.all? { |order_date| order_date == delivery_date }
      errors.add :orders, :invalid_delivery_date
    end
  end

  def check_orders_shift
    unless orders.map(&:shift).all? { |order_shift| order_shift == 'not_specified' || order_shift == shift }
      errors.add :orders, :invalid_shift
    end
  end

  def check_reverse_orders_position
    first_reverse_order = orders.where(reverse: true).order(:position).first
    return true unless first_reverse_order
    after_orders = orders.where('position > ?', first_reverse_order.position)
    if after_orders.where(reverse: false).any?
      errors.add :orders, :invalid_reverse_positions
    end
  end

end
