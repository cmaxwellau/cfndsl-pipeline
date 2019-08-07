require 'cfndsl/globals'
require 'cfndsl/version'

CfnDsl::CloudFormationTemplate.class_eval do
  def initialize()
    puts 'tag_standard_params'
    # parameters for tagging standard
    if defined? external_parameters[:TagStandard]
      external_parameters[:TagStandard].each do |param_name, props|
        logical_name = props['LogicalName'] || param_name
        Parameter(logical_name) do
          Type(props['Type'])
          Description(props['Description']) if props['Description']
          Default(props['Default']) if props['Default']
          AllowedPattern(props['AllowedPattern']) if props['AllowedPattern']
          AllowedValues(props['AllowedValues']) if props['Allowedvalues'] 
        end
        # ui_label("Standard Tags", final_name, props['Label'] || props['Description'] || param_name)
      end 
    end

  end

  # def ui_label(ui_group, ui_name, ui_text)
  #   ($Interface.parameter_groups[ui_group] ||= []) << ui_name
  #   $Interface.parameter_labels[ui_name] = ui_text
  # end  
end

module CfnDsl
  class PropertyDefinition < JSONable
    def initialize(value)
      @value = fix_references(value)
    end

    def fix_references(value) 
      case
      when value.is_a?(TrueClass) || value.is_a?(FalseClass) || value.is_a?(Integer)
        value
      when value.is_a?(String) && value.include?('${')
        FnSub(value)
      when value.is_a?(Hash)
        value.transform_values!{|item| send(__method__, item)}
      when value.is_a?(Array)
        value.map!{|item| send(__method__, item)}
      when value.is_a?(String) && value.include?('REF_') # Not sure if this is evalueen necessary anymore
        Ref(value.partition('_').last)
      else
        value
      end
    end       
  end
  class ResourceDefinition
    def initialize()
      apply_tag_standard
    end

    def apply_tag_standard(extra = [])
      begin
        external_parameters[:TagStandard].each do |tag_name, props| 
          add_tag(tag_name.to_s, Ref(props['LogicalName'] || tag_name) )
        end if defined? external_parameters[:TagStandard]
     rescue
      end
    end
  end
end