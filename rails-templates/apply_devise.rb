# create-user.rb
# TODO: RegistrationControllerのview書き換え username/displaynameがだめぽ
def source_paths
  # [__dir__]
  [Pathname.new(__dir__).join("./devise").to_s]
end

def apply_template!
  # DATABASE
  gem("pg")

  # AUTH
  gem("devise")

  gem_group :development do
    gem "pry-rails"
    gem "pry-byebug"
    gem "pry-doc"
    # gem 'better_errors'
    # gem 'binding_of_caller'
  end

  # for email
  gem_group :development do
    # gem "letter_opener"
    gem "letter_opener_web"
  end

  # generate(:scaffold, "Us name:string")
  # route "root to: 'people#index'"
  # rails_command("db:migrate")

  # Database config for postgresql
  remove_file "config/database.yml"
  template "config/database.yml.tt"
end

def setup_git
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
end

def setup_page_controler
  generate "controller Page index help"
  route "root to: 'page#index'"

  inject_into_file "app/views/layouts/application.html.erb", after: "<body>\n" do
    <<-'TEXT'
    <p class="notice"><%= notice %></p>
    <p class="alert"><%= alert %></p>
    <p><a href="/letter_opener">letter_opener</a></p>
    <p>
      <% if user_signed_in? %>
        <%= link_to "#{current_user.username} Logout", destroy_user_session_path, :method => :delete %>
      <% else %>
        <a href="<%= user_session_path %>">user</a>
      <% end %>
    </p>
    <p>
      <% if admin_signed_in? %>
        <%= link_to "#{current_admin.email} Logout", destroy_admin_session_path, :method => :delete %>
      <% else %>
        <a href="<%= admin_session_path %>">admin</a>
      <% end %>
    </p>
    TEXT
  end
end

def setup_devise
  # run "bundle exec spring stop"
  generate "devise:install"

  generate "devise", "User", "username:string:unique", "displayname:string"
  generate "devise:views", "users"
  generate "devise:controllers", "users"

  generate "devise Admin"
  generate "devise:views", "admins", "-v", "sessions"       # only  a few sets of views
  generate "devise:controllers", "admins", "-c", "sessions" # only  a few sets of controllers
end

#
# 一般ユーザと管理ユーザのモデル/コントローラーを分ける設定
#
def configure_devise
  environment "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }", env: "development"

  # viewを分ける
  inject_into_file "config/initializers/devise.rb", after: "# config.scoped_views = false" do
    "\n  config.scoped_views = true"
  end
  # モデル毎に使うコントローラーを指定する
  inject_into_file "config/routes.rb", after: "devise_for :users" do
    ", controllers: { sessions: 'users/sessions', registrations: 'users/registrations' }, sign_out_via: [:get, :delete]"
  end
  inject_into_file "config/routes.rb", after: "devise_for :admins" do
    ", controllers: { sessions: 'admins/sessions' }, sign_out_via: [:get, :delete]"
  end

  # テンプレートファイルから生成
  %w(
    app/controllers/concerns/solo_accessible.rb
    app/models/user.rb
    app/models/admin.rb
  ).each do |filename|
    remove_file filename
    template "#{filename}.tt"
  end
  # ファイルからコピー
  %w(
    app/views/users/registrations/new.html.erb
  ).each do |filename|
    remove_file filename
    copy_file "#{filename}"
  end

  # controllerのカスタマイズ(Admin/Userどちらかのモデルを利用したログインしか許可しない)
  ## Users
  inject_into_class "app/controllers/users/sessions_controller.rb", "Users::SessionsController", <<-'CODE'
  include SoloAccessible
  skip_before_action :check_solo, only: :destroy
  CODE
  inject_into_class "app/controllers/users/registrations_controller.rb", "Users::RegistrationsController", <<-'CODE'
  include SoloAccessible
  skip_before_action :check_solo, except: [:new, :create]
  CODE

  ## Admins
  inject_into_class "app/controllers/admins/sessions_controller.rb", "Admins::SessionsController", <<-'CODE'
  include SoloAccessible
  skip_before_action :check_solo, only: :destroy
  CODE

  # loginに利用するパラメータを読み込めるよう設定
  inject_into_class "app/controllers/application_controller.rb", "ApplicationController" do
    <<-'CODE'
  before_action :configure_permitted_parameters, if: :devise_controller?
  protected
  def configure_permitted_parameters
    added_attrs = [:username, :email, :password, :password_confirmation, :remember_me]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end
    CODE
  end
  # Viewの表示を変更
  gsub_file "app/views/admins/sessions/new.html.erb", "<h2>Log in</h2>", "<h2>Admin Log in</h2>"
  gsub_file "app/views/users/sessions/new.html.erb", "<h2>Log in</h2>", "<h2>User Log in</h2>"

  # loginに利用するパラメータを送信するようにViewを変更
  gsub_file "app/views/users/sessions/new.html.erb", "f.label :email", "f.label :login"
  gsub_file "app/views/users/sessions/new.html.erb", "f.email_field :email", "f.text_field :login"

  # testを追加
  test_files = Dir.glob("#{__dir__}/devise/test/{fixtures,integration}/*.*").map { |p| p.gsub(/^#{__dir__}\/devise\//, "") }
  test_files.each do |f|
    copy_file f, force: true
  end
  # %w( test/fixtures/users.yml
  #     test/fixtures/user_identities.yml
  #     test/fixtures/admins.yml
  #   ).each do | filename |
  # end

  inject_into_file "test/test_helper.rb", <<-'CODE', before: "end"
  def log_in(user)
    if defined?(:login_as)
      #use warden helper
      login_as(user, :scope => :user)
    else #controller_test, model_test
      #use devise helper
      sign_in(user)
    end
  end
  def log_out(scope = :user)
    if defined?(:login_as)
      #use warden helper
      logout(scope)
    else #controller_test, model_test
      #use devise helper
      sign_out scope
    end
  end
  CODE

  append_to_file "test/test_helper.rb", <<-'CODE'.strip_heredoc
    if ENV.fetch("LOG_OUTPUT_CONSOLE", false)
       # ログをコンソールに出力する
       Rails.logger = Logger.new(STDOUT) # 追記
       # SQLのログ
       # ActiveRecord::Base.logger = Logger.new(STDOUT) # 追記
    end
  CODE
end

def configure_letter_opener_web
  environment "config.action_mailer.delivery_method = :letter_opener_web", env: "development"
  route "mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?"
end

after_bundle do
  setup_git
  setup_devise
  configure_devise

  setup_page_controler

  configure_letter_opener_web

  copy_file "run_sample.sh", "run_sample.sh"
  chmod "run_sample.sh", 0755

  git add: "."
  git commit: %Q{ -m 'commit applied devise' }
end

apply_template!
