class SpecialusersController < ApplicationController

    def index
        @user = User.find_by(id: session[:id])
        authorize @user
    end

    # create new users with free registration. eligable for special agent. need key-in special password to create new users
    def register
        redirect_to '/special', flash: {danger: "You are not authorized"} and return unless admin_user || staff_user
        redirect_to '/special', flash: {danger: "Wrong special pass"} and return unless user[:specialpass] == ENV['SPECIAL_PASS']

        if @reguser = User.create(email: user[:email].downcase, name: user[:fullname], password: user[:passwd], package: 1, status: 1, expiry: 6.months.from_now).valid?
            flash[:success] = "The user is successful created"
            redirect_to '/special'
            return true
        else
            flash[:danger] = "Special user is unsuccessful created."
            redirect_to '/special'
        end

    end

    private

    def specialuser_params
        params.require(:userspecial).permit(:password)
    end

    def user
        params.require(:user).permit(:email, :fullname, :passwd, :specialpass)
    end

end