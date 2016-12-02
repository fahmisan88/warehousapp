class CurrenciesController < ApplicationController
  def new
    @currency = Currency.new
  end

  def create
    @currency = Currency.create(currency_params)
    if @currency.save
      redirect_to dashboard_path
      flash[:success] = "You've created a currency change."
    else
      flash[:danger]
    end
  end

  def edit
    @currency = Currency.find(params[:id])
  end

  def update
    @currency = Currency.find(params[:id])
    if @currency.update(currency_params)
      redirect_to dashboard_path
      flash[:success] = "You've updated the currency change."
    else
      flash[:danger]
    end

  end

  private

    def currency_params
      params.require(:currency).permit(:change)
    end
end
