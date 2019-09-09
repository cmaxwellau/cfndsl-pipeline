# frozen_string_literal: true.

$LOAD_PATH.unshift(File.dirname(__FILE__) + "/lib")
require "version" 

Gem::Specification.new do |s|
  s.name = %q(cfndsl-pipeline)
  s.authors = [
  	"Cam Maxwell"
  ]
  s.homepage              = 'https://github.com/cmaxwellau/cfndsl-pipeline.git'
  s.author                = 'Cam Maxwell'
  s.email                 = 'cameron.maxwell@gmail.com'
  s.version               = CfnDslPipeline::VERSION
  s.date                  = %q(2019-08-19)
  s.summary               = %q(Integrated build pipeline for building CloudFormation with CfnDsl)
  s.description           = %q(Integrated CfnDsl CloudFormation template generation pipeline that integrates cfn_nag, AWS template validation, and AWS template costing (where possible), and generated `aws cloudformation deploy` compatible parameters files)
  s.license               = 'MIT'
  s.files                 = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  s.require_paths         = ["lib"]
  s.required_ruby_version = '>= 2.4.1'
  s.bindir                = 'bin'
  s.add_dependency('cfn-nag', '~> 0.4')
  s.add_dependency('cfndsl', '~> 0.17')
  s.add_dependency('aws-sdk-cloudformation', '~> 1')
  s.add_dependency('aws-sdk-s3', '~> 1')
  s.add_dependency('uuid', '~> 2.3')
  s.add_dependency('colorize', '~> 0.8')
  s.executables << 'cfndsl_pipeline'  
end

