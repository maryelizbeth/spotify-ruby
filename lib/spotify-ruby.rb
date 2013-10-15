require File.expand_path('../spotify/error', __FILE__)
require File.expand_path('../spotify/configuration', __FILE__)
require File.expand_path('../spotify/api', __FILE__)
require File.expand_path('../spotify/client', __FILE__)

module Spotify
  extend Configuration

  # Alias for Instagram::Client.new
  #
  # @return [Instagram::Client]
  def self.client(options={})
    Spotify::Client.new(options)
  end

  # Delegate to Instagram::Client
  def self.method_missing(method, *args, &block)
    return super unless client.respond_to?(method)
    client.send(method, *args, &block)
  end

  # Delegate to Instagram::Client
  def self.respond_to?(method)
    return client.respond_to?(method) || super
  end
end