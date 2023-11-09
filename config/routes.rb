Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  get '/hello_world', to: 'example#hello_world'

  post '/user/register', to: 'users#register'
 
  post 'auth/login', to: 'authentication#login'

  # get '/*a', to: 'application#not_found'

  post '/user/login', to: 'sessions#create'

  get '/user/logout', to: 'sessions#logout'

  get '/user/get/:id', to: 'users#get'

  delete '/user/delete/:id', to: 'users#delete'

  get '/user/list/:page', to: 'users#list'

  get '/reset_password_page', to: 'users#reset_password', as: 'reset_password'

  post '/update_password', to: 'users#update_password'

  post '/user/forget_password', to: 'users#forget_password'

  # get '/reset_password', to: 'users#reset_password'

  # post '/update_password', to: 'users#update_password'

  post '/reset_password_submit', to: 'users#reset_password_submit', as: 'reset_password_submit'

  # config/routes.rb


end
