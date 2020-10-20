# apply_cancancan.rb

apply "#{__dir__}/apply_devise.rb"

def source_paths
  [__dir__]
end

def create_models
  # TODO: SCHEMAへのNOT NULL 指定を忘れないように
  generate "scaffold", "Blog", "user:references",
           "title:string", "description:text", "status:integer"
  #  , "--no-fixtures"
  _path = Dir.glob("db/migrate/*_create_blogs.rb").first
  gsub_file _path, "t.integer :status", "t.integer :status, null: false, default: 1"

  generate "scaffold", "Post", "blog:references", "user:references",
           "title:string", "body:text"
  #  , "--no-fixtures"
  generate "scaffold", "Comment", "post:references", "user:references",
           "name:string", "body:text"
  #  , "--no-fixtures"
end

def configure_models
  # 関係を追加(実運用ではこの実装は使わず論理削除、ステートなどを利用すること)
  inject_into_class "app/models/user.rb", "User", "  has_many :blogs, dependent: :destroy\n"
  inject_into_class "app/models/blog.rb", "Blog", "  enum status: { unpublished: 0, published: 1 }\n"
  inject_into_class "app/models/blog.rb", "Blog", "  has_many :posts, dependent: :destroy\n"
  inject_into_class "app/models/post.rb", "Post", "  has_many :comments, dependent: :delete_all\n"
end

def configure_contollers
  # 関係を追加(実運用ではこの実装は使わず論理削除、ステートなどを利用すること)
  inject_into_class "app/controllers/blogs_controller.rb", "BlogsController",
                    "  before_action :authenticate_user!, except: [:index, :show]\n"
  inject_into_class "app/controllers/posts_controller.rb", "PostsController",
                    "  before_action :authenticate_user!, except: [:index, :show]\n"
  inject_into_class "app/controllers/comments_controller.rb", "CommentsController",
                    "  before_action :authenticate_user!, except: [:index, :show]\n"
end

def configure_views
  inject_into_file "app/views/layouts/application.html.erb", <<-'CODE', after: "<%= yield %>\n"
    <div>
      <%= link_to "/blog", blogs_path %>
      <%= link_to "/post", posts_path %>
      <%= link_to "/comments", comments_path %>
    </div>
  CODE

  %w(blogs posts comments).each do |word|
    gsub_file "app/views/#{word}/_form.html.erb", "form.text_field :user_id ", 'form.text_field :user_id, list: "user_datalist" '
    inject_into_file "app/views/#{word}/_form.html.erb", <<-'CODE', after: "list: \"user_datalist\" %>\n"
    <datalist id="user_datalist">
      <% User.all.each do |user| %>
        <option value="<%= user.id %>"><%= user.username %></option>
      <% end %>
    </datalist>
    CODE

    # gsub_file "app/views/#{word}/index.html.erb", 'colspan="3"', 'colspan="4"' # cancancanと干渉する・・・
    gsub_file "app/views/#{word}/index.html.erb", '<th colspan="3"></th>', "<th colspan=\"3\"></th>\n<th></th>"
    inject_into_file "app/views/#{word}/index.html.erb", <<-"CODE", after: "data: { confirm: 'Are you sure?' } %></td>\n"
        <td>
          <%= form_with model: #{word.singularize}, method: :delete do |form| %>
            <%= form.submit :delete %>
          <% end %>
        </td>
    CODE
  end

  # Blogs
  # gsub_file "app/views/blogs/_form.html.erb", "<%= form.text_field :status %>", "<%= form.select :status, Blog.statuses.keys %>"
  gsub_file "app/views/blogs/_form.html.erb", "<%= form.number_field :status %>", "<%= form.select :status, Blog.statuses.keys %>"
  gsub_file "app/views/blogs/show.html.erb", /^(.*)$/m, <<-'CODE'
\1
<hr/>
<h3>Posts</h3>
<div>
  <% @blog.posts.each do |post| %>
    <p>
      <%= link_to post.title, post %><br/>
    </p>
  <% end %>
</div>
CODE

  # Posts
  gsub_file "app/views/posts/show.html.erb", /^(.*)$/m, <<-'CODE'
  \1
  <hr/>
  <h3>Comments</h3>
  <div>
    <% @post.comments.each do |comment| %>
      <p>
      <span><%= comment.name %></span>
      <span><%= comment.body %></span>
      <%= link_to comment.id, comment %><br/>
      </p>
    <% end %>
  </div>
CODE
end

def configure_tests
  %w(blogs posts comments).each do |word|
    _path = "test/controllers/#{word}_controller_test.rb"
    copy_file "cancancan/#{_path}", _path, force: true
  end
end

def configure_fixtures
  gsub_file "test/fixtures/blogs.yml", /(.*)status: 1/m, '\1status:  0'
end

after_bundle do
  create_models
  configure_models
  configure_contollers
  configure_views
  configure_tests
  configure_fixtures

  git add: "."
  git commit: %Q{ -m 'commit applied simpleblog' }
end
