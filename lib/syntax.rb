# frozen_string_literal: true
require 'aws-sdk-cloudformation'
require 'aws-sdk-s3' 
require 'uuid'


module CfnDslPipeline
  class Pipeline
    attr_accessor :cfn_client, :s3_client

    def initialize
      self.cfn_client = Aws::CloudFormation::Client.new(region: self.aws_region)
      self.s3_client = Aws::S3::Client.new(region: self.aws_region)
    end

    def exec_syntax_validation
      print "Validating template syntax...\n"
      if self.options.estimate_cost || (self.output_file.size > 51200)
        puts "Filesize is greater than 51200, or cost estimation required. Validating via S3 bucket "
        uuid = UUID.new
        object_name = "#{uuid.generate}"

        if self.options.validation_bucket
          bucket_name = self.options.validation_bucket
          puts "Using existing S3 bucket #{bucket_name}..."
          bucket = self.s3_client.bucket(self.options.validation_bucket)
        else
          bucket_name = "arch-code-#{uuid.generate}"
          puts "Creating temporary S3 bucket #{bucket_name}..."
          bucket = self.s3_client.bucket(bucket_name)
          bucket.create 
        end
        upload_template(bucket, object_name)

        self.syntax_report = s3_validate_syntax(bucket, object_name)

        if self.options.estimate_cost
          estimate_cost(bucket_name, object_name)
        end

        if !self.options.validation_bucket
          puts "Deleting temporary S3 bucket..."
          bucket.delete! 
        end

      else 
        self.syntax_report = local_validate_syntax
      end

      save_syntax_report

    end

    private
    def save_syntax_report
      report_filename = "#{self.output_dir}/#{self.base_name}.report"
      puts "Syntax validation report written to #{report_filename}"
      File.open(File.expand_path(report_filename), 'w').puts self.syntax_report.to_hash.to_yaml
    end

    def upload_template(bucket, object_name)
      puts "Uploading template to temporary S3 bucket..."
      object = bucket.object(object_name)
      object.upload_file(self.output_file)
      puts "  https://s3.amazonaws.com/#{bucket_name}/#{object_name}"
    end

    def estimate_cost(bucket, object_name)
      puts "Estimate cost of template..."
      client = Aws::CloudFormation::Client.new(region: self.options.aws_region)
      costing = client.estimate_template_cost(template_url: "https://#{bucket.url}/#{object_name}")
      puts "Cost Calculator URL is: #{costing.url}"
    end

    def s3_validate_syntax(bucket, object_name)
      if self.options.validate_syntax
        puts "Validating template syntax in S3 Bucket..."
        client = Aws::CloudFormation::Client.new(region: self.options.aws_region)
        client.validate_template(template_url: "https://s3.amazonaws.com/#{bucket.url}/#{object_name}")
      end
    end

    def local_validate_syntax
      puts "Validating template syntax locally..."
      client = Aws::CloudFormation::Client.new(region: self.options.aws_region)
      client.validate_template(template_body: self.template)
    end
  end
end
