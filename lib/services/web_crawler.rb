require 'nokogiri'
require 'concurrent-ruby'
require_relative '../helpers/http_helper'

class WebCrawler
  def initialize(start_url)
    @start_url = start_url
    @url_queue = Queue.new << @start_url
    @content_queue = Queue.new
    @url_count = Concurrent::AtomicFixnum.new(1) 
    @content_count = Concurrent::AtomicFixnum.new(0)
    @crawled_pages = {}
    @cpu_cores = Etc.nprocessors
    @logged_links = Concurrent::Set.new.add(@start_url)
    @mutex = Mutex.new
    @condition = ConditionVariable.new
    @crawl_pool = Concurrent::ThreadPoolExecutor.new(
      min_threads: 5,
      max_threads: 100,
    )
    @process_pool = Concurrent::ThreadPoolExecutor.new(
      min_threads: 5,
      max_threads: 100,
    )
    @done = false
  end

  def crawl

    @cpu_cores.times do
      @crawl_pool.post { crawl_url }
    end

    @cpu_cores.times do
      @process_pool.post { process_html_content }
    end

    shut_down_pools

    @crawled_pages
  end

  def crawl_url
    while !@done
      @mutex.synchronize { @condition.wait(@mutex) while @url_queue.empty? && !@done }

      webpage_url = @url_queue.pop(true) rescue nil
      break unless webpage_url

      response = Helper::HTTPHelper.connect(webpage_url)

      handle_response(webpage_url, response)
    end
  end

  def handle_response(webpage_url, response)
    if !response || response.code.to_i >= 400
      message = "Error fetching #{webpage_url}"
      message << ", with response code: #{response.code}" if response
      @crawled_pages[webpage_url] = [message]
      @url_count.decrement
      @mutex.synchronize { close } if @url_count.value == 0 && @content_count.value == 0
    else
      @content_queue << { url: webpage_url, body: response.body }
      @content_count.increment
      @url_count.decrement
      @condition.broadcast
    end
  end

  def process_html_content
    while !@done

      @mutex.synchronize { @condition.wait(@mutex) while @content_queue.empty? && !@done }

      content = @content_queue.pop(true) rescue nil
      break unless content

      extract_links(content[:url], content[:body])
      @content_count.decrement

      @mutex.synchronize { close } if @url_count.value == 0 && @content_count.value == 0
    end
  end

  def extract_links(webpage_url, body)
    doc = Nokogiri::HTML(body)

    links_on_page = []
    doc.css('a').each do |anchor_tag|
      link = anchor_tag['href']
      next unless link

      full_url = Helper::HTTPHelper.resolve_url(webpage_url, link)
      next unless full_url

      if @logged_links.include?(full_url) || !same_domain?(full_url) || non_html_link(full_url)
        links_on_page << full_url
      else
        puts "Found link: #{full_url}"
        @url_count.increment
        @url_queue << full_url
        @logged_links.add(full_url)
        links_on_page << full_url
      end
      @condition.broadcast
    end
    links_on_page.empty?  ? @crawled_pages[webpage_url] = ["No links found."] : @crawled_pages[webpage_url] = links_on_page.uniq
    @condition.broadcast
  end

  def same_domain?(url)
    URI.parse(url).host == URI.parse(@start_url).host
  end

  def non_html_link(url)
    non_html_extensions = ['.jpg', '.jpeg', '.png', '.gif', '.pdf', '.css', '.js', '.json', '.xml']
  
    url.start_with?('mailto:') || non_html_extensions.any? { |ext| url.downcase.end_with?(ext) }
  end

  def shut_down_pools
    @crawl_pool.shutdown
    @process_pool.shutdown
    @crawl_pool.wait_for_termination
    @process_pool.wait_for_termination
  end

  def close
    @done = true
    @condition.broadcast 
  end
end
