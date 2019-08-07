require 'cfn-nag'

module CfnDsl
  class Pipeline
    def exec_cfn_nag
      puts "Auditing template with cfn-nag..."
      cfn_nag_opts = Options.for('file')
      cfn_nag_config = CfnNagConfig.new(
        profile_definition: nil,
        blacklist_definition: nil,
        rule_directory: cfn_nag_opts[:rule_directory],
        allow_suppression: cfn_nag_opts[:allow_suppression],
        print_suppression: cfn_nag_opts[:print_suppression],
        isolate_custom_rule_exceptions: cfn_nag_opts[:isolate_custom_rule_exceptions],
        fail_on_warnings: cfn_nag_opts[:fail_on_warnings]
      )
      cfn_nag = CfnNag.new(config: cfn_nag_config)
      audit_result = cfn_nag.audit(cloudformation_string: output_template)
      audit_report = Capture.capture do
        SimpleStdoutResults.new.render([{
          filename: output_filename,
          file_results: audit_result
        }])
      end
      audit_filename = "#{@output_dir}/#{@input_filename}.audit.txt"
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