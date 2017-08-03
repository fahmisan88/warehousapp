class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception

  rescue_from Pundit::NotAuthorizedError do |exception|
    flash[:danger] = "You're not authorized"
    redirect_to request.referrer || root_path
  end

  private

  def admin_user
    return unless session[:id]
    @admin_user ||= User.find_by(id: session[:id], role: 2)
  end
  helper_method :admin_user

  def staff_user
    return unless session[:id]
    @staff_user ||= User.find_by(id: session[:id], role: 1)
  end
  helper_method :staff_user

  def member_user
    return unless session[:id]
    @member_user ||= User.find_by(id: session[:id], role: 0)
  end
  helper_method :member_user

  def current_user
    return unless session[:id]
    @current_user ||= User.find_by(id: session[:id])
  end
  helper_method :current_user


  def authenticate!
    unless current_user&.status == "Active"
      redirect_to root_path
      flash[:danger] = "You need to login first"
    end
  end

  # check existing of user on ezicargo code
  def ezicode_exist
    @user = User.find_by(ezi_id: parcel_params[:ezi_id].upcase)
    if @user.present?
      respond_to do |format|
        format.json {render json: { valid: true }}
      end
    else
      respond_to do |format|
        format.json {render json: { valid: false, message: "Ezicargo Code not exists" }}
      end
    end
  end
  helper_method :ezicode_exist

  protected
# ================================================================================================
  # email notification
  # name: current_user.name
  # email: current_user.email
  # controller: currently only for "parcels" and "shipments" controller
  # status: parcels - "created", "arrived" | shipments - "created", "waitpayment","readytoship"
  def deliver_mail(name, email, controller, status)
    @controller = controller
    @status = status
    @name =  name
    @email = email

    if @controller == "parcels"
      deliver_mail_parcels(@name, @email, @status)
    elsif @controller == "shipments"
      deliver_mail_shipments(@name, @email, @status)
    end
  end

  # use for parcels mail notification. strictly use for method deliver_mail
  def deliver_mail_parcels(name, email, status)
    @name = name
    @email = email
    @status = status

    @mail = Sendinblue::Mailin.new(ENV['SENDINBLUE_API_URL'], ENV['SENDINBLUE_API_KEY'], 10)

    @data = case @status
      when "created" then {id: 7, to: @email, attr: {"NAME" => @name}}
      when "arrived" then {id: 8, to: @email, attr: {"NAME" => @name}}
    end
    return @mail.send_transactional_template(@data)
  end

  # use for shipments mail notification. strictly use for method deliver_mail
  def deliver_mail_shipments(name, email, status)
    @name = name
    @email = email
    @status = status

    @mail = Sendinblue::Mailin.new(ENV['SENDINBLUE_API_URL'], ENV['SENDINBLUE_API_KEY'], 10)

    @data = case status
      when "created" then {id: 9, to: @email, attr: {"NAME" => @name}}
      when "waitpayment" then {id: 11, to: @email, attr: {"NAME" => @name}}
      when "readytoship" then {id: 10, to: @email, attr: {"NAME" => @name}}
    end
    return @mail.send_transactional_template(@data)
  end
# ========================================================================================================
end
