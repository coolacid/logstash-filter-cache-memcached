# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"

# This example filter will replace the contents of the default 
# message field with whatever you specify in the configuration.
#
# It is only intended to be used as an example.
class LogStash::Filters::Memcached < LogStash::Filters::Base

  # Setting the config_name here is required. This is how you
  # configure this filter from your Logstash config.
  #
  # filter {
  #   example {
  #     message => "My message..."
  #   }
  # }
  #
  config_name "memcached"
  
  # The namespace for the cache, suggest the filter name you're going to cache
  config :namespace, :validate => :string, :required => true

  config :compress, :validate => :boolean, :default => true
  
  # The Host:port for the memcached server
  config :host, :validate => :string, :required => true

  # The TTL of the cached data, default 0 which means no expiry
  config :ttl, :validate => :number, :default => 0
 
  # Sets the action. If set to true, it will retreive the data
  config :retreive, :validate => :boolean, :default => false
  
  # The item you want to store or retrieve
  config :key, :validate => :string

  # The field you will store or retrive into
  config :field, :validate => :string


  public
  def register
    require 'dalli'
    options = { :namesapce => @namespace, :compress => @compress, :expires_in => @ttl }
    @cache = Dalli::Client.new(@host, options)
    # Add instance variables 
  end # def register

  public
  def filter(event)
    if @retreive
      event[@field] = @cache.get(@key)
      if event[@field] == nil
        event["tags"] ||= []
        event["tags"] << "cache_miss" unless event["tags"].include?("cache_miss")
      else
        # filter_matched should go in the last line of our successful code
        filter_matched(event)
      end
    else
      @cache.set(@key, event[@field])
      # filter_matched should go in the last line of our successful code
      filter_matched(event)
    end

  end # def filter
end # class LogStash::Filters::Example
