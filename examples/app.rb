
require File.dirname(__FILE__)+'/../lib/failtale_reporter'

FailtaleReporter.configure do |config|
  config.base_uri  'errors.dev'
  config.api_token '4aec6928c465a1c62d14388ab16ae993518b3c0a'
end

FailtaleReporter.report do
  raise 'Hello 2'
end
