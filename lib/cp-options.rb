module CfnDsl
  class PipelineOptions
    @aws_region='ap-southeast-2'
    @validation_bucket=''
    @validate_cfn_nag=true
    @validate_syntax=true 
    @estimate_cost=false
    @dump_deploy_params=true

    class << self
      attr_accessor :aws_region, :validation_bucket, :linter, :validate_output, :estimate_cost, :dump_deploy_params
    end
  end
end