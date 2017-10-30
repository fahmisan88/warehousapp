class PasswordController < ApplicationController

    def index
        redirect_to '/password/resetpass'
    end

    # supply token reset in email
    def forgot
        if pass_reset_params[:email].blank?
            redirect_to 'password/resetpass'
            flash[:danger] = "Email not present"
        end

        @user = User.find_by(email: pass_reset_params[:email].downcase)
        @user.skip_icpassport_validation = true

        if @user.present?
            @user.generate_password_token!
            # send email here
            puts HTTParty.put("https://api.sendinblue.com/v2.0/template/13",:body =>{"id":13, "to":@user.email,"attr":{"NAME":@user.name,"PASS_RESET_URL_NO_PROTO": ENV['URL_NO_PROTO'] + "/password/reset/" + @user.reset_password_token,"PASS_RESET_URL": ENV['URL'] + "/password/reset/" + @user.reset_password_token}}, :default_timeout => 10, :headers => {"api-key"=>ENV['SENDINBLUE_API_KEY'],"content-type"=>"application/json"})
            # --------------------------------------------
            redirect_to '/'
            flash[:info] = "Check email for reset password instruction"
        else
            redirect_to '/password/resetpass'
            flash[:danger] = "Email address not found. Please check and try again."
        end
    end

    # must use 'get' method with 1 parameter 'token'.
    def reset
        @user = User.new

        if params[:token].blank?
            redirect_to 'password/resetpass'
            flash[:danger] = 'Token password reset not present'
        end

        token = params[:token].to_s

        if User.exists?(reset_password_token: token)
            @user = User.find_by(reset_password_token: token)
            if @user.password_token_valid? == false
                redirect_to '/password/resetpass'
                flash[:danger] = "Token password reset expired"
            end
        else
            redirect_to '/password/resetpass'
            flash[:danger] = "Invalid token password reset"
        end
    end

    # update new password
    def update
        @email = pass_reset_update_params[:email].downcase
        @token = pass_reset_update_params[:token]
        @password = pass_reset_update_params[:password]

        if User.exists?(reset_password_token: @token)
            @user = User.find_by(reset_password_token: @token)
            @user.skip_icpassport_validation = true
            if @user.email == @email
                    if @user.reset_password!(@password)
                        redirect_to '/login'
                        flash[:success] = "Success reset new paasword"
                    end
            else
                redirect_to '/password/resetpass'
                flash[:danger] = "Email not valid with token"
            end
        else
            redirect_to '/password/resetpass'
            flash[:danger] = "Token password reset not exist"
        end
    end

    # First page to open for request new password
    def resetpass
        @user = User.new
    end

    private
    def pass_reset_params
        params.require(:user).permit(:email)
    end

    def pass_reset_update_params
        params.require(:user).permit(:email, :token, :password)
    end
end
