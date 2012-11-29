#!/usr/local/bin/ruby
require 'webrick'
require_relative 'phphandler'
include WEBrick

dir = File.join(File.dirname(__FILE__), "docroot")
port = 8080

# path to PHP 5 binaries
phppath = File.join(File.dirname(__FILE__), "php-5.4.9-Win32-VC9-x86").gsub("/", "\\")

puts "URL: http://#{Socket.gethostname}:#{port}"

s = HTTPServer.new(
    :Port => port,
    :DocumentRoot => dir,
    :PHPPath => phppath
)
s.mount("/", HTTPServlet::FileHandler, dir, {:FancyIndexing => true, :HandlerTable => {"php" => HTTPServlet::PHPHandler}})

trap("INT") { s.shutdown }
s.start
