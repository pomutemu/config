gem "aasm"
gem "active_model_serializers"
gem "activerecord-session_store"
gem "faraday"
gem "figaro"
gem "omniauth"
gem "responders"
gem "ridgepole"

gem "bower-rails"
gem "hamlit"
gem "kaminari"
gem "simple_form"

gem_group :development do
  gem "hirb-unicode"
  gem "pry-rails"
end

gem_group :test do
  gem "autodoc"
  # gem "bullet"
  gem "database_rewinder"
  gem "factory_girl_rails"
  gem "rspec-rails"
  gem "rspec-request_describer"
end

run_bundle

application do
  <<-_RUBY_
config.generators do |g|
      g.assets false
      g.helper false
      g.migration false
      g.skip_routes true
      g.template_engine false
      g.test_framework false
    end

    config.secret_key_base = Figaro.env.secret_key_base
  _RUBY_
end

generate "active_record:session_migration"
generate "rspec:install"

generate "bower_rails:initialize"
generate "simple_form:install"

gsub_file "./config/initializers/session_store.rb", "Rails.application.config.session_store :cookie_store" do
  "Rails.application.config.session_store :active_record_store"
end

inject_into_file "./spec/rails_helper.rb", after: "RSpec.configure do |config|" do
  <<-_RUBY_

  config.include FactoryGirl::Syntax::Methods
  config.include RSpec::RequestDescriber

  config.before :suite do
    # Bullet.enable = true
    # Bullet.raise = true
    DatabaseRewinder.clean_all
    FactoryGirl.reload
  end

  config.before :each do
    # Bullet.start_request
  end

  config.after :each do
    # Bullet.end_request
    DatabaseRewinder.clean
  end
  _RUBY_
end

rake "db:migrate RAILS_ENV=development"
rake "db:migrate RAILS_ENV=test"

run "bundle e ridgepole --export -c ./config/database.yml -o ./Schemafile -E development"

rakefile "autodoc.rake" do
  <<-_RUBY_
namespace :autodoc do
  task :default do
    sh "AUTODOC=1 bundle e rspec ./spec/requests"
  end
end
  _RUBY_
end

rakefile "ridgepole.rake" do
  <<-'_RUBY_'
namespace :ridgepole do
  RIDGEPOLE = "bundle e ridgepole -c ./config/database.yml -f ./Schemafile"

  task :check do
    sh "#{RIDGEPOLE} --apply --dry-run -E '#{Rails.env}'"

    if Rails.env == "development"
      sh "#{RIDGEPOLE} --apply --dry-run -E test"
    end
  end

  task :apply do
    sh "#{RIDGEPOLE} --apply -E '#{Rails.env}'"

    if Rails.env == "development"
      sh "#{RIDGEPOLE} --apply -E test"

      sh "bundle e rake db:schema:dump 'RAILS_ENV=#{Rails.env}'"
    end
  end
end
  _RUBY_
end

append_file "./.gitignore", <<-_GITIGNORE_

/config/application.yml
_GITIGNORE_

remove_file "./README.rdoc"
remove_file "./config/secrets.yml"
remove_file "./db/seeds.rb"
