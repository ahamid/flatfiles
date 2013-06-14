$:.push File.expand_path("lib", File.dirname(__FILE__))
require "flatfiles/version"

Gem::Specification.new do |s|
  s.name = "flatfiles"
  s.version = FlatFiles::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors = ["Aaron Hamid"]
  s.email = [ "aaron.hamid@gmail.com" ]
  s.homepage = %q{http://github.com/ahamid/flatfiles}
  s.summary = %q{Flat-file parsing library}
  s.description = %q{Flat-file parsing library}
  s.files = Dir.glob("{bin,lib}/**/*") + %w(README.rdoc)
  s.test_files = Dir.glob("{test}/**/*.rb")
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.require_paths = ["lib"]
  s.add_runtime_dependency("json_pure", [">= 0"])
  s.add_runtime_dependency("i18n", [">= 0"])
  s.add_runtime_dependency("bindata", [">= 0"])
  s.add_runtime_dependency("axiom", [">= 0"])
  s.add_runtime_dependency("factory_girl", [">= 0"])
  s.add_runtime_dependency("faker", [">= 0"])
  s.add_development_dependency("bundler")
  s.add_development_dependency("rake")
  s.add_development_dependency("rspec", [">= 0"])
  s.add_development_dependency("rdoc", [">= 0"])
  s.add_development_dependency("simplecov")
  s.add_development_dependency("turn")
  s.add_development_dependency("ruby-prof")
  s.add_development_dependency("ruby-debug19")
end
