# frozen_string_literal: true
require 'aws-sdk-cloudformation'
require 'aws-sdk-s3'
require 'uuid'

module CfnDslPipeline
  #
  class Pipeline
    attr_accessor :s3_client

    def initialize
      self.s3_client = Aws::S3::Client.new(region: aws_region)
    end
    # rubocop:disable Metrics/AbcSize
    def exec_syntax_validation
      puts 'Validating template syntax...'
      if options.estimate_cost || (output_file.size > 51_200)
        puts 'Filesize is greater than 51200, or cost estimation required. Validating via S3 bucket '
        uuid = UUID.new
        bucket = determine_bucket
        object_name = uuid.generate.to_s
        upload_template(bucket, object_name)
        self.syntax_report = s3_validate_syntax(bucket, object_name)
        estimate_cost(bucket_name, object_name)
        unless options.validation_bucket
          puts 'Deleting temporary S3 bucket...'
          bucket.delete!
        end
      else
        self.syntax_report = local_validate_syntax
      end
      save_syntax_report
    end
    # rubocop:enable Metrics/AbcSize

    private

    def determine_bucket
      if options.validation_bucket
        bucket_name = options.validation_bucket
        puts "Using existing S3 bucket #{bucket_name}..."
        bucket = s3_client.bucket(options.validation_bucket)
      else
        bucket_name = "arch-code-#{uuid.generate}"
        puts "Creating temporary S3 bucket #{bucket_name}..."
        bucket = s3_client.bucket(bucket_name)
        bucket.create
      end
      bucket
    end

    def save_syntax_report
      return unless options.save_syntax_report
      report_filename = "#{output_dir}/#{base_name}.report"
      puts "Syntax validation report written to #{report_filename}"
      File.open(File.expand_path(report_filename), 'w').puts syntax_report.to_hash.to_yaml
    end

    def upload_template(bucket, object_name)
      puts 'Uploading template to temporary S3 bucket...'
      object = bucket.object(object_name)
      object.upload_file(output_file)
      puts "https://s3.amazonaws.com/#{bucket_name}/#{object_name}"
    end

    def estimate_cost(bucket, object_name)
      return unless options.estimate_cost
      puts 'Estimate cost of template...'
      client = Aws::CloudFormation::Client.new(region: options.aws_region)
      costing = client.estimate_template_cost(template_url: "https://#{bucket.url}/#{object_name}")
      puts "Cost Calculator URL is: #{costing.url}"
    end

    def s3_validate_syntax(bucket, object_name)
      return unless options.validate_syntax
      puts 'Validating template syntax in S3 Bucket...'
      client = Aws::CloudFormation::Client.new(region: options.aws_region)
      client.validate_template(template_url: "https://s3.amazonaws.com/#{bucket.url}/#{object_name}")
    end

    def local_validate_syntax
      puts 'Validating template syntax locally...'
      client = Aws::CloudFormation::Client.new(region: options.aws_region)
      client.validate_template(template_body: template)
    end
  end
end
