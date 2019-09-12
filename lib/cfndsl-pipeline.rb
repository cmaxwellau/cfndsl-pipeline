# rubocop:disable Naming/FileName
# frozen_string_literal: true

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
require 'cfn-nag'
require 'fileutils'

require_relative 'monkey-patches/cfndsl_patch'
require_relative 'monkey-patches/stdout_capture'
require_relative 'options'
require_relative 'params'
require_relative 'exec_cfndsl'
require_relative 'exec_cfn_nag'
require_relative 'exec_syntax'

module CfnDslPipeline
  # Main pipeline
  class Pipeline
    attr_accessor :input_filename, :output_dir, :options, :base_name, :template, :output_filename, :output_file, :syntax_report

    def initialize(output_dir, options)
      self.input_filename = ''
      self.output_file = nil
      self.template = nil
      self.options = options || nil
      self.syntax_report = []
      FileUtils.mkdir_p output_dir
      abort "Could not create output directory #{output_dir}" unless Dir[output_dir]
      self.output_dir = output_dir
    end

    def build(input_filename, cfndsl_extras)
      abort "Input file #{input_filename} doesn't exist!" unless File.file?(input_filename)
      self.input_filename = input_filename.to_s
      self.base_name = File.basename(input_filename, '.*')
      self.output_filename = File.expand_path("#{output_dir}/#{base_name}.yaml")
      exec_cfndsl cfndsl_extras
      exec_syntax_validation if options.validate_syntax
      exec_dump_params if options.dump_deploy_params
      exec_cfn_nag if options.validate_cfn_nag
    end
  end
end
# rubocop:enable Naming/FileName
