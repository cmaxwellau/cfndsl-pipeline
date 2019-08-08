Gem::Specification.new do |s|
  s.name = %q{cfndsl-pipeline}
  s.authors = [
  	"Cam Maxwell"
  ]
  s.version = "0.0.5"
  s.date = %q{2019-08-07}
  s.summary = %q{Integrated build pipeline for building CloudFormation with CFNDSL}
  s.files = [
    'lib/cfndsl-pipeline.rb',
    'lib/cp-cfndsl.rb',
    'lib/cp-cfn_nag.rb',
    'lib/cp-options.rb',
    'lib/cp-params.rb',
    'lib/cp-syntax.rb',
    'lib/monkey-patches.rb',
    'lib/stdout-capture.rb'
  ]
  s.require_paths = ["lib"]
end
