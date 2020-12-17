$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'logger-setup'

# AWS Lambda function handler.
def run_rules(event:, context:)

  $logger.info 'Starting HTML menu generation...'
  $logger.debug 'Event:'
  $logger.debug event.to_s

  # client_id: ENV['SINGLE_PLATFORM_CLIENT_ID'],

  {
    statusCode: 200
  }

end
