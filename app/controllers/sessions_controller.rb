class SessionsController < ApplicationController
  skip_before_action :require_login

  def new
    @user = User.new
  end

  def create
    if login(params[:email], params[:password], true)
      redirect_to root_url
    else
      flash.now[:danger] = t('.login_error')
      render :new
    end
  end

  def destroy
    logout
    redirect_to root_url
  end

end
