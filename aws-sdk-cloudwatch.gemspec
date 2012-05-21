Gem::Specification.new do |s|
  s.name = 'aws-sdk-cloudwatch'
  s.version = '0.0.0'
  s.date = '2012-05-21'
  s.summary = 'AWS CloudWatch API support'
  s.description = 'Extends the original aws-sdk gem from Amazon with support for the CloudWatch API'
  s.authors = ['Rafał Rzepecki']
  s.email = 'divided.mind@gmail.com'
  s.files = Dir['lib/aws/**/*.rb'] + Dir['lib/aws/api_config/*.yml']
#  s.homepage = ' TODO '
  s.add_runtime_dependency 'aws-sdk', '~> 1.3', '>= 1.3.9'
end
