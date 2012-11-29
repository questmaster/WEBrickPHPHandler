#
# cgihandler.rb -- CGIHandler Class
#
# Author: IPR -- Internet Programming with Ruby -- writers
# Copyright (c) 2001 TAKAHASHI Masayoshi, GOTOU Yuuzou
# Copyright (c) 2002 Internet Programming with Ruby writers. All rights
# reserved.
#
# $IPR: cgihandler.rb,v 1.27 2003/03/21 19:56:01 gotoyuzo Exp $

require 'rbconfig'
require 'tempfile'
require 'webrick/config'
require 'webrick/httpservlet/abstract'

module WEBrick
  module HTTPServlet

    class PHPHandler < AbstractServlet
      PHPCGI = 'php-cgi.exe'

      def initialize(server, name)
        super(server, name)
        @phpcmd = File.join(@server[:PHPPath], PHPCGI).gsub("/", "\\")
      end

      def do_GET(req, res)
        data = nil
        status = -1

        meta = req.meta_vars
        meta["SCRIPT_FILENAME"] = File.join(@config[:DocumentRoot], meta['SCRIPT_NAME']).gsub("/", "\\")
        meta["PATH"] = @config[:CGIPathEnv]
        if /mswin|bccwin|mingw/ =~ RUBY_PLATFORM
          meta["SystemRoot"] = ENV["SystemRoot"]
        end
        ENV.update(meta)

        cgi_in = IO::popen(@phpcmd, "r+b")
        begin
          cgi_in.sync = true
        ensure
          data = cgi_in.read
          cgi_in.close
          status = $?.exitstatus
          sleep 0.1 if /mswin|bccwin|mingw/ =~ RUBY_PLATFORM
        end

        @script_filename = meta['SCRIPT_NAME']
        if status != 0
          @logger.error("CGIHandler: #{@script_filename} exit with #{status}")
        end

        data = "" unless data
        raw_header, body = data.split(/^[\xd\xa]+/, 2)
        raise HTTPStatus::InternalServerError,
              "Premature end of script headers: #{@script_filename}" if body.nil?

        begin
          header = HTTPUtils::parse_header(raw_header)
          if /^(\d+)/ =~ header['status'][0]
            res.status = $1.to_i
            header.delete('status')
          end
          if header.has_key?('location')
            # RFC 3875 6.2.3, 6.2.4
            res.status = 302 unless (300...400) === res.status
          end
          if header.has_key?('set-cookie')
            header['set-cookie'].each { |k|
              res.cookies << Cookie.parse_set_cookie(k)
            }
            header.delete('set-cookie')
          end
          header.each { |key, val| res[key] = val.join(", ") }
        rescue => ex
          raise HTTPStatus::InternalServerError, ex.message
        end
        res.body = body
      end

      alias do_POST do_GET
    end

  end
end
