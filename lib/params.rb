# frozen_string_literal: true

module CfnDslPipeline
  class Pipeline
  	def exec_dump_params
      param_filename = "#{self.output_dir}/#{self.input_filename}.parameters"
      puts "Deploy parameters written to #{param_filename}"
      param_file = File.open(File.expand_path(param_filename), 'w')
      self.syntax_report['parameters'].each do | param |
        param_file.puts "#{param['parameter_key']}='#{param['default_value']}'"
      end
    end
  end
end  
