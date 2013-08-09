$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

# Core Libraries
require 'time'
require 'timeout'
require 'open-uri'

# Gems
require 'rubygems'
require 'hpricot'
require 'curb'
require 'nokogiri'

# Files
require 'amphibian/runner'
require 'amphibian/balancerManagerDocument'
