class UserMailer < ApplicationMailer
    # def password_reset_email(user)
    #     @user = user
    #     @reset_link = reset_password_url(token: user.password_reset_token)

    #     mail(to: @user.email, subject: 'password Reset Instructions')
    # end

    default from: 'adityaanand6828@gmail.com'

    def password_reset_email(user, token)
        @user = user
        @reset_link = reset_password_url(token: token)

        mail(to: @user.email, subject: 'Password Reset Instructions')
    end

end
