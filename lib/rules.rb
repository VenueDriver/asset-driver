class Rule

end

$rules = [] # Global list of rule class instances.
Dir.glob("rules/**/*.rb").each{|file| require_relative "../#{file}" }
