class LoadsController < ApplicationController
  def create
    date = Date.parse(params[:date])
    @loads = ['morning', 'noon', 'evening'].map do |shift|
       Load.new(delivery_date: date, shift: shift)
    end
    flash[:errors] = @loads.flat_map(&:errors) unless @loads.each(&:save).all?
    redirect_to orders_url(date: params[:date])
  end
end
