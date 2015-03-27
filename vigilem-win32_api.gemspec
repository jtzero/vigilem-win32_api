# -*- encoding: utf-8 -*-
require './lib/vigilem/win32_api/version'

Gem::Specification.new do |s|
  s.name          = 'vigilem-win32_api'
  s.version       = Vigilem::Win32API::VERSION
  s.platform      = Gem::Platform::RUBY
  s.summary       = 'Windows API Bindings and DOM converter for Vigilem'
  s.description   = 'Windows API Bindings and DOM converter for Vigilem'
  s.authors       = ['jtzero']
  s.email         = 'jtzero511@gmail'
  s.homepage      = 'http://rubygems.org/gems/vigilem-win_api'
  s.license       = 'MIT'
  
  s.add_dependency 'vigilem-core', '~> 0.1.0'
  s.add_dependency 'vigilem-dom'
  
  s.add_development_dependency 'yard'
  s.add_development_dependency 'bundler', '~> 1.7'
  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'rspec', '~> 3.1'
  s.add_development_dependency 'rspec-given'
  s.add_development_dependency 'turnip'
  s.add_development_dependency 'guard-rspec'
    
  s.files         = Dir['{lib,spec,ext,test,features,bin}/**/**'] + ['LICENSE.txt']
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']
end
