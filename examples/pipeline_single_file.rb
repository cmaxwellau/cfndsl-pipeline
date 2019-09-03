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

opts = CfnDslPipeline::Options.new
# opts.validation_bucket		= 'cdsapipipeline-codebuildartifactsbucket-1iajuto6hoxe4'
opts.validate_cfn_nag		= true
opts.validate_syntax		= false
opts.dump_deploy_params		= false
opts.estimate_cost			= false
opts.save_syntax_report		= false
opts.save_audit_report		= false
opts.debug_audit			= false

opts.cfn_nag = CfnNagConfig.new(
	print_suppression: true, # Emit information when rules are supressed
	allow_suppression: true, # Allow inline metadata to supress rules on a per-resource basis
	fail_on_warnings: false, # This is up to you
	blacklist_definition: IO.read('./cfn_nag_rules/rule_suppression.yaml'),
	rule_directory: './cfn_nag_rules'
)

output_dir='cfn'

cfndsl_extras = [[:yaml, "standard_tags.yaml"]]
pipeline=CfnDslPipeline::Pipeline.new(output_dir, opts)

pipeline.build("s3bucket.rb", cfndsl_extras)
