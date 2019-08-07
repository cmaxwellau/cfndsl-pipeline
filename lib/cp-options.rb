module CfnDsl
  class Pipeline
    class Options
      @aws_region='ap-southeast-2'
      @validation_bucket=''
      @validate_cfn_nag=true
      @validate_syntax=true 
      @estimate_cost=false
      @dump_deploy_params=true

      class << self
        attr_accessor :aws_region, :validation_bucket, :linter, :validate_output, :estimate_cost, :dump_deploy_params
      end

      def initialize(
          aws_region: false, 
          validation_bucket:false,
          validate_cfn_nag:false, 
          validate_syntax:false,
          estimate_cost:false, 
          dump_deploy_params:false)
        @aws_region=aws_region?
        @validation_bucket=validation_bucket?
        @validate_cfn_nag=validate_cfn_nag?
        @validate_syntax=validate_syntax?
        @estimate_cost=estimate_cost?
        @dump_deploy_params=dump_deploy_params?
      end
    end
  end
end

