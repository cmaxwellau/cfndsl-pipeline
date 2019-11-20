# frozen_string_literal: true

require 'cfndsl/globals'
require 'cfndsl/version'
require 'cfndsl/external_parameters'
require 'cfndsl/aws/cloud_formation_template'

PARAM_PROPS = %w([Description Default AllowedPattern AllowedValues]).freeze
HAS_PROPAGATABLE_TAGS = %w([CfnDsl::AWS::Types::AWS_AutoScaling_AutoScalingGroup]).freeze
# rubocop:disable Metrics/LineLength
HAS_MAPPED_TAGS = %w([CfnDsl::AWS::Types::AWS_Serverless_Function CfnDsl::AWS::Types::AWS_Serverless_SimpleTable CfnDsl::AWS::Types::AWS_Serverless_Application]).freeze
# rubocop:enable Metrics/LineLength

# Automatically add Parameters for Tag values
CfnDsl::CloudFormationTemplate.class_eval do
  def initialize
    return unless external_parameters&.fetch(:TagStandard) && external_parameters[:TagStandard].is_a?(Hash)

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
    end
  end
end

module CfnDsl
  # Add ability to reset params when being used in loops in rakefiles etc
  class ExternalParameters
    class << self
      def reset
        @parameters = self.class.defaults.clone
      end
    end
  end

  # extends CfnDsl esource Properties to automatically substitute
  # FnSub recuraively
  class PropertyDefinition < JSONable
    def initialize(value)
      @value = fix_substitutions(value)
    end

    def fix_substitutions(val)
      return val unless defined? val.class.to_s.downcase

      meth = "fix_#{val.class.to_s.downcase}"
      return send(meth, val) if respond_to?(meth.to_sym)

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

    private

    def apply_tag_standard
      return unless defined? external_parameters[:TagStandard]
      return unless external_parameters[:TagStandard].is_a?(Hash)

      apply_tags(external_parameters[:TagStandard]) if defined? self.Tag
      apply_tags_map(external_parameters[:TagStandard]) if HAS_MAPPED_TAGS.include? self.class.to_s
    end

    def apply_tags(tags)
      tags.each do |tag_name, props|
        send(:Tag) do
          Key tag_name.to_s
          Value Ref(props['LogicalName'] || tag_name)
          PropagateAtLaunch true if HAS_PROPAGATABLE_TAGS.include? self.class.to_s
        end
      end
    end

    def apply_tags_map(tags)
      tag_map = {}
      tags.each do |tag_name, props|
        tag_map[tag_name.to_s] = Ref(props['LogicalName'] || tag_name)
      end
      Tags tag_map
    end
  end
end
