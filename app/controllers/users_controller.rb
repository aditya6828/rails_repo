class UsersController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :authenticate_user, only: [:get]
  
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


    
    def get
      user_id = params[:id]
      

      requested_user = User.find_by(id: user_id)

      if requested_user
        if current_user.id == requested_user.id
          render json: requested_user
        else
          render json: {error: 'unauthorized access'}, status: 400
        end
      else
        render json: {error: 'User not found'}, status: 400
      end

    end
    
    def delete

      user_id = params[:id]
      puts "Received user ID in delete action: #{user_id.inspect}"
      # puts "Received user ID in delete action: #{user_id}"

      requested_user = User.find_by(id: user_id)

      if requested_user
        if current_user.id == requested_user.id
          requested_user.destroy
          session[:user_id] = nil
          render json: {message: 'User deleted successfully'}
        else
          render json: {error: 'unauthorized access'}, status: 400
        end
      else
        render json: {error: 'User not found'}, status: 400
      end
    end
      
      
  

    private 
    def user_params
    params.permit(:username, :password, :password_confirmation, :email, :id, :first_name, :last_name)
    end 

    def authenticate_user
      unless current_user
        render json: {error: 'Unauthorized access'}, status: 400
      end
    end

    def current_user
      @current_user ||= User.find_by(id: session[:user_id])
    end


  end
  