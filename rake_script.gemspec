# coding: utf-8

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rake_script/version'

Gem::Specification.new do |spec|
  spec.name = 'rake_script'
  spec.version = RakeScript::VERSION
  spec.authors = ['Denis Talakevich']
  spec.email = 'senid231@gmail.com'
  spec.date = '2019-11-29'

  spec.summary = 'Rake scripts helper for file system and shell commands.'
  spec.description = "Rake scripts helper for file system and shell commands."
  spec.homepage = 'https://github.com/senid231/rake_script'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(\.gitignore|test)/}) }
  spec.require_paths = ['lib']

  spec.add_dependency 'rake'

  spec.add_development_dependency 'minitest', '~> 5.13'
end
