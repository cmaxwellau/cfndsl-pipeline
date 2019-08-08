module CfnDslPipeline
  class Options
    attr_accessor :aws_region, :validation_bucket, :validate_syntax, :validate_cfn_nag, :validate_output, :estimate_cost, :dump_deploy_params
    def initialize()
      self.aws_region='ap-southeast-2'
      self.validation_bucket=''
      self.validate_cfn_nag=true
      self.validate_syntax=true
      self.estimate_cost=false
      self.dump_deploy_params=true
    end
  end
end

