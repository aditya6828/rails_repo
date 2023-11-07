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

    #     {
    #   "username": "your_username",
    #   "password": "your_password",
    #   "email": "your_email@example.com",
    #   "id": 1,
    #   "first_name": "Your",
    #   "last_name": "Name"
    # }


    
  def get
    user_id = params[:id]
    # render user_id
    

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

  def list
    page = params[:page].to_i
    
    per_page = 10

    offset=(page-1)*per_page

    users = User.limit(per_page).offset(offset)

    if users.empty?
      render json: { data: [], message: 'total limit exceeded'}
    else
      render json: {data: users, message: 'data extracted'}
    end
  end
    
  def delete

    delete_id = params[:id]
    # puts "Received user ID in delete action: #{user_id.inspect}"
    # puts "Received user ID in delete action: #{user_id}"

    requested_user = User.find_by(id: delete_id)

    if requested_user
      if current_user == requested_user.id
        requested_user.destroy
        session[:user_token] = nil
        render json: {message: 'User deleted successfully'}
      else
        render json: {error: 'unauthorized access'}, status: 400
      end
    else
      render json: {error: 'User not found'}, status: 400
    end
  end


  def forget_password
    email = params[:email]

    if email.blank?
      render json: {error: 'Email cannot be blank'}, status: 400
      return
    end

    e_user = User.find_by(email: email)

    if e_user

      token = SecureRandom.hex(20)
      e_user.update(password_reset_token: token, password_reset_token_expires_at: 1.hour.from_now)
      
    
      
      render json: {message: 'Pasword reset email sent successfully'}
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

    # @current_user ||= User.find_by(id: session[:user_id])
    token = session[:user_token]

    if token.present?

      user_info = JsonWebToken.decode(token)
      user_id = user_info[:user_id]
      @current_user ||= User.find_by(id: user_id)
      # @current_user ||= User.find_by(id: user_id)
    end
  end 

end