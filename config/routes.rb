Rails.application.routes.draw do
  resources :orders do
    patch :shift, on: :member
    post :import, on: :collection
  end

  resources :loads, only: [:create] do
    patch :complete, on: :member
  end

  scope :dashboards, controller: :dashboards do
    get :dispatcher
  end

  root to: 'dashboards#dispatcher'
end
