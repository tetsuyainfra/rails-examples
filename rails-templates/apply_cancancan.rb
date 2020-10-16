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
    # config_can
    _path = "app/views/#{target}/index.html.erb"
    inject_into_file _path, <<-'CODE', after: "<th colspan=\"3\"></th>\n"
      <th>:manage</th>
      <th>:read</th>
      <th>:update</th>
      <th>:destroy</th>
CODE

    _t = target.singularize
    _code = "<td><%= link_to 'Destroy', #{_t}, method: :delete, data: { confirm: 'Are you sure?' } %></td>\n"
    inject_into_file _path, <<-"CODE", after: _code
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
    can [:read, :destroy], Comment, user_id: user.id
CODE

  inject_into_class "app/controllers/blogs_controller.rb", "BlogsController", "  load_and_authorize_resource\n"
  inject_into_class "app/controllers/posts_controller.rb", "PostsController", "  load_and_authorize_resource\n"
  inject_into_class "app/controllers/comments_controller.rb", "CommentsController", "  load_and_authorize_resource\n"
end

after_bundle do
  # run "bundle exec spring stop"
  setup_can
  configure_can

  git add: "."
  git commit: %Q{ -m 'commit applied cancancan' }
end
