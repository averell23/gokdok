# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{gokdok}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Daniel Hahn"]
  s.date = %q{2009-07-17}
  s.description = %q{Allows you to automatically push your RDoc documentation to GitHub.}
  s.email = %q{ghub@limitedcreativity.org}
  s.extra_rdoc_files = ["README.rdoc", "CHANGES", "LICENSE"]
  s.files = ["lib/gokdok.rb", "README.rdoc", "CHANGES", "LICENSE"]
  s.has_rdoc = true
  s.homepage = %q{http://averell23.github.com/gokdok}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Upload your RDoc documentation to GitHub pages.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<grit>, [">= 1.1.1"])
    else
      s.add_dependency(%q<grit>, [">= 1.1.1"])
    end
  else
    s.add_dependency(%q<grit>, [">= 1.1.1"])
  end
end
