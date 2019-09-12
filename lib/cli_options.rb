# frozen_string_literal: true

require 'optparse'

module CfnDslPipeline
  # Command Line Options processing
  class CliOptions
    attr_accessor :output, :template, :pipeline, :cfndsl_extras, :op

    USAGE = "Usage: #{File.basename(__FILE__)} input file [ -o output_dir ] [ -b bucket ] OPTIONS [ include1 include2 etc.. ]"

    def initialize
      @output = './'
      @cfndsl_extras = []
      @pipeline = CfnDslPipeline::Options.new
      parse && validate
    end

    private

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/BlockLength
    def parse
      @op = OptionParser.new do |opts|
        opts.banner = USAGE

        opts.on('-o', '--output dir', 'Optional output directory. Default is current directory') do |dir|
          @output = dir
        end

        opts.on('-b', '--bucket', 'Optional Existing S3 bucket for cost estimation and large template syntax validation') do |bucket|
          pipeline.validation_bucket = bucket
        end

        opts.on('-p', '--params', 'Create cloudformation deploy compatible params file') do
          pipeline.dump_deploy_params = true
        end

        opts.on('-s', '--syntax', 'Enable syntax check') do
          pipeline.validate_syntax = true
        end

        opts.on('--syntax-report', 'Save template syntax report') do
          pipeline.save_syntax_report = true
        end

        opts.on('-a', '--audit', 'Enable cfn_nag audit') do
          pipeline.validate_cfn_nag = false
        end

        opts.on('--audit-rule-dir', 'cfn_nag audit custom rules directory') do
          pipeline.cfn_nag[:rule_directory] = true
        end

        opts.on('--audit-report', 'Save cfn_nag audit report') do
          pipeline.save_audit_report = true
        end

        opts.on('--audit-debug', 'Enable cfn_nag rule debug output') do
          pipeline.debug_audit = true
        end

        opts.on('-e', '--estimate-costs', 'Generate URL for AWS simple cost calculator') do
          pipeline.estimate_cost = true
        end

        opts.on('-r', '--aws-region', 'AWS region to use. Default: ap-southeast-2') do |region|
          pipeline.aws_region = region
        end

        opts.on_tail('-h', '--help', 'show this message') do
          puts opts
          exit
        end

        opts.on_tail('-d', '--debug', 'show pipeline debug messages') do
          pipeline.debug = true
          exit
        end

        opts.on_tail('-v', '--version', 'Show version') do
          puts CfnDsl::Pipeline::VERSION
          exit
        end
      end
      @op.parse!

      # first non-dash parameter is the mandatory input file
      @template = ARGV.pop
      # rubocop:disable Style/MultilineIfModifier
      ARGV.each do |arg|
        @cfndsl_extras << [:yaml, arg]
      end unless ARGV.empty?
      # rubocop:enable Style/MultilineIfModifier

      pipeline
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/BlockLength

    def fatal(msg)
      puts msg
      puts @op
      exit 1
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    def validate
      # Exit on invalid option combinations
      fatal 'Error: Input template file does not exist.' unless @template && File.file?(@template)

      if @pipeline.save_syntax_report
        fatal 'Error: save syntax report is set, but syntax validation was not enabled.' unless @pipeline.validate_syntax && !@pipeline.save_syntax_report
      end
      # rubocop:disable  Style/GuardClause
      if @pipeline.cfn_nag.rule_directory || @pipeline.debug_audit || @pipeline.save_audit_report
        fatal 'Error: Audit options set, but audit was not enabled' unless @pipeline.validate_cfn_nag
        fatal 'Error: cfn_nag rule directory does not exist' unless File.directory?(@pipeline.cfn_nag.rule_directory)
      end
      # rubocop:enable  Style/GuardClause
    end
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity
  end
end
