# create-user.rb
def source_paths
  [__dir__]
end

# DATABASE
gem("pg")

# AUTH
gem("devise")

# generate(:scaffold, "Us name:string")
# route "root to: 'people#index'"
# rails_command("db:migrate")

remove_file "config/database.yml"
# database名変えたいのでtemplate_fileにした方がよい
copy_file "config/database.yml"

def setup_git
  # git :init
  # git add: "."
  # git commit: %Q{ -m 'Initial commit' }
end

def setup_page_controler
  generate "controller Page index help"
  route "root to: 'page#index'"

  inject_into_file "app/views/layouts/application.html.erb", after: "<body>\n" do
    <<-'TEXT'
    <p class="notice"><%= notice %></p>
    <p class="alert"><%= alert %></p>
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
  run "bundle exec spring stop"
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
    ", controllers: { sessions: 'users/sessions', registrations: 'users/registrations' }"
  end
  inject_into_file "config/routes.rb", after: "devise_for :admins" do
    ", controllers: { sessions: 'admins/sessions' }"
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
end

after_bundle do
  # setup_git
  setup_devise
  configure_devise

  setup_page_controler
end
