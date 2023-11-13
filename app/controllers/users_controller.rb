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
    # render json: { user_id: user_id }
    

    requested_user = User.find_by(params[:id])
    # puts requested_user

    if requested_user
      render json: requested_user
      render json: { user_id: user_id }
      if current_user && current_user.id == requested_user.id
        render json: requested_user 
      else
        
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
        render json: {error: 'unauthorized access abcd'}, status: 400
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

    user = User.find_by(email: email)

    if user

      token = SecureRandom.hex(20)
      user.update(password_reset_token: token, password_reset_token_expires_at: 1.hour.from_now)

      send_password_reset_email(user, token)
    
      
      render json: {message: 'Pasword reset email sent successfully'}
    else
      render json: {error: 'User not found'}, status: 400
    end
  end

  def reset_password
    token = params[:token]
    user = User.find_by(password_reset_token: token)
    # puts user.password_reset_token_expires_at
    if user && user.password_reset_token_expires_at > Time.now
      # render json: { message: 'Password reset page' }
      render 'users/reset_password'
      # render '/reset_password_page'
      
    else
      render json: {error: 'Invalid or expired token'}, status: 400
    end
  end

  def update_password
    token = params[:token]
    user = User.find_by(password_reset_token: token)
    
    if user && user.password_reset_token_expires_at > Time.now
      new_password = params[:new_password]

      # Validate and update the password
      if new_password.present?
        user.update(password: new_password, password_reset_token: nil, password_reset_token_expires_at: nil)
        render json: { message: 'Password updated successfully' }
      else
        render json: { error: 'New password cannot be blank' }, status: 400
      end
    else
      render json: { error: 'Invalid or expired token' }, status: 400
    end
  end

  def reset_password_submit
    token = params[:token]
    user = User.find_by(password_reset_token: token)
    # session[:user_token] = user.token # Set the token when the user logs in


    # puts user
    # puts user.password_reset_token_expires_at
    if user && user.password_reset_token_expires_at > Time.now
      new_password = params[:user][:new_password]
      password_confirmation = params[:user][:password_confirmation]

      if new_password.present? && new_password == password_confirmation
        # Update the user's password
        user.update(password: new_password, password_reset_token: nil, password_reset_token_expires_at: nil)

        # Optional: You might want to log the user in after password reset
        session[:user_id] = user.id

        flash[:notice] = 'Password reset successfully!'
        redirect_to root_path
      else
        flash[:error] = 'New password and password confirmation do not match'
        render 'users/reset_password'
      end
    else
      flash[:error] = 'Invalid or expired token'
      redirect_to root_path
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

  def send_password_reset_email(user, token)
    # Use ActionMailer to send the email using SMTP
    UserMailer.password_reset_email(user, token).deliver_now
  end

end