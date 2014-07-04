name = "test_after_commit"
require "./lib/#{name}/version"

Gem::Specification.new name, TestAfterCommit::VERSION do |s|
  s.summary = "makes after_commit callbacks testable in Rails 3+ with transactional_fixtures"
  s.authors = ["Michael Grosser"]
  s.email = "michael@grosser.it"
  s.homepage = "https://github.com/grosser/#{name}"
  s.files = `git ls-files lib`.split("\n")
  s.license = 'MIT'

  s.add_runtime_dependency "activerecord", ">= 3.2"

  s.add_development_dependency "wwtd"
  s.add_development_dependency "bump"
  s.add_development_dependency "rake"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec"
end
