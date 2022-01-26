#!/usr/bin/env rake
require "bundler/gem_tasks"

require 'rake'
require 'bundler'

require 'rspec/core/rake_task'
require 'yard'
require 'yard/rake/yardoc_task'
require 'rubocop/rake_task'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

task :default => :ci  

desc "run continuous integration suite (lint, tests, coverage, docs)" 
task :ci => [:rubocop, :rspec, :doc]

task :spec => :rspec

RSpec::Core::RakeTask.new(:rspec) do |spec|
  spec.rspec_opts = ["-c", "-f progress", "--tty", "-r ./spec/spec_helper.rb"]
end

RuboCop::RakeTask.new(:rubocop) do |task|
  task.requires << 'rubocop-rspec'
  task.options = ['--fail-level', 'error']
end

# Use yard to build docs
begin
  project_root = File.expand_path(File.dirname(__FILE__))
  doc_dest_dir = File.join(project_root, 'doc')

  YARD::Rake::YardocTask.new(:doc) do |yt|
    yt.files = Dir.glob(File.join(project_root, 'lib', '**', '*.rb')) +
                 [ File.join(project_root, 'README.rdoc') ]
    yt.options = ['--output-dir', doc_dest_dir, '--readme', 'README.rdoc', '--title', 'Ruby Mods Gem Documentation']
  end
rescue LoadError
  desc "Generate YARD Documentation"
  task :doc do
    abort "Please install the YARD gem to generate rdoc."
  end
end  
