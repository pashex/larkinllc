module UserConstraint
  def current_user(request)
    User.find_by_id(request.session[:user_id])
  end
end

class DispatcherRequiredConstraint
  include UserConstraint

  def matches?(request)
    user = current_user(request)
    p user.present? && user.role == 'dispatcher'
    user.present? && user.role == 'dispatcher'
  end
end

class DriverRequiredConstraint
  include UserConstraint

  def matches?(request)
    user = current_user(request)
    user.present? && user.role == 'driver'
  end
end


Rails.application.routes.draw do
  constraints(DispatcherRequiredConstraint.new) do
    resources :orders, only: [:index, :edit, :update, :destroy] do
      patch :shift, on: :member
      post :split, on: :member
      post :import, on: :collection
    end

    resources :loads, only: [:create] do
      patch :complete, on: :member
    end

    scope :dashboards, controller: :dashboards do
      get :dispatcher
      delete :destroy_all
    end

    root to: 'dashboards#dispatcher', as: nil
  end

  constraints(DriverRequiredConstraint.new) do
    resources :loads, only: [:index] do
      get :export, on: :member
    end

    scope :dashboards, controller: :dashboards do
      get :driver
    end

    root to: 'dashboards#driver', as: nil
  end

  resources :sessions

  get 'login' => 'sessions#new', as: :login
  post 'logout' => 'sessions#destroy', as: :logout

  root to: 'dashboards#index'
end
