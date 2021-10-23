module Urb
  class Builder
    def initialize(url = nil)
      @queries = {}
      @paths = []
      @scheme = ''
      @host = ''
      parse! url
    end

    def append(*paths)
      paths.each do |path|
        @paths << path.to_s
      end

      self
    end

    def add(params)
      params.each do |key, value|
        @queries[key] = value unless @queries.key?(key)
      end

      self
    end

    def over(params)
      params.each do |key, value|
        @queries[key] = value if @queries.key?(key)
      end

      self
    end

    def del(*keys)
      keys.each do |key|
        @queries.delete(key)
      end

      self
    end

    def scheme(new_scheme)
      allow_list = %w[http https]
      raise Urb::InvalidUrl unless allow_list.include?(new_scheme)

      @scheme = new_scheme

      self
    end

    # def base_url

    # end

    def port; end

    # def build
    #   url_string = "#{schema}#{base_url}#{port}"
    # end

    private

    def parse!(url = nil); end

    def default_schema
      'http'
    end
  end
end
