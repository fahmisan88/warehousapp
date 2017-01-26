class UserPolicy < ApplicationPolicy

  def index?
    user_has_power?
  end

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

  def suspend?
    user.present? && user.admin?
  end

  private

  def user_has_power?
    user.admin? || user.staff?
  end
end
