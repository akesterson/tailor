# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tailor/version'

Gem::Specification.new do |spec|
  spec.name          = "tailor"
  spec.version       = Tailor::VERSION
  spec.authors       = ["Andrew Kesterson"]
  spec.email         = ["andrew@aklabs.net"]
  spec.summary       = "A GUI toolkit and library for working with image tilesets"
  spec.description   = ""
  spec.homepage      = "https://github.com/akesterson/tailor/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_dependency "wxruby-ruby19"
end
