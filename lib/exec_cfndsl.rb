# frozen_string_literal: true

require 'cfndsl'
require 'cfndsl/globals'
require 'cfndsl/version'

module CfnDslPipeline
  # Interface to cfndsl
  class Pipeline
    def exec_cfndsl(cfndsl_extras)
      puts 'Generating CloudFormation template...'

      model = CfnDsl.eval_file_with_extras(@input_filename.to_s, cfndsl_extras, (options.debug_cfndsl ? STDOUT : nil))
      @template = JSON.parse(model.to_json).to_yaml
      File.open(@output_filename, 'w') do |file|
        file.puts @template
      end
      @output_file = File.open(@output_filename)
      puts "#{@output_file.size} bytes written to #{@output_filename}"
    end
  end
end
