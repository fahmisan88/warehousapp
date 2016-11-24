class UserPolicy < ApplicationPolicy

  def new?
    user.present? && record.id == user.id
  end

  def create?
    new?
  end

  def edit?
    new? || user.admin?
  end

  def update?
    new? || user.admin?
  end

  def destroy?
    user.present? && user.admin?
  end

  private

  def user_has_power?
    user.admin? || user.staff?
  end
end
