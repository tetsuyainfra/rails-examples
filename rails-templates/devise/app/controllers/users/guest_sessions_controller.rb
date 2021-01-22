# frozen_string_literal: true
# app/controllers/users/guest_sessions_controller.rb

class Users::GuestSessionsController < Devise::SessionsController
  GUEST_ACCOUNT_RANGE = 1..2

  include SoloAccessible
  skip_before_action :check_solo, only: :destroy

  def new_guest
    no = params[:no].to_i || 1
    no = 1 unless GUEST_ACCOUNT_RANGE.cover?(no)

    user = User.find_or_create_by!(email: "guest#{no}@example.com") do |user|
      # ブロックで必要カラムを追加(自分の場合はnicknameを追加)
      user.username = "guest#{no}"
      user.displayname = "Guestユーザー#{no}"
      user.password = SecureRandom.urlsafe_base64
      if respond_to?(:confirmed_at)
        user.confirmed_at = Time.now  # Confirmable を使用している場合は必要
      end
    end
    # ログイン(deviseのメソッド)
    sign_in user
    # トップページへリダイレクト
    redirect_to root_path
  end
end
