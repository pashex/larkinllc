Rails.application.routes.draw do
  resources :orders do
    patch :shift, on: :member
    post :import, on: :collection
  end

  resources :loads, only: [:index, :create] do
    patch :complete, on: :member
    get :export, on: :member
  end

  scope :dashboards, controller: :dashboards do
    get :dispatcher
    get :driver
  end

  root to: 'dashboards#dispatcher'
end
