# -*- encoding: utf-8 -*-
require File.expand_path('../lib/mods/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "mods"
  gem.authors       = ["Naomi Dushay", "Bess Sadler"]
  gem.version       = Mods::VERSION
  gem.email         = ["ndushay AT stanford.edu", "bess AT stanford.edu"]
  gem.description   = %q{A Ruby gem to parse MODS (Metadata Object Description Schema) records}
  gem.summary       = %q{A Ruby gem to parse MODS (Metadata Object Description Schema) records.  More information about MODS can be found at http://www.loc.gov/standards/mods/registry.php.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  
  # Runtime dependencies
  gem.add_dependency 'nokogiri'

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
