# WEBrickPHPHandler #

In this project a PHPHandler for the ruby WEBrick minimal webserver was created. With an PHP installation the
webserver can process php files and serve php websites.

## Files ##

- .idea => RubyMine project files
- docroot => example webserver root directory
- main.rb => example webserver start script
- phphandler.php => PHPHandler for WEBrick

## Prerequisites ##

- The handler supports PHP 5 and needs a PHP 5 installation.
- The WEBrick configuration :DocumentRoot has to be set
- The new WEBrick configuration :PHPPath has to be set

It is assumed that all php files are accessible from the :DocumentRoot path.

## Usage ##

    require 'webrick'
    require_relative 'phphandler'
    include WEBrick

    dir = File.join(File.dirname(__FILE__), "docroot")
    port = 8080
    phppath = File.join(File.dirname(__FILE__), "php-5.4.9-Win32-VC9-x86").gsub("/", "\\")

    server = HTTPServer.new(
        :Port => port,
        :DocumentRoot => dir,
        :PHPPath => phppath
    )
    server.mount("/", HTTPServlet::FileHandler, dir,
        {:FancyIndexing => true, :HandlerTable => {"php" => HTTPServlet::PHPHandler}})

    trap("INT") { server.shutdown }
    server.start

