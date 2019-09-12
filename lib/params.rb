# frozen_string_literal: true

require 'shellwords'

module CfnDslPipeline
  # Dump stack parameters based on template
  class Pipeline
    def exec_dump_params
      param_filename = "#{output_dir}/#{base_name}.params"
      puts "Deploy parameters written to #{param_filename}"
      param_file = File.open(File.expand_path(param_filename), 'w')
      syntax_report['parameters'].each do |param|
        param_file.puts "#{param['parameter_key']}=#{param['default_value']}"
      end
    end
  end
end
