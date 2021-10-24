require 'uri'

module Urb
  class Builder
    def initialize(url = nil)
      parse! url
    end

    # Add fragment to path url
    # For example:
    #
    #   Urb::Builder('http://google.com).append('new_fragment', 'second_fragment')
    #
    # Result will be: 'http://google.com/new_fragment/second_fragment'
    #
    # Retrun self instnce
    def append(*paths)
      paths.each do |path|
        @paths << path.to_s
      end

      self
    end

    # Add new query params to url
    # For example:
    #
    #   Urb::Builder('http://google.com/some_path).add(q: 'one', w: 'two)
    #
    # Result will be: 'http://google.com/some_path?q=one&w=two'
    #
    # Retrun self instnce
    def add(params)
      params.each do |key, value|
        @queries[key] = value unless @queries.key?(key)
      end

      self
    end

    # Ovrride existed query params to url
    # For example:
    #
    #   Urb::Builder('http://google.com/some_path?q=cat&w=mouse).add(q: 'dog')
    #
    # Result will be: 'http://google.com/some_path?q=dog&w=mouse'
    #
    # Retrun self instnce
    def over(params)
      params.each do |key, value|
        @queries[key] = value if @queries.key?(key)
      end

      self
    end

    # Delete existed query params to url
    # For example:
    #
    #   Urb::Builder('http://google.com/some_path?q=cat&w=mouse).add(q)
    #
    # Result will be: 'http://google.com/some_path?w=mouse'
    #
    # Retrun self instnce
    def del(*keys)
      keys.each do |key|
        @queries.delete(key)
      end

      self
    end

    # Replase a url scheme to new
    # Allow list for scheme:
    #   ftp http rtmp rtsp https gopher mailto news nntp irc smb prospero telnet
    #   wais xmpp file data tel afs cid mid mailserver nfs tn3270 z39 skype smsto
    #   ed2k market steam bitcoin ob tg
    #
    # For example:
    #
    #   Urb::Builder('http://google.com/some_path?q=cat&w=mouse).scheme('https')
    #
    # Result will be: 'https://google.com/some_path?w=mouse'
    #
    # Retrun self instnce
    def scheme(new_scheme)
      allow_list = %w[ftp http rtmp rtsp https gopher mailto news nntp irc smb prospero telnet
                      wais xmpp file data tel afs cid mid mailserver nfs tn3270 z39 skype smsto
                      ed2k market steam bitcoin ob tg]
      unless allow_list.include?(new_scheme)
        raise Urb::InvalidUrl
      end

      @scheme = new_scheme

      self
    end

    # Replase a url host to new
    # host must not be empty and include '.' and
    #
    # For example:
    #
    #   Urb::Builder('http://google.com/some_path?q=cat&w=mouse).host('www.example.us')
    #
    # Result will be: 'https://www.example.us/some_path?w=mouse'
    #
    # Retrun self instnce
    def host(new_host)
      unless host_valid? new_host
        raise Urb::InvalidUrl 'Try to set a invalid value to host'
      end

      @host = new_host

      self
    end

    # Replase a url port to new
    # host must not be empty, be number with size equle 4
    #
    # For example:
    #
    #   Urb::Builder('http://google.com:3001/some_path?q=cat&w=mouse).port('4432')
    #
    # Result will be: 'https://google.com:4432/some_path?w=mouse'
    #
    # Retrun self instnce
    def port(new_port)
      unless port_valid? new_port
        raise Urb::InvalidUrl 'Try to set a invalid value to port'
      end

      @port = new_port

      self
    end

    # Build new url like URI
    # host segment must be not empty
    #
    # For example:
    #
    #   Urb::Builder('http://google.com:3001/some_path?q=cat&w=mouse).port('4432')
    #
    # Result will be: 'https://google.com:4432/some_path?w=mouse'
    #
    # Retrun self instnce
    def build_as_string
      if @host.nil? || @host.empty?
        raise Urb::InvalidUrl 'Host is can not be bil or empty'
      end

      "#{safe_scheme}#{@host}#{safe_port}#{safe_path}#{safe_queries}"
    end

    # Build new url like string
    # host segment must not be
    #
    # For example:
    #
    #   Urb::Builder('http://google.com:3001/some_path?q=cat&w=mouse).build_as_string
    #
    # Result will be: 'https://google.com:3001/some_path?w=mouse'
    #
    # Retrun string
    def build_as_url
      URI(build_as_string)
    rescue Urb::InvalidUrl => e
      return URI('/')
    end

    private

    def safe_scheme
      if @scheme.nil? || @scheme.empty?
        ''
      else
        "#{@scheme}://"
      end
    end

    def safe_port
      if @port.nil? || @port.empty?
        ''
      else
        ":#{@port}"
      end
    end

    def safe_path
      if @paths.nil? || @paths.empty?
        ''
      else
        "/#{@paths.join('/')}"
      end
    end

    def safe_queries
      if @queries.nil? || @queries.empty?
        ''
      else
        array_queries = @queries.map { |key, value| "#{key}=#{value}" }.join('&')
        "?#{array_queries}"
      end
    end

    def parse!(url = nil)
      if url.nil?
        @scheme = ''
        @host = ''
        @port = ''
        @paths = []
        @queries = {}
      else
        parser = Urb::UrlParser.new(url)
        parser.parse
        @scheme = parser.scheme
        @host = parser.host
        @port = parser.port
        @paths = parser.paths
        @queries = parser.queries
      end
    end

    def host_valid?(host)
      if verify_host host
        return true
      end

      false
    rescue StandardError => e
      false
    end

    def verify_host(host)
      !host.empty? && host.include?('.')
    end

    def port_valid?(port)
      if verify_port port
        return true
      end

      false
    rescue StandardError => e
      false
    end

    def verify_port(port)
      !port.to_s.empty? && port.is_a?(Numeric) && port.to_s.size == 4
    end
  end
end
