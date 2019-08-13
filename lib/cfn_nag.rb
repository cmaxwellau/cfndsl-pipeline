require 'cfn-nag'

module CfnDslPipeline
  class Pipeline
    def exec_cfn_nag
      puts "Auditing template with cfn-nag..."
      cfn_nag_config = CfnNagConfig.new(
        print_suppression: false,
        fail_on_warnings: true
      )
      cfn_nag = CfnNag.new(config: cfn_nag_config)
      audit_result = cfn_nag.audit(cloudformation_string: self.template)
      audit_report = Capture.capture do
        SimpleStdoutResults.new.render([{
          filename: output_filename,
          file_results: audit_result
        }])
      end
      audit_filename = "#{self.output_dir}/#{self.input_filename}.audit"
      puts "Audit results written to #{audit_filename}."
      File.open(File.expand_path(audit_filename), 'w').puts audit_report['stdout']
      if audit_result[:failure_count]>0
        puts "#{audit_result[:failure_count]} error(s) found during audit.  (˃̣̣̥⌓˂̣̣̥⋆)"
      else
        puts 'Template passed audit!        \( ﾟヮﾟ)/'
      end
    end
  end
end