class LoadsController < ApplicationController
  before_action :parse_date
  before_action :find_load, only: [:complete]

  def index
    @loads = Load.for_truck_and_date(current_user.truck_number, @date).order(:shift).includes(orders: [:origin, :destination]).where(completed: true)
  end

  def create
    @loads = ['morning', 'noon', 'evening'].map do |shift|
       Load.new(delivery_date: @date, shift: shift)
    end
    flash[:danger] = @loads.flat_map {|l| l.errors.full_messages}.uniq unless @loads.map(&:save).all?
    redirect_to orders_url(date: @date)
  end

  def complete
    unless @load.update(completed: true)
      flash[:danger] = @load.errors.full_messages
     end
    redirect_to orders_url(date: @date)
  end

  def export
    @load = Load.where(completed: true).find(params[:id])
  end

  private

  def parse_date
    @date = Date.parse(params[:date]) rescue nil
  end

  def find_load
    @load = Load.find(params[:id])
  end
end
