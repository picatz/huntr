# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "huntr/version"

Gem::Specification.new do |spec|
  spec.name          = "huntr"
  spec.version       = Huntr::VERSION
  spec.authors       = ["Kent Gruber"]
  spec.email         = ["kgruber1@emich.edu"]

  spec.summary       = %q{A simple reconnaissance command-line application.}
  #spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "https://github.com/picatz/huntr"
  spec.license       = "MIT"
  
  spec.files         = Dir['lib/**/*.rb']
  spec.bindir        = 'bin'
  spec.executable    = "huntr"
  spec.require_paths = ['lib']

  spec.add_dependency "shodan"
  spec.add_dependency "command_lion"
  spec.add_dependency "nmapr"
  spec.add_dependency "colorize"
  spec.add_dependency "ipaddress"
  spec.add_dependency "whois-parser"
  spec.add_dependency "unirest"
  
  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
