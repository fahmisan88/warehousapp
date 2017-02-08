class ParcelPolicy < ApplicationPolicy

  def show?
    user.present? && record.user == user || user_has_power?
  end

  def create?
    show?
  end

  def edit?
    user_has_power?
  end

  def edit_awb?
    show?
  end

  def request_refund?
    show?
  end

  def update_request_refund?
    show?
  end

  def update_awb?
    show?
  end

  def update?
    user_has_power?
  end

  def destroy?
    show?
  end

  private

  def user_has_power?
    user.admin? || user.staff?
  end
end
