class SessionsController < ApplicationController
    skip_before_action :verify_authenticity_token

    def create
        user = User.find_by(username: params[:username])

        password = params[:password]

        if user && user.authenticate(password)

            session[:user_id] = user.id
            render json: {user_id: user.id}
            

        else
            render json: {error: 'Invalid username or password'}, status: 400
        end
    end

    def logout
        session[:user_id] = nil
        render json: {message: 'Logout successfull'}
    end


end
