require 'logger'

module CfnDslPipeline
	formatter = proc do |severity, datetime, progname, msg|
	   "#{severity}: #{msg}\n"
	end

	Logger = Logger.new(STDOUT, formatter: formatter)
end