#!/usr/bin/ruby
#
lib = File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))
$LOAD_PATH.unshift(lib)

require 'gis'
Gis.new(ARGV).run
