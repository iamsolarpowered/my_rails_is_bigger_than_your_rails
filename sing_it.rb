#FIXME: The next release of Rails should have an after_bundle method that actually works.
def after_bundle
  begin
    super
  rescue NoMethodError => e
    say "If the command below fails, you'll have to run it on your own until Rails 4.2 comes out.", [:red, :on_white, :bold]
    yield
  end
end

# Let's see, we want...

# A better web server
gem 'thin'

# Haml
gem 'haml'

# Bootstrap
gem 'bootstrap-sass'
run 'mv app/assets/stylesheets/application.css app/assets/stylesheets/application.css.scss'
append_file 'app/assets/stylesheets/application.css.scss', <<-END

  @import "bootstrap-sprockets";
  @import "bootstrap";
END

# Angular
bower_installed = run 'bower help -s'
run 'npm install bower' unless bower_installed
gem 'bower-rails'
create_file 'Bowerfile', "asset 'angular'"
after_bundle do
  rake 'bower:install'
end
inject_into_file 'app/assets/javascripts/application.js', "//= require angular/angular\n", before: '//= require_tree .'
gsub_file 'app/assets/javascripts/application.js', "//= require turbolinks\n", '' # remove turbolinks

# Guard and Foreman
gem_group :development do
  gem 'guard-livereload', require: false
  gem 'guard-minitest', require: false
  gem 'foreman'
end
create_file 'Procfile', <<-END
web:    bundle exec rails s
guard:  bundle exec guard
END
after_bundle do
  run 'bundle exec guard init'
end

# kick-ass testing tools
gem_group :test do
  gem 'factory_girl_rails'
  gem 'minitest-spec-rails'
  gem 'capybara_minitest_spec'
  gem 'capybara-webkit'
  gem 'launchy'
  # gem 'jasmine'
end
append_file 'test/test_helper.rb', <<-END
\n\n
require 'minitest/autorun'
require 'capybara/rails'

module ActionDispatch
  class IntegrationTest
    include Capybara::DSL
    Capybara.current_driver = :webkit
  end
end
END

