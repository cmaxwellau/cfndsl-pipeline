
require 'aws-sdk-cloudformation'
require 'aws-sdk-s3' 
require 'uuid'


module CfnDsl
  class Pipeline
    class << self
      attr_accessor :cfn_client, :s3_client
    end

    def initialize
      @cfn_client = Aws::CloudFormation::Client.new(region: @aws_region)
      @s3_client = Aws::S3::Client.new(region: @aws_region)
    end

    def exec_syntax_validation
      print "Validating template syntax...\n"
      if @options.estimate_cost || (@output_file.size > 51200)
        puts "Filesize is greater than 51200, or cost estimation required. Validating via S3 bucket "
        uuid = UUID.new
        object_name = "#{uuid.generate}"

        if @options.validation_bucket
          bucket_name = @options.validation_bucket
          puts "Using existing S3 bucket #{bucket_name}..."
          bucket = @s3_client.bucket(@options.validation_bucket)
        else
          bucket_name = "arch-code-#{uuid.generate}"
          puts "Creating temporary S3 bucket #{bucket_name}..."
          bucket = @s3_client.bucket(bucket_name)
          bucket.create 
        end
        upload_template(bucket, object_name)
      if @options.validate_syntax
        report = s3_validate_syntax(bucket, object_name)
        if @options.estimate_cost
          estimate_cost(bucket_name, object_name)
        end

        if !@options.validation_bucket
          puts "Deleting temporary S3 bucket..."
          bucket.delete! 
        end

      else 
        report = local_validate_syntax
      end

      report_filename = "#{@output_dir}/#{@input_filename}.report.yaml"
      puts "Validation report written to #{report_filename}"
      File.open(File.expand_path(report_filename), 'w').puts report.to_hash.to_yaml
    end
    private

    def upload_template(bucket, object_name)
      puts "Uploading template to temporary S3 bucket..."
      object = bucket.object(object_name)
      object.upload_file(@output_file)
      puts "  https://s3.amazonaws.com/#{bucket_name}/#{object_name}"

    def estimate_cost(bucket, object_name)
      puts "Estimate cost of template..."
      costing = @cfn_client.estimate_template_cost({template_url: "https://#{bucket.url}/#{object_name}"})
      puts "Cost Calculator URL is: #{costing.url}"
    end

    def s3_validate_syntax(bucket, object_name)
      if @options.validate_syntax
        puts "Validating template syntax in S3 Bucket..."
        @cfn_client.validate_template({template_url: "https://s3.amazonaws.com/#{bucket.url}/#{object_name}"})
      end    
    end

    def local_validate_syntax
      puts "Validating template syntax locally..."
      @cfn_client.validate_template({template_body: @output_template})
    end
  end
end