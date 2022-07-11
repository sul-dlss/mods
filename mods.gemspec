# -*- encoding: utf-8 -*-
require File.expand_path('../lib/mods/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "mods"
  gem.version       = Mods::VERSION
  gem.authors       = ["Naomi Dushay", "Bess Sadler"]
  gem.email         = ["ndushay AT stanford.edu", "bess AT stanford.edu"]
  gem.description   = "Parse MODS (Metadata Object Description Schema) records.  More information about MODS can be found at http://www.loc.gov/standards/mods/"
  gem.summary       = "Parse MODS (Metadata Object Description Schema) records."
  gem.homepage      = "https://github.com/sul-dlss/mods"

  gem.extra_rdoc_files = ["LICENSE", "README.md"]
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^spec/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'nokogiri', '>= 1.6.6'
  gem.add_dependency 'nom-xml', '~> 1.0'
  gem.add_dependency 'iso-639'
  gem.add_dependency 'edtf', '~> 3.0.8'

  # Runtime dependencies
  # gem.add_runtime_dependency 'nokogiri'

  # Development dependencies
  # Bundler will install these gems too if you've checked out solrmarc-wrapper source from git and run 'bundle install'
  # It will not add these as dependencies if you require solrmarc-wrapper for other projects
  gem.add_development_dependency "rake"
  # docs
  gem.add_development_dependency "rdoc"
  gem.add_development_dependency "yard"
  # tests
  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'simplecov', '~> 0.17.0' # CodeClimate cannot use SimpleCov >= 0.18.0 for generating test coverage
  # gem.add_development_dependency 'ruby-debug19'
  gem.add_development_dependency 'equivalent-xml'
end
