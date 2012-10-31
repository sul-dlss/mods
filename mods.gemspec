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

  gem.extra_rdoc_files = ["LICENSE", "README.rdoc"]
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  
  gem.add_dependency 'nokogiri'

  # Runtime dependencies
  # gem.add_runtime_dependency 'glah'

  # Bundler will install these gems too if you've checked out solrmarc-wrapper source from git and run 'bundle install'
  # It will not add these as dependencies if you require solrmarc-wrapper for other projects
  gem.add_development_dependency "rake"
  # docs
  gem.add_development_dependency "rdoc"
  gem.add_development_dependency "yard"
  # tests
	gem.add_development_dependency 'rspec'
	gem.add_development_dependency 'simplecov'
	gem.add_development_dependency 'simplecov-rcov'
	# gem.add_development_dependency 'ruby-debug19'
  
end
