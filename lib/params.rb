# frozen_string_literal: true
require 'shellwords'

module CfnDslPipeline
  class Pipeline
  	def exec_dump_params
      param_filename = "#{self.output_dir}/#{self.base_name}.params"
      puts "Deploy parameters written to #{param_filename}"
      param_file = File.open(File.expand_path(param_filename), 'w')
      self.syntax_report['parameters'].each do | param |
        param_file.puts "#{param['parameter_key']}=#{Shellwords.escape(param['default_value'])}"
      end
    end
  end
end  
