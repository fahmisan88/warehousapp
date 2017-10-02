class Admin::CurrenciesController < ApplicationController
  before_action :check_if_admin
  
  def edit
    @currency = Currency.find(params[:id])
  end

  def update
    @currency = Currency.find(params[:id])
    if @currency.update(currency_params)
      redirect_to admin_dashboards_path
      flash[:success] = "You've updated the currency change."
    else
      flash[:danger]
    end
  end

  private
  def currency_params
    params.require(:currency).permit(:myr2rmb, :rmb2myr)
  end
end
