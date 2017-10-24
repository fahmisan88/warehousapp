class ParcelPolicy < ApplicationPolicy

  def show?
    user.present? && record.user == user || user_has_power?
  end

  def create?
    show?
  end

  def edit?
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

  def admin_create_parcel_show?
    user_has_power?
  end

  def admin_create?
    user_has_power?
  end

  private

  def user_has_power?
    user.admin? || user.staff?
  end
end
