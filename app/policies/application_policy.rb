# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    true
  end

  def show?
    admin_and_above?
  end

  def create?
    admin_and_above?
  end

  def new?
    create?
  end

  def update?
    admin_and_above?
  end

  def edit?
    update?
  end

  def destroy?
    admin_and_above?
  end

  def admin_and_above?
    user.admin? || user.owner?
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NoMethodError, "You must define #resolve in #{self.class}"
    end

    def admin_and_above?
      user.admin? || user.owner?
    end

    private

    attr_reader :user, :scope
  end
end
