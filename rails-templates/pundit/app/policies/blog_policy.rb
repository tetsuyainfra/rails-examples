class BlogPolicy < ApplicationPolicy
  # def initialize(user, record) # in ApplicationPolicy
  def new?
    true
  end

  def create?
    @record.user_id == user.id
  end

  def show?
    if @record.user_id == user.id
      return true
    end
    @record.published?
  end

  def update?
    # Rails.logger.debug "update?: #{@record.inspect}"
    # Rails.logger.debug "update? @user: #{@user.inspect}"
    @record.user_id == user.id
  end

  def destroy?
    @record.user_id == user.id
  end
end
