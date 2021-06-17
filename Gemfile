source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 6.1.3', '>= 6.1.3.2'
# Use mysql as the database for Active Record
gem 'mysql2', '~> 0.5'
# Use Puma as the app server
gem 'puma', '~> 5.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
end

group :development do
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

gem 'dotenv-rails', '~> 2.7', groups: %i[development test]

gem 'rspec-rails', '~> 5.0', groups: %i[development test]

gem 'rubocop', '~> 1.17', group: :development

gem 'rubocop-performance', '~> 1.11', group: :development

gem 'rubocop-rails', '~> 2.10', group: :development

gem 'rubocop-rspec', '~> 2.4', group: :development

gem 'annotate', '~> 3.1', group: :development

gem 'factory_bot_rails', '~> 6.2', groups: %i[development test]

gem 'rubycritic', '~> 4.6', groups: %i[development test]

gem 'ffaker', '~> 2.18', groups: %i[development test]

gem 'pry-rails', '~> 0.3.9', groups: %i[development test]
