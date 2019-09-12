# frozen_string_literal: true
require 'cfn-nag/custom_rule_loader'
require 'cfn-nag/cfn_nag_config'

module CfnDslPipeline
  #
  class Options
    attr_accessor :aws_region, :validation_bucket, :estimate_cost, :dump_deploy_params, :cfn_nag
    attr_accessor :validate_cfn_nag, :save_audit_report, :validate_syntax, :save_syntax_report, :validate_output
    attr_accessor :debug_audit, :debug_pipeline, :debug_cfndsl
    def initialize
      self.aws_region         = ENV['AWS_REGION'] || 'ap-southeast-2'
      self.validation_bucket  = ''
      self.validate_cfn_nag   = false
      self.validate_syntax    = false
      self.estimate_cost      = false
      self.save_syntax_report = false
      self.dump_deploy_params = false
      self.save_audit_report  = false
      self.debug_pipeline     = false
      self.debug_cfndsl       = false
      self.debug_audit        = false
      self.cfn_nag = CfnNagConfig.new(
        print_suppression: false,
        fail_on_warnings: true
      )
    end
  end
end
