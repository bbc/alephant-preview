$: << File.join(File.dirname(__FILE__),"..", "lib")

ENV['RACK_ENV']     = 'test'
ENV['FIXTURE_PATH'] = File.join(File.dirname(__FILE__),'fixtures')

require 'pry'
require 'rack/test'
require 'alephant/preview'

