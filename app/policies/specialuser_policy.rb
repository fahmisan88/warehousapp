class SpecialuserPolicy < ApplicationPolicy
    def index?
        user.admin? || user.staff?
    end
end