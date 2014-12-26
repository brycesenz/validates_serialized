# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'validates_serialized/version'

Gem::Specification.new do |spec|
  spec.name = "validates_serialized"
  spec.version = ValidatesSerialized::VERSION
  spec.authors = ["brycesenz"]
  spec.email = ["bryce.senz@gmail.com"]
  spec.description = %q{Validation for serialized model objects}
  spec.summary = %q{An ActiveModel enhancement that allows for better validation of serialized objects in Ruby}
  spec.homepage = "https://github.com/brycesenz/validates_serialized"
  spec.license = "MIT"

  spec.files = `git ls-files`.split($/)
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activemodel", ">= 4.0.0"
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "sqlite3", "~> 1.3"
  spec.add_development_dependency "rake", "~> 10.1"
  spec.add_development_dependency "rspec", "~> 2.6"
end
