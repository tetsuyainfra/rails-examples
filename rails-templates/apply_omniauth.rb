# create-user.rb
# TODO: RegistrationControllerのview書き換え username/displaynameがだめぽ

apply "#{__dir__}/apply_devise.rb"

def source_paths
  [Pathname.new(__dir__).join("./devise").to_s,
   Pathname.new(__dir__).join("./omniauth").to_s]
end

# AUTH
# Omniauth 1.X系
gem("omniauth-twitter", "~> 1.3")
gem("omniauth-github", "~> 1.4")
# gem "omniauth-apple", "~> 1.0"
# gem "omniauth-facebook", "~> 8.0"
gem("omniauth")

# Omniauth 2.X系
# gem "omniauth", "~> 2.0"
# gem "omniauth-oauth2"

after_bundle do
  # git add: "."
  # git commit: %Q{ -m 'commit applied Omniauth' }
end
