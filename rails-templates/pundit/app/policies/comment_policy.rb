class CommentPolicy < ApplicationPolicy
  # def initialize(user, record) # in ApplicationPolicy
  def new?
    true
  end

  def create?
    @record.user_id == user.id
  end

  def show?
    if @record.post.blog.user_id == user.id
      return true
    end
    @record.post.blog.published?
  end

  def update?
    false
  end

  def destroy?
    @record.user_id == user.id
  end
end
