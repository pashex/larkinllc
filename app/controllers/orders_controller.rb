class OrdersController < ApplicationController
  before_action :parse_date
  before_action :find_order, only: [:show, :edit, :update, :shift, :destroy]

  def index
    @loads = Load.by_date(@date).order(:shift).includes(orders: [:origin, :destination])
    @loads_present = !@loads.empty?
    orders = Order.where(load: nil).by_date(@date).includes(:origin, :destination)
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
    redirect_to orders_url(date: @order.delivery_date)
  end

  def shift
    if params[:reverse]
      @order.move_higher
    else
      @order.move_lower
    end
    redirect_to orders_url(date: @date)
  end

  def destroy
  end

  def import
    flash[:errors] = OrderParser.perform(params[:file], strategy: params[:strategy])
    flash[:errors] << I18n.t('.errors_in_csv') unless flash[:errors].empty?
    redirect_to dispatcher_url
  end

  private

  def parse_date
    @date = Date.parse(params[:date]) rescue nil
  end

  def find_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:load_id, :delivery_date, :shift, :number)
  end

end
