class DashboardsController < ApplicationController
  def index
    if current_user
      if current_user.role == 'dispatcher'
        redirect_to dispatcher_url
      elsif current_user.role == 'driver'
        redirect_to driver_url
      end
    else
      redirect_to login_url
    end
  end

  def dispatcher
    @dates = Order.order(:delivery_date).select(:delivery_date).distinct.pluck(:delivery_date)
    @completed_dates = Load.where(completed: true).group(:delivery_date).having('COUNT(*) = 3').pluck(:delivery_date)
    @uncompleted_dates = @dates - @completed_dates
  end

  def driver
    @dates = Load.where(completed: true).order(:delivery_date).select(:delivery_date).distinct.pluck(:delivery_date)
  end

end
