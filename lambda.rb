$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'logger-setup'
require 'sam-parameter-environment'
SamParameterEnvironment.load

# Load all rules.
require 'rule'
$LOAD_PATH << File.join(File.dirname(__FILE__), 'rules')
$rules = [] # Global list of lambda functions.
Dir.glob("rules/**/*.rb").each{|file| require file}

# Unit tests, can be run as canaries in the cloud.
def pre_traffic_lambda_function(event:, context:)
  # Each canary within this AWS Lambda function is a labmda function in Ruby.
  $rules.each{ |rule| rule.test }
end

# AWS Lambda function handler.
def run_rules(event:, context:)

  $logger.info 'Running rules...'

  # Each trigger within this AWS Lambda function is a lambda function in Ruby.
  $rules.each{ |rule| rule.trigger(event:event) }

  {
    statusCode: 200
  }

end
