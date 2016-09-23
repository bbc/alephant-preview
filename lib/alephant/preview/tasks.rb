require 'rake'
require 'pathname'

root = Pathname.new(__FILE__).dirname
task_path = (root + 'tasks').realdirpath

Dir["#{task_path}/**/*.rake"].each { |ext| load ext } if defined?(Rake)
