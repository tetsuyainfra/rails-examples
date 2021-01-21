# Deviseで複数モデルを利用するとき、排他的なログインを実現する
# ※各モデルでログイン済みの場合、
#   他のDeviseコントローラーにアクセスすると関連付けられたpathへリダイレクトする
#   ただし,次の場合はリダイレクトしないようにする
#      - sessions#destroy
#      - registrations#edit,update,destroy,cancel
#
# 参考:
#  - [How to Setup Multiple Devise User Models](https://github.com/plataformatec/devise/wiki/How-to-Setup-Multiple-Devise-User-Models)

module SoloAccessible
  extend ActiveSupport::Concern
  included do
    before_action :check_solo
  end

  protected

  def check_solo
    if current_admin
      flash.clear
      # if you have rails_admin. You can redirect anywhere really
      # redirect_to(rails_admin.dashboard_path) && return
      redirect_to root_path
    elsif current_user
      flash.clear
      # The authenticated root path can be defined in your routes.rb in: devise_scope :user do...
      # redirect_to(authenticated_user_root_path) && return
      redirect_to root_path
    end
  end
end
