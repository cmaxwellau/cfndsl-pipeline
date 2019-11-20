# frozen_string_literal: true

require 'cfn-nag'
require 'logging'
require 'colorize'

module CfnDslPipeline
  # Interface to cfn_nag auditing
  class Pipeline
    def exec_cfn_nag
      puts 'Auditing template with cfn-nag...'
      configure_cfn_nag_logging
      cfn_nag = CfnNag.new(config: options.cfn_nag)
      result = cfn_nag.audit(cloudformation_string: template)
      save_report result
      display_report result
      show_summary result
    end

    private

    def configure_cfn_nag_logging
      CfnNagLogging.configure_logging([:debug]) if options.debug_audit
    end

    def display_report(result)
      ColoredStdoutResults.new.render(
        [
          {
            filename: @base_name.to_s,
            file_results: result
          }
        ]
      )
    end

    def save_report(result)
      return unless options.save_audit_report

      report_data = Capture.capture do
        SimpleStdoutResults.new.render(
          [
            {
              filename: @base_name.to_s,
              file_results: result
            }
          ]
        )
      end
      filename = "#{output_dir}/#{base_name}.audit"
      File.open(File.expand_path(filename), 'w').puts report_data['stdout']
      puts "Saved audit report to #{filename}"
    end

    def show_summary(result)
      if result[:failure_count].positive?
        puts "Audit failed. #{result[:failure_count]} error(s) found     ( ಠ ʖ̯ ಠ)  ".red
      elsif result[:violations].count.positive?
        puts "Audit passed with #{result[:warning_count]} warnings.     (._.)  ".yellow
      else
        puts 'Audit passed!        ヽ( ﾟヮﾟ)/      ヽ(´ー｀)ノ'.green
      end
    end
  end
end
