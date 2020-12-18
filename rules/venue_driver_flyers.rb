require 'pry'

#-------------------------------------------------------------------------------
# Trigger
#-------------------------------------------------------------------------------

$triggers << ->(event) {
  puts "Venue Driver flyers!! #{event}"
  binding.pry
}

#-------------------------------------------------------------------------------
# Action
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# Test
#-------------------------------------------------------------------------------

require 'test/unit'
require 'test/unit/ui/console/testrunner'

class RuleTestCase < Test::Unit::TestCase
  # def setup
  # end

  # def teardown
  # end

  def test_pass
    puts "BUCKET: #{ENV['VENUE_DRIVER_FLYERS_SOURCE_BUCKET']}"
    assert(true, 'Assertion was true.')
  end

  def test_fail
    assert(false, 'Assertion was false.')
  end
end

require 'awesome_print'
$tests << -> {
  result = Test::Unit::UI::Console::TestRunner.run(RuleTestCase)

  if result.error_occurred? or result.failure_occurred?
    # Do something to tell CodeDeploy to abort the deployment.
  end
}
