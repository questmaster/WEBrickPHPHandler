# WEBrick - PHPHandler #

In this project a PHPHandler for the ruby WEBrick minimal webserver was created. With an PHP installation the
webserver can process php files and serve php websites.

## Files ##

- .idea => RubyMine project files
- docroot => example webserver root directory
- main.rb => example webserver start script
- phphandler.rb => PHPHandler for WEBrick

## Prerequisites ##

- Ruby with WEBrick
- The handler supports PHP 5 and needs a PHP 5 installation.
- The WEBrick configuration :DocumentRoot has to be set
- The new WEBrick configuration :PHPPath has to be set

It is assumed that all php files are accessible from the :DocumentRoot path.

## Usage ##

With the mount() method the PHPHandler can be registered for files with the .php file extension in the :HandlerTable.
Additionally :DocumentRoot has to be set to be able to resolve the local path of the files to be processed. Also the
:PHPPath variable has to be set to the location of the PHP 5 'php-cgi.exe' location.

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

