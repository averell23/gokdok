$: << File.dirname(__FILE__)
require 'meta_project'
require 'rake'
require 'rake/clean'
require 'rake/rdoctask'
require 'jeweler'
load 'gokdok.gemspec'

require 'lib/gokdok'

CLEAN.include("pkg", "lib/*.bundle", "html", "*.gem", ".config")

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_files.include("lib/**/*rb")
  rdoc.rdoc_files.include('LICENSE', 'CHANGES', 'README.rdoc')
  rdoc.main = "README.rdoc"
  rdoc.title = "Watchdogger Documentation"
  rdoc.options << '--line-numbers' << '--inline-source'
end

Jeweler::Tasks.new do |s|
  s.name = "gokdok"
  s.summary = "Upload your RDoc documentation to GitHub pages."
  s.email = "ghub@limitedcreativity.org"
  s.homepage = "http://averell23.github.com/gokdok"
  s.description = "Allows you to automatically push your RDoc documentation to GitHub."
  s.authors = ["Daniel Hahn"]
  s.files = FileList["{lib}/**/*"]
  s.extra_rdoc_files = ["README.rdoc", "CHANGES", "LICENSE", "sample_config.yml"]
  s.add_dependency('grit', '>= 1.1.1')
end

Rake::Gokdok.new do |gd|
  gd.repo_url = 'git@github.com:averell23/watchdogger.git'
  gd.remote_path = 'html'
end
