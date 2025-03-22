require "sinatra/base"
require 'net/http'
require_relative '../services/web_crawler'

class CrawlerController < Sinatra::Base
  set :default_content_type, 'application/json'

  def self.process_url(url, max_time)
    if url_exists?(url)
      converted_max_time = max_time.empty? ? nil : max_time.to_f
      crawler = WebCrawler.new(url, converted_max_time)
      crawler.crawl
    else
      raise ArgumentError, "Not a valid URL, please try again."
    end
  end

  def self.url_exists?(url)
    uri = parse_uri(url)
    return false unless uri
  
    return false unless valid_http_uri?(uri)
  
    check_http_response(uri)
  end

  private

  def self.parse_uri(url)
    URI.parse(url)
  rescue URI::InvalidURIError
    nil
  end
  
  def self.valid_http_uri?(uri)
    uri.is_a?(URI::HTTP) && !uri.host.nil?
  end
  
  def self.check_http_response(uri)
    response = Net::HTTP.get_response(uri)
    response.is_a?(Net::HTTPSuccess)
  rescue StandardError
    false
  end
end
