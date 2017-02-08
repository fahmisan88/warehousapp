class CurrencyPolicy < ApplicationPolicy

  def edit?
    user_has_power?
  end

  def update?
    user_has_power?
  end

  private

  def user_has_power?
    user.admin? || user.staff?
  end

end
