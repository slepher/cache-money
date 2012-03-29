# -*- encoding: utf-8 -*-
#require File.join(File.dirname(__FILE__), 'lib/cash/version')

Gem::Specification.new do |s|
  s.name = %q{cache-money}
  #s.version = Cash::VERSION
  s.version = "1.0.0"

  s.required_rubygems_version = '1.3.7'
  s.authors = ["Nick Kallen", "Ashley Martens", "Scott Mace", "John O'Neill"]
  s.date = Date.today.to_s
  s.description = %q{Write-through and Read-through Cacheing for ActiveRecord}
  s.email = %q{teamplatform@ngmoco.com}
  s.extra_rdoc_files = [
    "LICENSE",
    "README",
    "README.markdown",
    "TODO"
  ]
  s.files = Dir[
    "README",
    "TODO",
    "UNSUPPORTED_FEATURES",
    "lib/**/*.rb",
    "rails/init.rb",
    "init.rb"
  ]
  s.homepage = %q{http://github.com/ngmoco/cache-money}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Write-through and Read-through Cacheing for ActiveRecord}
  s.test_files = Dir[
    "config/*",
    "db/schema.rb",
    "spec/**/*.rb"
  ]

  s.add_runtime_dependency(%q<activerecord>, [">= 3.0.0"])
  s.add_runtime_dependency(%q<activesupport>)
  s.add_runtime_dependency(%q<actionpack>)
  #s.add_runtime_dependency(%q<memcached>) # sudo apt-get install libsasl2-dev
  #s.add_runtime_dependency(%q<jeweler>, [">= 1.4.0"])

  s.add_development_dependency(%q<rake>)
  s.add_development_dependency(%q<ruby-debug>, ["~> 0.10.0"])
  s.add_development_dependency(%q<rspec>, ["~> 1.3.0"])
  s.add_development_dependency(%q<sqlite3-ruby>)
  s.add_development_dependency(%q<rr>)
end

