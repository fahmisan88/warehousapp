class ShipmentPolicy < ApplicationPolicy


  def show?
    user.present? && record.user == user || user_has_power?
  end

  def create?
    show?
  end

  def edit?
    show?
  end

  def update?
    show?
  end

  def destroy?
    show?
  end

  private

  def user_has_power?
    user.admin? || user.staff?
  end
end
