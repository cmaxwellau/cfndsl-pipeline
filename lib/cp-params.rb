
module CfnDsl
  class Pipeline
  	def exec_dump_params
      param_filename = "#{@output_dir}/#{@input_filename}.parameters.yaml"
      puts "Deploy parameters written to #{param_filename}"
      param_file = File.open(File.expand_path(param_filename), 'w')
      report['parameters'].each do | param |
        param_file.puts "#{param['parameter_key']}='#{param['default_value']}'"
      end
    end
  end
end  
