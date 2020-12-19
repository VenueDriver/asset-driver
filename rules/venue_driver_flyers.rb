require 'test/unit'
require 'test/unit/ui/console/testrunner'

require 'pry'
require 'awesome_print'

require 'mini_magick'

require 'aws-sdk-s3'

class VenueDriverFlyersRule < Rule

  def resolutions
    [
      2400,
      1920,
      1200,
      640,
      320
    ]
  end

  #-----------------------------------------------------------------------------
  # Rule
  #-----------------------------------------------------------------------------

  def trigger(event:)
    $logger.debug "AWS Lambda event:\n" + event.ai

    event = event['Records'].first

    $logger.debug "File name: #{event['s3']['object']['key']}"

    # Conditions for matching the event:
    if (
        # Is it from S3?
        event['eventSource'].eql? 'aws:s3' and

        # Is it a file (object) creation event?
        event['eventName'].eql? 'ObjectCreated:Put' and

        # Does the filename match the pattern "*/original/*.*"?
        event['s3']['object']['key'] =~ /(\d+)\/original\/(.*)/
      )

      event_id = $1
      original_image_filename = $2

      $logger.debug "Event ID: #{event_id}"
      $logger.debug "Original image filename: #{original_image_filename}"

      # If those conditions match, then do this.
      generate_responsive_images(
        event_id:event_id,
        filename:event['s3']['object']['key']
      )

    end
  end

  #-----------------------------------------------------------------------------
  # Action
  #-----------------------------------------------------------------------------

  def generate_responsive_images(event_id:, filename:)
    $logger.info "Generating responsive images for: #{filename}"

    # Generate each resolution that we need.
    resolutions.each do |width|
      # Generate the square variants.
      generate_image(
        source_bucket_name: ENV['VENUE_DRIVER_FLYERS_SOURCE_BUCKET'],
        source_filename: filename,
        output_bucket_name: ENV['VENUE_DRIVER_FLYERS_OUTPUT_BUCKET'],
        output_filename: "flyer/squared/#{width}/event/#{event_id}.jpg",
        width: width,
        height: width
      )
    end

  end

  def generate_image(
    source_bucket_name:, source_filename:,
    output_bucket_name:, output_filename:,
    width:, height:)

    $logger.info "Generating image: #{output_filename}"

    # Get the source file from S3 to a /tmp file.
    $logger.info "Getting source file from: #{source_bucket_name}:#{source_filename}"
    s3 = Aws::S3::Resource.new()
    object = s3.bucket(source_bucket_name).object(source_filename)
    tmp_file_name = '/tmp/asset-driver-image'
    object.get(response_target: tmp_file_name)

    $logger.debug "Source image size: #{File.size(tmp_file_name)} bytes"

    image = MiniMagick::Image.open(tmp_file_name)

    $logger.debug "Image resolution: #{image.width}x#{image.height}"

    # Resize to a bounding box the size of the largest axis.
    resize = "#{[width, height].max}x#{[width, height].max}^"
    $logger.debug "Resizing: #{resize}"
    image.resize resize

    $logger.debug "Image resolution: #{image.width}x#{image.height}"

    # Crop down from there to the final image.
    shave = "#{(image.width-width)/2}x#{(image.height-height)/2}"
    $logger.debug "Shaving: #{shave}"
    image.shave shave

    $logger.debug "Image resolution: #{image.width}x#{image.height}"

    crop = "#{width}x#{height}+0+0^"
    $logger.debug "Final crop to: #{crop}"
    image.crop crop

    $logger.debug "Image resolution: #{image.width}x#{image.height}"

    resized_tmp_file = '/tmp/asset-driver-resized-image'
    image.quality 30
    image.strip.write resized_tmp_file

    $logger.debug 'Stripped ImageMagick output file size: ' +
      "#{File.size(resized_tmp_file)} bytes"

    # Upload the output image.
    s3.bucket(output_bucket_name).object(output_filename).
      upload_file(resized_tmp_file, acl: 'public-read')

  end

end

# Register an instance of the rule in the global list.
$rules << VenueDriverFlyersRule.new
