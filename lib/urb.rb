require 'urb/version'
require_relative './builder'
require_relative './url_parser'

module Urb
  # When URI is not valid.
  class InvalidUrl < StandardError; end
end
