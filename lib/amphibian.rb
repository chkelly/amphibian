$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

# Core Libraries
require 'time'
require 'timeout'
require 'open-uri'

# Gems
require 'rubygems'
require 'hpricot'

# Files
require 'amphibian/runner'
require 'amphibian/balancerManagerDocument'


module Amphibian
  VERSION = '0.0.2'
end