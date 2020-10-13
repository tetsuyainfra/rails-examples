# create-user.rb
gem("devise")
gem("pg")
# generate(:scaffold, "Us name:string")
# route "root to: 'people#index'"
# rails_command("db:migrate")

file 'config/database.yml', <<-CODE, {force: true }
default: &default
  adapter: postgresql
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  timeout: 5000
  username: <%= ENV.fetch("POSTGRES_USER") { "postgres" } %>
  password: <%= ENV.fetch("POSTGRES_PASSWORD") { "password" } %>
  host: localhost
  port: 25432

development:
  <<: *default
  database: rails_development

test:
  <<: *default
  database: rails_test

production:
  <<: *default
  database: rails_production
CODE


after_bundle do
  # git :init
  # git add: "."
  # git commit: %Q{ -m 'Initial commit' }
end