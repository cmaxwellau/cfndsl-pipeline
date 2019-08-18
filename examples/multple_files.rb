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


require 'cfndsl-pipeline'

options = CfnDslPipeline::Options.new
options.validation_bucket= 'my_cloudformation_bucket'

includes =[
  [:yaml,'includes/common_definitions.yaml'],
  [:yaml,'includes/standard_tags.yaml']
]

['file1', 'file2'].each do |file|
  cfndsl_extras = Marshal.load(Marshal.dump(includes)) << [:yaml, "#{file}.tags.yaml"]
  pipeline=CfnDslPipeline::Pipeline.new('output_dir', options)
  pipeline.build(file, cfndsl_extras)
end
