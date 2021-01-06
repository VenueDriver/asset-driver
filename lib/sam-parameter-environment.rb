require 'toml'

module SamParameterEnvironment

# Get environment variables from the samconfig.toml file.
# Sort of like using dotenv, but the environment variables come from the
# 'parameter_overrides' setting in the SAM configuration file instead of from
# a .env file.
  def self.load(environment=nil)
    # This code that was intended for use in local development and testing was
    # running in AWS Lambda, and the code ended up thinking that it was in the
    # ‘dev’ environment.  It was very confusing to understand why it kept trying
    # to connect to the development S3 bucket.
    # TODO: The bug couldn’t have happened if the samconfig.toml file hadn’t
    # been built into the package for Lambda.  It would be better if only the
    # code needed for runtime were included in the package.
    return if ENV['AWS_EXECUTION_ENV']

    return unless File.exist? 'samconfig.toml'
    environment = ARGV[1] || 'default'
    TOML.load_file('samconfig.toml')[environment]['deploy']['parameters'
      ]['parameter_overrides'].
      split(' ').each do |variable|
        parts = variable.split '='
        value = parts[1].gsub(/^\"(.*)\"$/){ $1 }
        ENV[parts[0].gsub(/(?<!^)[A-Z]/) do "_#$&" end.upcase] = value
      end
  end

end
