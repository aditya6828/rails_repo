class SessionsController < ApplicationController
    def create
        user = User.find_by(username: params[:username])

        if user && user.authenticate(params[:password])

            session[:user_id] = user.id
            render json: {user_id: user.id}

        else
            render json: {error: 'Invalid username or password'}, status: 400
        end
    end


end
