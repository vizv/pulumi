# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'pulumi/version'

Gem::Specification.new do |spec|
  spec.name          = 'pulumi'
  spec.version       = Pulumi::VERSION
  spec.authors       = ['Wenxuan Zhao']
  spec.email         = ['wenxuan.zhao@viz.software']

  spec.summary       = 'Pulumi SDK'
  spec.description   = 'Pulumi\'s Ruby SDK'
  spec.homepage      = 'https://pulumi.io'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata = { 'source_code_uri' => 'https://github.com/vizv/pulumi' }

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features|cmd|ruby)/|\A(Makefile|\.git.*)\z}) }
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{\Abin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rubocop', '~> 1.0'
  spec.add_development_dependency 'rubocop-rake', '~> 0.0'

  spec.add_dependency 'zeitwerk', '~> 2.0'
end
