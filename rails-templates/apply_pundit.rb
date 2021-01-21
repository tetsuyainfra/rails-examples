# apply_pundit.rb
apply "#{__dir__}/apply_simple_blog.rb"

def source_paths
  [Pathname.new(__dir__).join("./devise").to_s,
   Pathname.new(__dir__).join("./omniauth").to_s,
   Pathname.new(__dir__).join("./simple_blog").to_s,
   Pathname.new(__dir__).join("./pundit").to_s]
end

gem "pundit"

def setup_pundit
  generate "pundit:install"
end

def configure_pundit
  inject_into_class "app/controllers/application_controller.rb", "ApplicationController", <<-'CODE'
  include Pundit
  # after_action :verify_authorized, except: [:index, :new], unless: devise_controller? # authorize methodが呼ばれてない場合例外が起きる(開発時のみ使う方がよい)
  # after_action :verify_policy_scoped, only: :index # policy_scope が呼ばれてない場合例外が起きる
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  CODE

  inject_into_file "app/controllers/application_controller.rb", <<-'CODE', after: "protected\n"
  def pundit_user
    current_user || User.new
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    # redirect_to(request.referrer || root_path)
    redirect_to(root_path)
  end
  CODE

  %w(blogs posts comments).each do |target|
    # config_can
    _path = "app/views/#{target}/index.html.erb"
    inject_into_file _path, <<-"CODE", before: "    </tr>\n  </thead>"
      <th>index?</th>
      <th>show?</th>
      <th>create?</th>
      <th>update?</th>
      <th>destroy?</th>
CODE
    _t = target.singularize
    _code = "      </tr>\n    <% end %>\n  </tbody>"
    inject_into_file _path, <<-"CODE", before: _code
        <td><%= policy(#{_t}).index? %></td>
        <td><%= policy(#{_t}).show? %></td>
        <td><%= policy(#{_t}).create? %></td>
        <td><%= policy(#{_t}).update? %></td>
        <td><%= policy(#{_t}).destroy? %></td>
CODE

    _path = "app/controllers/#{target}_controller.rb"
    copy_file "#{_path}", _path, force: true

    _path = "app/policies/#{target.singularize}_policy.rb"
    copy_file "#{_path}", _path, force: true

    _path = "test/controllers/#{target}_controller_test.rb"
    copy_file "#{_path}", _path, force: true
  end
end

after_bundle do
  setup_pundit
  git add: "."
  git commit: %Q{ -m 'commit setup pundit' }

  configure_pundit
  git add: "."
  git commit: %Q{ -m 'commit applied pundit config' }
end
