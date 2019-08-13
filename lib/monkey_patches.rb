# frozen_string_literal: true

require 'cfndsl/globals'
require 'cfndsl/version'
PARAM_PROPS = %w[Description Default AllowedPattern AllowedValues].freeze

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
          send(prop, props[key]) if defined? props[key]
        end
      end
    end
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
      meth = "fix_#{val.is_a?.downcase}"
      if respond_to?(meth.to_sym)
        send(meth.to_sym)
      else
        val
      end
    end

    # have to capture the types as the bools also meatch others

    def fix_not(&val)
      val
    end
    alias fix_trueclass  fix_not
    alias fix_falseclass fix_not
    alias fix_integer    fix_not
    
    def fix_hash(&val)
      val.transform_values! { |item| fix_substitutions item }
    end

    def fix_array(&val)
      val.map! { |item| fix_substitutions item }
    end

    def fix_string(&val)
      val.include?('${') ? FnSub(val) : val
    end
  end

  # Automatically apply Tag standard to  CfnDsl Resources (if supplied)
  class ResourceDefinition
    def initialize
      apply_tag_standard
    end

    def apply_tag_standard
      return unless defined? external_parameters[:TagStandard]

      # begin
      external_parameters[:TagStandard].each do |tag_name, props|
        add_tag(tag_name.to_s, Ref(props['LogicalName'] || tag_name))
      end
      # rescue
      # end
    end
  end
end
