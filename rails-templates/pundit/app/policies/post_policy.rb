class PostPolicy < ApplicationPolicy
  # def initialize(user, record) # in ApplicationPolicy
  def new?
    true
  end

  def create?
    @record.blog.user_id == user.id
  end

  def show?
    if @record.blog.user_id == user.id
      return true
    end
    @record.blog.published?
  end

  def update?
    @record.blog.user_id == user.id
  end

  def destroy?
    @record.blog.user_id == user.id
  end
end
