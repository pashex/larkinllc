class LoadsController < ApplicationController
  before_action :parse_date

  def create
    @loads = ['morning', 'noon', 'evening'].map do |shift|
       Load.new(delivery_date: @date, shift: shift)
    end
    flash[:errors] = @loads.flat_map {|l| l.errors.full_messages}.uniq unless @loads.map(&:save).all?
    redirect_to orders_url(date: @date)
  end

  def complete
    @load = Load.find(params[:id])
    unless @load.update(completed: true)
      flash[:errors] = @load.errors.full_messages
     end
    redirect_to orders_url(date: @date)
  end

  private

  def parse_date
    @date = Date.parse(params[:date]) rescue nil
  end

end
