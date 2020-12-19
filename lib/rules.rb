class Rule

end

$rules = [] # Global list of lambda functions.
Dir.glob("rules/**/*.rb").each{|file| require_relative "../#{file}" }
