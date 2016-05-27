lib = File.expand_path("../..", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "alephant/preview/version"
require "alephant/preview/server"
require "alephant/preview/template"
