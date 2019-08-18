#!/usr/bin/env ruby
#
# 
# The MIT License
#
# Copyright (c) 2019 Cam Maxwell (cameron.maxwell@gmail.com)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
# 

require 'cfndsl'
require 'fileutils'

require_relative 'options'
require_relative 'params'
require_relative 'monkey_patches'
require_relative 'stdout_capture'
require_relative 'run-cfndsl'
require_relative 'run-cfn_nag'
require_relative 'run-syntax'

module CfnDslPipeline
  class Pipeline

    attr_accessor :input_filename, :output_dir, :options, :base_name, :template, :output_filename, :output_file, :syntax_report

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
      abort "Input file #{input_filename} doesn't exist!" if !File.file?(input_filename)
      self.input_filename = "#{input_filename}"
      self.base_name = File.basename(input_filename, '.*')
      self.output_filename = File.expand_path("#{self.output_dir}/#{self.base_name}.yaml")
      exec_cfndsl cfndsl_extras
      exec_syntax_validation if self.options.validate_syntax
      exec_dump_params if self.options.dump_deploy_params
      exec_cfn_nag if self.options.validate_cfn_nag
    end
  end
end
