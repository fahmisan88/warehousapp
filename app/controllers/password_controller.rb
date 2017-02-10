class PasswordController < ApplicationController

    def forgot
        if params[:email].blank?
            redirect_to 'password/resetpass'
            flash[:danger] = "Email not present"
        end

        @user = User.find_by(email: params[:email].downcase)

        if @user.present?
            @user.generate_password_token!
            # send email here
            redirect_to '/'
            flash[:info] = "Check email for reset password instruction"
        else
            redirect_to 'password/resetpass'
            flash[:danger] = "Email address not found. Please check and try again."
        end
    end

    def reset
        if params[:token].blank?
            redirect_to 'password/resetpass'
            flash[:danger] = 'Token reset not present'
        end

        token = params[:token].to_s

        @user = User.find_by(reset_password_token: token)

        if @user.present? && @user.password_token_valid?
            if @user.reset_password!(params[:password])
                redirect_to '/login'
                flash[:success] = "You password is successfully reset"
            else
                redirect_to 'password/resetpass'
                flash[:danger] = @user.errors.full_messages
            end
        end
    end

    def update
    end

    def resetpass
    end
end