class DashboardsController < ApplicationController
  def dispatcher
    @dates = Order.order(:delivery_date).select(:delivery_date).distinct.pluck(:delivery_date)
    @completed_dates = Load.where(completed: true).group(:delivery_date).having('COUNT(*) = 3').pluck(:delivery_date)
    @uncompleted_dates = @dates - @completed_dates
  end

  def driver
    @dates = Load.where(completed: true).order(:delivery_date).select(:delivery_date).distinct.pluck(:delivery_date)
  end

end
