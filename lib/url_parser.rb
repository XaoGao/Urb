module Urb
  class UrlParser
    attr_reader :scheme, :host, :port, :paths, :queries

    def initialize(url)
      @scanner = StringScanner.new(url)
    end

    def parse
      @scheme = parse_scheme @scanner
      @host = parse_host @scanner
      @port = parse_port @scanner
      @paths = parse_paths @scanner
      @queries = parse_queries @scanner
    end

    private

    def parse_scheme(scanner)
      scheme = scanner.scan(/[^:\/?#]+/)
      if scheme.nil? || scheme.empty?
        ''
      else
        # remove "://"
        scanner.scan(/[:\/]+/)
        scheme
      end
    end

    def parse_host(scanner)
      host = scanner.scan(/[^:\/?#]+/)

      if host.nil? || host.empty?
        ''
      else
        host
      end
    end

    def parse_port(scanner)
      port = scanner.scan(/[:\d]+/)
      if port.nil? || port.empty?
        ''
      else
        port.delete(':')
      end
    end

    def parse_paths(scanner)
      paths = scanner.scan(/[^?]+/)
      if paths.nil? || paths.empty?
        []
      else
        paths.split('/').reject(&:empty?)
      end
    end

    def parse_queries(scanner)
      queries = scanner.scan(/[^#]+/)
      if queries.nil? || queries.empty?
        {}
      else
        queries.delete('?').split('&').map do |q|
          q.split('=')
        end.to_h.transform_keys(&:to_sym)
      end
    end
  end
end
