require 'cfndsl'
require 'cfndsl/globals'
require 'cfndsl/version'

module CfnDslPipeline
  class Pipeline
   def exec_cfndsl(cfndsl_extras)
      # puts cfndsl_extras.inspect
      print "Generating CloudFormation template...\n"
      model = CfnDsl.eval_file_with_extras("#{@input_filename}", cfndsl_extras)
      @template = JSON.parse(model.to_json).to_yaml
      File.open(@output_filename, 'w') do |file|
        file.puts @template
      end
      @output_file = File.open(@output_filename)
      puts "  #{@output_file.size} bytes written to #{@output_filename}"
    end
  end
end