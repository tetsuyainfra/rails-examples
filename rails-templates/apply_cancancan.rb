# apply_cancancan.rb
def source_paths
  [__dir__]
end

apply "#{__dir__}/apply_simple_blog.rb"
gem "cancancan"

def setup_can
  generate "cancan:ability"
end

def configure_can
  %w(blogs posts comments).each do |target|
    inject_into_file "app/controllers/#{target}_controller.rb",
      "  load_and_authorize_resource except: [:new]\n",
      before: "  before_action :set_#{target.singularize}"

    # config_can
    _path = "app/views/#{target}/index.html.erb"
    inject_into_file _path, <<-"CODE", before: "    </tr>\n  </thead>"
      <th>:manage</th>
      <th>:read</th>
      <th>:update</th>
      <th>:destroy</th>
CODE

    _t = target.singularize
    # _code = "<td><%= link_to 'Destroy', #{_t}, method: :delete, data: { confirm: 'Are you sure?' } %></td>\n" #before version
    _code = "      </tr>\n    <% end %>\n  </tbody>"
    inject_into_file _path, <<-"CODE", before: _code
        <th><%= can? :manage, #{_t} %></th>
        <th><%= can? :read, #{_t} %></th>
        <th><%= can? :update, #{_t} %></th>
        <th><%= can? :destroy, #{_t} %></th>
CODE
  end

  inject_into_file "app/models/ability.rb", <<-'CODE', after: "initialize(user)\n"
    user = user || User.new # guest user (not logged in)
    # Blog
    can :read, Blog, status: Blog.statuses[:published]
    can :manage, Blog, user_id: user.id

    # Post
    can :read, Post, blog: { status: Blog.statuses[:published] }
    can :manage, Post, blog: { user_id: user.id }

    # Comment
    can :read, Comment, post: { blog: { status: Blog.statuses[:published] } }
    can [:read, :destroy, :create], Comment, user_id: user.id
CODE

  _code = "before_action :configure_permitted_parameters, if: :devise_controller?\n"
  inject_into_file "app/controllers/application_controller.rb", <<-'CODE', after: _code
  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden, content_type: "text/html" }
      format.html { redirect_to main_app.root_url, notice: exception.message }
      format.js { head :forbidden, content_type: "text/html" }
    end
  end

  CODE
end

after_bundle do
  # run "bundle exec spring stop"
  setup_can
  configure_can

  git add: "."
  git commit: %Q{ -m 'commit applied cancancan' }
end
