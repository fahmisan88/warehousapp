class PasswordController < ApplicationController

    def index
        redirect_to '/password/resetpass'
    end

    def forgot
        if pass_reset_params[:email].blank?
            redirect_to 'password/resetpass'
            flash[:danger] = "Email not present"
        end

        @user = User.find_by(email: pass_reset_params[:email].downcase)

        if @user.present?
            @user.generate_password_token!
            # send email here
            @mail = Sendinblue::Mailin.new(ENV['SENDINBLUE_API_URL'], ENV['SENDINBLUE_API_KEY'], 10)
            @data = {"id" => 13, "to" => @user.email, "attr" => {"NAME" => @user.name, "PASS_RESET_URL_NO_PROTO" => "localhost/password/reset/" + @user.reset_password_token, "PASS_RESET_URL" => "http://localhost/password/reset/" + @user.reset_password_token}}
            puts @mail.send_transactional_template(@data)
            # --------------------------------------------
            redirect_to '/'
            flash[:info] = "Check email for reset password instruction"
        else
            redirect_to '/password/resetpass'
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
        @user = User.new
    end

    private
    def pass_reset_params
        params.require(:user).permit(:email, :token)
    end
end