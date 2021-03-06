class OrdersController < ApplicationController
  before_action :parse_date
  before_action :find_order, only: [:show, :edit, :update, :shift, :split, :destroy]

  def index
    @loads = Load.by_date(@date).order(:shift).includes(orders: [:origin, :destination])
    @loads_present = !@loads.empty?
    orders = Order.where(load: nil).by_date(@date).includes(:origin, :destination)
    @shifted_orders = orders.shifted.order(:shift, volume: :desc)
    @not_shifted_orders = orders.not_specified.order(volume: :desc)
  end

  def edit
  end

  def update
    @order.attributes = order_params
    if @order.load && @order.load.completed?
      flash[:danger] = t('update_order_in_completed_load')
    else
      unless @order.save
        flash[:danger] = @order.errors.full_messages
      end
    end
    redirect_to orders_url(date: @order.reload.delivery_date)
  end

  def shift
    if params[:reverse]
      @order.move_higher
    else
      @order.move_lower
    end
    redirect_to orders_url(date: @date)
  end

  def split
    new_volume = params[:new_volume].to_f
    new_quantity = params[:new_quantity].to_i

    flash.now[:danger] ||= []
    flash.now[:danger] << I18n.t('invalid_new_volume') unless new_volume > 0 && new_volume < @order.volume
    flash.now[:danger] << I18n.t('invalid_new_quantity') unless new_quantity > 0 && new_quantity < @order.quantity

    if flash.now[:danger].empty?
      @new_order = Order.new(@order.attributes.merge(id: nil, volume: @order.volume - new_volume, quantity: @order.quantity - new_quantity))
      Order.transaction do
        @order.update!(volume: new_volume, quantity: new_quantity)
        @new_order.save!
      end
      redirect_to orders_url(date: @order.delivery_date)
    else
      render :edit
    end
  rescue Exception => e
    flash.now[:danger] = e.message
    render :edit
  end

  def import
    messages = OrderParser.perform(params[:file], strategy: params[:strategy])
    unless messages[:warnings].empty?
      flash[:warning] = messages[:warnings]
      flash[:warning] << I18n.t('warnings_in_csv')
    end
    if messages[:errors].empty?
      flash[:success] = I18n.t('success_import')
    else
      flash[:danger] = messages[:errors]
      flash[:danger] << I18n.t('errors_in_csv')
    end
  rescue Exception => e
    flash[:danger] = [I18n.t('error_import_file')]
    flash[:danger] << e.message
  ensure
    redirect_to dispatcher_url
  end

  def destroy
    flash[:danger] = I18n.t('cannot_destroy_order_in_load') unless @order.destroy
    redirect_to orders_url(date: @order.delivery_date)
  end

  private

  def parse_date
    @date = Date.parse(params[:date]) rescue nil
  end

  def find_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:load_id, :delivery_date, :shift, :number, :phone)
  end

end
