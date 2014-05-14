require 'rake'
require 'pry'

# Load our Rakefile
load 'Rakefile'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end
