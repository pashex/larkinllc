class Load < ActiveRecord::Base
  MAX_VOLUME = 1400.0

  has_many :orders
  enum shift: { morning: 1, noon: 2, evening: 3 }

  validates :delivery_date, presence: true
  validates :shift, uniqueness: { scope: :delivery_date }

  validate :check_orders_delivery_date
  validate :check_orders_shift

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

end
