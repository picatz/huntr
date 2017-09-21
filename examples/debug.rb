$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'huntr'
require 'pry'

target = Huntr::Target.new("74.208.110.154")

binding.pry
