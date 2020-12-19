require 'toml'

module SamParameterEnvironment

# Get environment variables from the samconfig.toml file.
# Sort of like using dotenv, but the environment variables come from the
# 'parameter_overrides' setting in the SAM configuration file instead of from
# a .env file.
  def self.load(environment=nil)
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
