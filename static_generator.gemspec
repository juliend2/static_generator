# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "static_generator/version"

Gem::Specification.new do |s|
  s.name        = "static_generator"
  s.version     = StaticGenerator::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Julien Desrosiers"]
  s.email       = ["hello@juliendesrosiers.com"]
  s.homepage    = ""
  s.summary     = %q{Crawler that generates a file structure that can be served by Apache without any change}
  s.description = %q{Crawl a site with 'clean-URLs' and generate a files and folders from it. Example: the URL /page will become /page/index.html instead of /page.html so you can serve it straight from Apache and all the links are still working.}

  s.rubyforge_project = "static_generator"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec", "~> 2.4.0"
  s.add_development_dependency "fakeweb", "~> 1.3.0"
  s.add_development_dependency "awesome_print", "~> 0.3.2"

  s.add_dependency "anemone", "~> 0.5.0"
end
