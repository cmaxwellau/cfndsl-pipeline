# frozen_string_literal: true.

$LOAD_PATH.unshift(File.dirname(__FILE__) + "/lib")
require "version" 

Gem::Specification.new do |s|
  s.name = %q(cfndsl-pipeline)
  s.authors = [
  	"Cam Maxwell"
  ]
  s.homepage = 'https://github.com/cmaxwellau/cfndsl-pipeline.git'
  s.email = 'cameron.maxwell@gmail.com'
  s.version = CfnDslPipeline::VERSION
  s.date = %q(2019-08-13)
  s.summary = %q(Integrated build pipeline for building CloudFormation with CfnDsl)
  s.description = %q(Integrated CfnDsl CloudFormation template generation pipeline that integrates cfn_nag, AWS template validation, and AWS template costing (where possible), and generated `aws cloudformation deploy` compatible parameters files)
  s.license = 'MIT'
  s.files = [
    'lib/pipeline.rb',
    'lib/cfndsl.rb',
    'lib/cfn_nag.rb',
    'lib/options.rb',
    'lib/params.rb',
    'lib/syntax.rb',
    'lib/monkey_patches.rb',
    'lib/stdout_capture.rb',
    'lib/version.rb'
  ]
  s.require_paths = ["lib"]
  s.required_ruby_version = '>= 2.4.1'
  s.add_dependency('cfn-nag', '0.4.35')
  s.add_dependency('cfndsl', '0.17.0')
  s.add_dependency('aws-sdk-cloudformation', '1.25.0')
  s.add_dependency('aws-sdk-s3', '1.46.0')
  s.add_dependency('uuid', '2.3.9')
  s.bindir = 'bin'
  s.executables << 'cfndsl_pipeline'  
end

