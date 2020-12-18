require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'pry'

require 'awesome_print'

class VenueDriverFlyersRuleTestCase < Test::Unit::TestCase
  # def setup
  # end

  # def teardown
  # end

  def test_event_flyer
    puts "BUCKET: #{ENV['VENUE_DRIVER_FLYERS_SOURCE_BUCKET']}"
    assert(true, 'Assertion was true.')
  end

end

class VenueDriverFlyersRule < Rule
  #-------------------------------------------------------------------------------
  # Rule
  #-------------------------------------------------------------------------------

  def trigger(event:)
    $logger.info 'Hello, world!'
    $logger.debug "AWS Lambda event:"
    $logger.debug event.ai

    event_record = event['Records'].first
    if event_record['eventSource'].eql? 'aws:s3' and
      event_record['eventName'].eql? 'ObjectCreated:Put'
      $logger.info "File name: #{event_record['s3']['object']['key']}"
    end
  end

  #-------------------------------------------------------------------------------
  # Action
  #-------------------------------------------------------------------------------


  #-------------------------------------------------------------------------------
  # Tests
  #-------------------------------------------------------------------------------

  def test

    result = Test::Unit::UI::Console::TestRunner.
      run(VenueDriverFlyersRuleTestCase)

    if result.error_occurred? or result.failure_occurred?
      # Do something to tell CodeDeploy to abort the deployment.
    end

  end

end

# Register an instance of the rule in the global list.
$rules << VenueDriverFlyersRule.new
