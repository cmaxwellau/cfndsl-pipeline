# cfndsl-pipeline

This ruby gem provides an integrated CfnDsl CloudFormation template generation pipeline that integrates resaource tagging standards, cfn_nag linting, AWS template syntax validation, and AWS template costing (where possible), and generates `aws cloudformation deploy` compatible parameter files.

## Bash Usage:
```shell
$ cfndsl_pipeline
Usage: cfndsl_pipeline -t input file -o output dir [ -b bucket | -p | -c ] [include1 include2 etc]
    -t, --template file              Input file
    -o, --output dir                 Output directory
    -b, --bucket                     Existing S3 bucket for cost estimation and large template syntax validation
        --disable-syntax             Enable syntax check
    -p, --params                     Create cloudformation deploy compatible params file
        --disable-nag                Enable cfn_nag 
        --syntax-report              Save template syntax report
        --audit-report               Save cfn_nag audit report
    -c, --estimate                   Generate URL for AWS simple cost calculator
    -h, --help                       show this message
    -v, --version                    show the version
```

## Ruby Usage
```ruby
require 'cfndsl-pipeline'

opts = CfnDslPipeline::Options.new
opts.validation_bucket=   'my-s3-bucket'
opts.validate_cfn_nag=    true
opts.validate_syntax=     true
opts.dump_deploy_params=  false
opts.estimate_cost=       false
opts.save_syntax_report=  false
opts.save_audit_report=   false

output_dir='cloudformation'
input_file='my-cfndsl-template.rb'
cfndsl_extras = [[:yaml, 'standard_tags.yaml']]

pipeline=CfnDslPipeline::Pipeline.new(output_dir, opts)
pipeline.build(input_file, cfndsl_extras)
```


## Tag standards
These are implemented as a simple YAML file. CFNDSL has been extended to generate the appropriate template inputs for each tag key for you, as well as automatically tagging each and every resource that supports tags. All DSL properties of the parameters are supported, in addition to a logical name to use for the parameter key.

```yaml
---
TagStandard:
  MyCostCode:
    Default: 'MC68EC020'
    Type: String
    AllowedPattern: 'MC[0-9]{2}[A-Z]{2}[0-9]{3}'
    LogicalName: CostCentre
