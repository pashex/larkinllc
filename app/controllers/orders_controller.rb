class OrdersController < ApplicationController
  before_action :find_order, only: [:show, :edit, :update, :shift, :destroy]

  def index
    @loads = Load.by_date(params[:date]).order(:shift).includes(orders: [:origin, :destination])
    @loads_present = !@loads.empty?
    orders = Order.where(load: nil).by_date(params[:date]).includes(:origin, :destination)
    @shifted_orders = orders.shifted.order(:shift, volume: :desc)
    @not_shifted_orders = orders.not_specified.order(volume: :desc)
  end

  def show
  end

  def edit
  end

  def update
    unless @order.update(order_params)
      flash[:errors] = @order.errors.full_messages
    end
    redirect_to orders_url(date: params[:date])
  end

  def shift
    if params[:reverse]
      @order.move_higher
    else
      @order.move_lower
    end
    redirect_to orders_url(date: params[:date])
  end

  def destroy
  end

  def import
    flash[:errors] = OrderParser.perform(params[:file])
    redirect_to dispatcher_dashboards_url
  end

  private

  def find_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:load_id, :delivery_date, :shift)
  end
end
