# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "aws-sdk-cloudwatch"
  s.version     = '0.0.0'
  s.authors     = ["Rafał Rzepecki"]
  s.email       = ["divided.mind@gmail.com"]
  s.homepage    = ""
  s.summary = 'AWS CloudWatch API support'
  s.description = 'Extends the original aws-sdk gem from Amazon with support for the CloudWatch API'

  s.rubyforge_project = "aws-sdk-cloudwatch"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'aws-sdk', '~> 1.3', '>= 1.3.9'
  s.add_development_dependency 'bundler', '~> 1.0', '>= 1.0.15'
  s.add_development_dependency 'rspec', '~> 2.10'
end
