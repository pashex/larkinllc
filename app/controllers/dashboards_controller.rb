class DashboardsController < ApplicationController
  def dispatcher
    @dates = Order.order(:delivery_date).select(:delivery_date).distinct.pluck(:delivery_date)
  end
end
