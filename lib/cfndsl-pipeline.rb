#!/usr/bin/env ruby
#
# Copyright 2018 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You
# may not use this file except in compliance with the License. A copy of
# the License is located at
#
# http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file. This file is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
# ANY KIND, either express or implied. See the License for the specific
# language governing permissions and limitations under the License.
#
require_relative 'cp-cfndsl'
require_relative 'cp-cfn_nag'
require_relative 'cp-options'
require_relative 'cp-params'
require_relative 'cp-syntax'
require_relative 'monkey-patches'
require_relative 'stdout-capture'

require 'fileutils'
# require 'json'
# require 'yaml'
# require 'open-uri'


module CfnDslPipeline
  class Pipeline

    attr_accessor :input_filename, :output_dir, :options, :template, :output_filename, :output_file, :syntax_report

    def initialize (output_dir, options)
      self.input_filename = ''
      self.output_file = nil
      self.template = nil
      self.options = options || nil
      self.syntax_report = []
      FileUtils.mkdir_p output_dir
      abort "Could not create output directory #{output_dir}" if Dir[output_dir] == nil
      self.output_dir = output_dir
    end

    def build(input_filename, cfndsl_extras)
      puts self.options
      abort "Input file #{input_filename}.rb doesn't exist!" if !File.file?("#{input_filename}.rb")
      self.input_filename = "#{input_filename}"
      self.output_filename = File.expand_path("#{self.output_dir}/#{input_filename}.yaml")
      exec_cfndsl cfndsl_extras
      exec_syntax_validation if self.options.validate_syntax
      exec_dump_params if self.options.dump_deploy_params
      exec_cfn_nag if self.options.validate_cfn_nag

    end
  end
end
