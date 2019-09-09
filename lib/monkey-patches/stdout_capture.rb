# frozen_string_literal: true

require 'stringio'
require 'ostruct'

# Mess wit stdout, capture, restore stdout
class Capture
  def self.capture(&block)
    # redirect output to StringIO objects
    stdout = StringIO.new
    stderr = StringIO.new
    $stdout = stdout
    $stderr = stderr

    result = block.call

    # restore normal output
    $stdout = STDOUT
    $stderr = STDERR

    OpenStruct.new result: result, stdout: stdout.string, stderr: stderr.string
  end
end
