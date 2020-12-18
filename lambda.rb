$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'logger-setup'
require 'sam-parameter-environment'
SamParameterEnvironment.load

# Load all rules.
$LOAD_PATH << File.join(File.dirname(__FILE__), 'rules')
$triggers = [] # Global list of triggers for the rules.
$tests = [] # Canaries.
Dir.glob("rules/**/*.rb").each{|file| require file}

# Production unit tests.
def pre_traffic_lambda_function(event:, context:)
  # Each canary within this AWS Lambda function is a Ruby lambda function.
  $tests.each{ |trigger| trigger.call }
end

# AWS Lambda function handler.
def run_rules(event:, context:)

  $logger.info 'Running rules...'

  # Each trigger within this AWS Lambda function is a Ruby lambda function.
  $triggers.each{ |trigger| trigger.call(event) }

  {
    statusCode: 200
  }

end
