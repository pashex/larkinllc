class DashboardsController < ApplicationController
  def dispatcher
    @dates = Order.order(:delivery_date).select(:delivery_date).distinct.pluck(:delivery_date)
  end

  def driver
    @dates = Load.where(completed: true).order(:delivery_date).select(:delivery_date).distinct.pluck(:delivery_date)
  end

end
