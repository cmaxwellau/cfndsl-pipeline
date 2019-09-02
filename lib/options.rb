# frozen_string_literal: true

module CfnDslPipeline
  class Options
    attr_accessor :aws_region, :validation_bucket, :save_audit_report, :validate_syntax, :save_syntax_report, :validate_cfn_nag, :validate_output, :estimate_cost, :dump_deploy_params, :cfn_nag
    def initialize()
      self.aws_region='ap-southeast-2'
      self.validation_bucket=''
      self.validate_cfn_nag=true
      self.validate_syntax=true
      self.estimate_cost=false
      self.save_syntax_report=false
      self.dump_deploy_params=true
      self.save_audit_report=false
      self.cfn_nag = CfnNagConfig.new(
        print_suppression: false,
        fail_on_warnings: true
      )
    end
  end
end

