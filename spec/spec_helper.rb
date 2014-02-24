$: << File.join(File.dirname(__FILE__),"..", "lib")

FIXTURE_PATH = File.join(File.dirname(__FILE__),'fixtures')

ENV['BASE_LOCATION']         = FIXTURE_PATH
ENV['PREVIEW_TEMPLATE_PATH'] = File.join(FIXTURE_PATH, 'lib')
ENV['RACK_ENV']              = 'test'

require 'pry'
require 'rack/test'
require 'alephant/preview'

