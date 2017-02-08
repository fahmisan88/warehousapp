class CurrenciesController < ApplicationController

  def edit
    @currency = Currency.find(params[:id])
    authorize @currency
  end

  def update
    @currency = Currency.find(params[:id])
    authorize @currency
    if @currency.update(currency_params)
      redirect_to dashboard_path
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
