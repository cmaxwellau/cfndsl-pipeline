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


require 'fileutils'
# require 'json'
# require 'yaml'
# require 'open-uri'


module CfnDsl
  class Pipeline
    @input_filename = ''
    @output_file = nil
    @output_dir = ''
    @options = nil
    @template = nil
    class << self
      attr_accessor :input_filename, :output_dir, :options, :template, :output_filename
    end

    def initialize (output_dir, options=false)
      @options = options if options

      FileUtils.mkdir_p output_dir
      abort "Could not create output directory #{output_dir}" if Dir[output_dir] == nil
      @output_dir = output_dir
    end

    def build(input_filename,  cfndsl_extras: false)
      abort "Input file #{input_filename} doesn't exist!" if !iFile.file?(input_filename)
      @input_filename = input_filename
      @output_filename = File.expand_path("#{@output_dir}/#{input_filename}.yaml")

      exec_cfndsl cfndsl_extras

      exec_syntax_validation @options.estimate_cost || @options.validate_syntax

      exec_cfn_nag if linter
      
      exec_dump_params if dump_deploy_params

    end
  end
end
