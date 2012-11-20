#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'rake'
require 'rake/testtask'
require 'rspec'
require 'rspec/core/rake_task'
require 'rubygems/package_task'

RSpec::Core::RakeTask.new("spec") do |spec|
  spec.pattern = "spec/**/*_spec.rb"
end

desc "Run the Integration Specs (rendering)"
RSpec::Core::RakeTask.new("spec:integration") do |spec|
  spec.pattern = "spec/unit/*_spec.rb"
end

desc "Run the Unit Specs"
RSpec::Core::RakeTask.new("spec:unit") do |spec|
  spec.pattern = "spec/unit/*_spec.rb"
end

desc "Run all the specs without all the verbose spec output"
RSpec::Core::RakeTask.new('spec:progress') do |spec|
  spec.rspec_opts = %w(--format progress)
  spec.pattern = "spec/**/*_spec.rb"
end

Rake::TestTask.new(:test) do |t|
  t.libs << '.' << 'lib' << 'test'
  t.test_files = FileList['test/liquid/**/*_test.rb']
  t.verbose = false
end

task :default => [:spec, :test]

gemspec = eval(File.read('locomotive_liquid.gemspec'))

Gem::PackageTask.new(gemspec) do |pkg|
  pkg.gem_spec = gemspec
end

desc "Build the gem and release it to rubygems.org"
task :release => :gem do
  puts "Tagging #{gemspec.version}..."
  system "git tag -a #{gemspec.version} -m 'Tagging #{gemspec.version}'"
  puts "Pushing to Github..."
  system "git push --tags"
  puts "Pushing to rubygems.org..."
  system "gem push pkg/#{gemspec.name}-#{gemspec.version}.gem"
end

namespace :benchmark do

  desc "Run the liquid benchmark"
  task :run do
    ruby "./performance/benchmark.rb"
  end

end

namespace :profile do

  desc "Run the liquid profile/performance coverage"
  task :run do
    ruby "./performance/profile.rb"
  end

  desc "Run KCacheGrind"
  task :grind => :run  do
    system "qcachegrind /tmp/liquid.rubyprof_calltreeprinter.txt"
  end

end

desc "Run example"
task :example do
  ruby "-w -d -Ilib example/server/server.rb"
end
