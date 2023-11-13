class AuthenticationController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :authorize_request, except: :login

    def login
        @user = User.find_by(username: params[:username])
        password = params[:password]
        if @user&.authenticate(password)
            token = JsonWebToken.encode(user_id: @user.id)
            session[:user_token] = token
            time= Time.now + 24.hours.to_i
            render json: { token: token, exp: time.strftime("%m-%d-%Y %H:%M"),username: @user.username}, status: :ok
        else
            render json: {error: 'unauthorized'}, status: :unauthorized
        end
    end

    private

    def login_params
        params.permit(:username, :password)
    end

end
