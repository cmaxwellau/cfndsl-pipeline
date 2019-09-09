# frozen_string_literal: true

require 'cfndsl/globals'
require 'cfndsl/version'
PARAM_PROPS = %w[Description Default AllowedPattern AllowedValues].freeze
HAS_PROPAGATABLE_TAGS = %w[CfnDsl::AWS::Types::AWS_AutoScaling_AutoScalingGroup].freeze
HAS_MAPPED_TAGS = %w[CfnDsl::AWS::Types::AWS_Serverless_Function CfnDsl::AWS::Types::AWS_Serverless_SimpleTable CfnDsl::AWS::Types::AWS_Serverless_Application].freeze

# Automatically add Parameters for Tag values
CfnDsl::CloudFormationTemplate.class_eval do
  def initialize
    return unless defined? external_parameters[:TagStandard]

    # parameters for tagging standard
    external_parameters[:TagStandard].each do |param_name, props|
      logical_name = props['LogicalName'] || param_name
      Parameter(logical_name) do
        Type(props['Type'])
        PARAM_PROPS.each do |key|
          # puts key, props[key]
          send(key, props[key]) if props[key]
        end
      end
    end if external_parameters[:TagStandard].kind_of?(Hash)
  end
end

module CfnDsl
  # extends CfnDsl esource Properties to automatically substitute
  # FnSub recuraively
  class PropertyDefinition < JSONable
    def initialize(value)
      @value = fix_substitutions(value)
    end

    def fix_substitutions(val)
      return val unless defined? val.class.to_s.downcase
      meth = "fix_#{val.class.to_s.downcase}"
      if respond_to?(meth.to_sym)
        return send(meth, val)
      end
      val
    end

    def fix_hash(val)
      val.transform_values! { |item| fix_substitutions item }
    end

    def fix_array(val)
      val.map! { |item| fix_substitutions item }
    end

    ## TODO Need to add exclusion if string is already a propoerty of FnSub...
    def fix_string(val)
      val.include?('${') ? FnSub(val) : val
    end
  end

  # Automatically apply resource tag standard to supported resources (if supplied)
  class ResourceDefinition
    def initialize
      apply_tag_standard
    end

    def apply_tag_standard
      return unless defined? external_parameters[:TagStandard]
      return unless external_parameters[:TagStandard].kind_of?(Hash)

      resource_type = self.class.to_s

      if defined? self.Tag
        external_parameters[:TagStandard].each do |tag_name, props|
          send(:Tag) do
            Key tag_name.to_s
            Value Ref(props['LogicalName'] || tag_name)
            PropagateAtLaunch true if HAS_PROPAGATABLE_TAGS.include? resource_type
          end
        end
      elsif HAS_MAPPED_TAGS.include? resource_type
        tag_map = {}
        external_parameters[:TagStandard].each do |tag_name, props| 
          tag_map[tag_name.to_s] = Ref(props['LogicalName'] || tag_name)
        end
        Tags tag_map
      end
    end
  end
end