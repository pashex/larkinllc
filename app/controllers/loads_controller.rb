class LoadsController < ApplicationController
  def create
    date = Date.parse(params[:date]) rescue nil
    @loads = ['morning', 'noon', 'evening'].map do |shift|
       Load.new(delivery_date: date, shift: shift)
    end
    flash[:errors] = @loads.flat_map {|l| l.errors.full_messages}.uniq unless @loads.map(&:save).all?
    redirect_to orders_url(date: params[:date])
  end
end
