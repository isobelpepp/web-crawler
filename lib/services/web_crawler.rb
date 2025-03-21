require 'nokogiri'
require_relative '../helpers/http_helper'

class WebCrawler
  def initialize(start_url)
    @start_url = start_url
    @url_queue = Queue.new << @start_url
    @content_queue = Queue.new
    @crawled_pages = {}
  end

  def crawl
    crawl_url

    process_html_content

    @crawled_pages
  end

  def crawl_url
    webpage_url = @url_queue.pop

    response = Helper::HTTPHelper.connect(webpage_url)

    handle_response(webpage_url, response)
  end

  def handle_response(webpage_url, response)
    #handle http errors
    if response.success?
      @content_queue << { url: webpage_url, body: response.body }
    else
      @crawled_pages[webpage_url] = ["Error fetching: #{webpage_url}, with response code: #{status}"]
    end
  end

  def process_html_content
    content = @content_queue.pop
    extract_links(content[:url], content[:body])
  end

  def extract_links(webpage_url, body)
    doc = Nokogiri::HTML(body)

    links_on_page = []
    doc.css('a').each do |anchor_tag|
      link = anchor_tag['href']
      next unless link

      full_url = resolve_url(webpage_url, link)

      @url_queue << full_url
      links_on_page << full_url
    end

    links_on_page.empty?  ? @crawled_pages[webpage_url] = ["No links found."] : @crawled_pages[webpage_url] = links_on_page
  end

  def resolve_url(base_url, relative_url)
    return nil if relative_url.nil? || relative_url.start_with?('#')
    URI.join(base_url, relative_url).to_s
  rescue URI::InvalidURIError => e
    nil
  end
end
