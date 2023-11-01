class UsersController < ApplicationController
    skip_before_action :verify_authenticity_token
  
    def register
      if User.exists?(username: user_params[:username])
        render json: { error: 'Username is not unique' }, status: 400
        return
      end
  
      if User.exists?(email: user_params[:email])
        render json: { error: 'Email is not unique' }, status: 400
        return
      end
  
      encrypted_password = BCrypt::Password.create(user_params[:password])
  
      user = User.new(user_params) 
        puts "this is user #{user.password}"
      if user.save
        render json: { message: 'User registered successfully' }
      else
        render json: user.errors.full_messages, status: 400
      end
    end

    private 
    def user_params
    params.permit(:username, :password, :password_confirmation, :email, :id, :first_name, :last_name)
    end 


  end
  