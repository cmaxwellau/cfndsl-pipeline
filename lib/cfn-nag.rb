require 'cfn-nag'
require 'colorize'

module CfnDslPipeline

  class Pipeline
    def exec_cfn_nag
      puts "Auditing template with cfn-nag..."
      
      CfnNagLogging.configure_logging([:debug]) if self.options.debug_audit 
      cfn_nag = CfnNag.new(config: self.options.cfn_nag)
      result = cfn_nag.audit(cloudformation_string: self.template)
      save_report result if self.options.save_audit_report
      display_report result
      show_summary result
    end

    def display_report(result)
      puts ColoredStdoutResults.new.render([{
        filename: "#{@base_name}",
        file_results: result
      }])    
    end

    def save_report(result)
      report_data = Capture.capture do
        SimpleStdoutResults.new.render([{
          filename: "#{@base_name}",
          file_results: result
        }])
      end    
      filename = "#{self.output_dir}/#{self.base_name}.audit"
      File.open(File.expand_path(filename), 'w').puts report_data['stdout']
      puts "Saved audit report to #{filename}"
    end

    def show_summary(result)
      if result[:failure_count]>0
        puts "Audit failed. #{result[:failure_count]} error(s) found     ( ಠ ʖ̯ ಠ)  ".red
      elsif result[:violations].count>0
        puts "Audit passed with #{result[:warning_count]} warnings.     (._.)  ".yellow
      else
        puts "Audit passed!        ヽ( ﾟヮﾟ)/      ヽ(´ー｀)ノ".green
      end    
    end

  end
end