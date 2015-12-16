source 'https://rubygems.org'

ruby '2.2.2', :engine => 'jruby', :engine_version => '9.0.1.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.4'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyrhino'
# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'puma'
gem 'restforce'
gem 'omniauth-salesforce'
gem 'maestrano-connector-rails', :path => '../maestrano-connector-rails'
gem 'figaro'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'haml-rails'
gem 'deepstruct'

gem 'bootstrap-sass'
gem 'autoprefixer-rails'


group :production do
  gem 'rails_12factor'
  gem 'activerecord-jdbcpostgresql-adapter'
  gem 'delayed_job_active_record'
end

group :test, :develpment do
  gem 'activerecord-jdbcsqlite3-adapter'
end

group :test do
  gem 'simplecov'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'shoulda-matchers'
  gem 'timecop'
end