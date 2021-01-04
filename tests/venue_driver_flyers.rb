require 'test/unit'
require 'test/unit/ui/console/testrunner'

# require 'pry'
require 'awesome_print'

require 'mini_magick'

require 'aws-sdk-s3'

class VenueDriverFlyersRuleTestCase < Test::Unit::TestCase

  @@source_bucket_name = ENV['VENUE_DRIVER_FLYERS_SOURCE_BUCKET']
  @@output_bucket_name = ENV['VENUE_DRIVER_FLYERS_OUTPUT_BUCKET']
  @@standard_test_image_filename = 'tests/assets/Ocean_Drive_by_night_3.jpg'

  # Copy the standard test image to the place where the original image for
  # the event with ID 0 would be.  (There is no such event for real.)
  def setup
    $logger.info "Test setup for source bucket: #{@@source_bucket_name}"
    s3 = Aws::S3::Resource.new()

    $logger.debug "Uploading test flyer image."
    s3.bucket(@@source_bucket_name).
      object('0/original/file.jpg').
        upload_file(@@standard_test_image_filename)
  end

  def teardown
    # delete_test_files
  end

  def test_event_flyer
    rule = VenueDriverFlyersRule.new

    rule.trigger(event:JSON.parse(File.read('tests/events/created_file.json')))

    s3 = Aws::S3::Resource.new()
    source_bucket = s3.bucket(@@source_bucket_name)
    output_bucket = s3.bucket(@@output_bucket_name)

    rule.resolutions.each do |resolution|
      output_s3_filename = "flyer/squared/#{resolution}/event/0.jpg"
      assert(output_bucket.object(output_s3_filename).exists?,
        "#{resolution}x#{resolution} image exists.")

      # Get the file from S3.
      output_tmp_filename = '/tmp/asset-driver-image'
      output_file = output_bucket.object(output_s3_filename).
          get(response_target: output_tmp_filename)

      assert(MiniMagick::Image.open(output_tmp_filename).valid?,
        "#{resolution}x#{resolution} image is valid.")

      assert(MiniMagick::Image.open(output_tmp_filename).width.eql?(resolution),
        "#{resolution}x#{resolution} width is correct.")

      assert(MiniMagick::Image.open(output_tmp_filename).width.
        eql?(MiniMagick::Image.open(output_tmp_filename).height),
        "#{resolution}x#{resolution} image is square.")
    end

  end

  def delete_test_files
    s3 = Aws::S3::Resource.new()
    VenueDriverFlyersRule.resolutions.each do |width|
      s3.bucket(@@output_bucket_name).
        object("flyer/squared/#{width}/event/0.jpg").delete
    end
    s3.bucket(@@source_bucket_name).
      object(@@standard_test_image_filename).delete
  end

end

class VenueDriverFlyersRule

  def test

    result = Test::Unit::UI::Console::TestRunner.
      run(VenueDriverFlyersRuleTestCase)

    if result.error_occurred? or result.failure_occurred?
      # Do something to tell CodeDeploy to abort the deployment.
    end

  end

end
