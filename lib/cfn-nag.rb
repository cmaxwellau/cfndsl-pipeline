require 'cfn-nag'
require 'colorize'

module CfnDslPipeline

  class Pipeline
    def exec_cfn_nag
      puts "Auditing template with cfn-nag..."
      
      CfnNagLogging.configure_logging({:debug => self.options.debug_audit})
      cfn_nag = CfnNag.new(config: self.options.cfn_nag)
      result = cfn_nag.audit(cloudformation_string: self.template)
      if self.options.save_audit_report
        audit_report = Capture.capture do
          SimpleStdoutResults.new.render([{
            filename: output_filename,
            file_results: result
          }])
        end
        audit_filename = "#{self.output_dir}/#{self.base_name}.audit"
        File.open(File.expand_path(audit_filename), 'w').puts audit_report['stdout']
        puts "Saved audit report to #{audit_filename}"
        if result[:failure_count]>0
          puts "Audit failed. #{result[:failure_count]} error(s) found     ( ಠ ʖ̯ ಠ)  ".red
        elsif result[:violations].count>0
          puts "Audit passed with #{result[:warning_count]} warnings.     (._.)  ".yellow
        else
          puts "Audit passed!        ヽ( ﾟヮﾟ)/      ヽ(´ー｀)ノ".green
        end        
      else
        ColoredStdoutResults.new.render([{
          filename: "cfn-nag results:",
          file_results: result
        }]) 
      end
    end
  end
end