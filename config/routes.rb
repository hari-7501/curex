Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      post 'send_otp', to: 'users#send_otp'
      post 'verify_otp', to: 'users#verify_otp'
      resources :wallets, only: [:index]
      resources :transactions, only: [:index, :create]
    end
  end
end
