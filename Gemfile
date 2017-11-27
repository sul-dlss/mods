source 'https://rubygems.org'

# See mods.gemspec for this gem's dependencies
gemspec

group :test do
  gem 'coveralls', require: false
end

# Pin to activesupport 4.x for older versions of ruby
gem 'activesupport', '~> 4.2' if RUBY_VERSION < '2.2.2'
gem 'byebug'
