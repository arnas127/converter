# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'currency_manager/version'

Gem::Specification.new do |spec|
  spec.name          = 'currency_manager'
  spec.version       = CurrencyManager::VERSION
  spec.authors       = ['Arnas Rutkauskas']
  spec.email         = ['arnas127@gmail.com']

  spec.summary       = %q{Currency managment}
  spec.description   = %q{Operate with currencies by your defined rates}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
