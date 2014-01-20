lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wrap_it/version'

Gem::Specification.new do |spec|
  spec.name          = 'wrap_it'
  spec.version       = WrapIt::VERSION
  spec.authors       = ['Alexey Ovchinnikov']
  spec.email         = ['alexiss@cybernetlab.ru']
  spec.description   = %q{Set of classes and modules for creating HTML helpers}
  spec.summary       = <<-EOL.gsub(/^\s+\|/, '')
    |This library provides set of classes and modules with simple DSL for quick
    |and easy creating html helpers with your own DSL. It's usefull for
    |implementing CSS frameworks, or making your own.
  EOL
  spec.homepage      = 'https://github.com/cybernetlab/wrap_it'
  spec.license       = 'MIT'
  spec.metadata      = {
    'issue_tracker' => 'https://github.com/cybernetlab/wrap_it/issues'
  }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 10.1'
  spec.add_development_dependency 'redcarpet', '~> 1.17'
  spec.add_development_dependency 'yard', '~> 0.8'
  spec.add_development_dependency 'rspec', '~> 2.14'
  spec.add_development_dependency 'rspec-html-matchers', '~> 0.4'
end
