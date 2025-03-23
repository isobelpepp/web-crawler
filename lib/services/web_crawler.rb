require 'nokogiri'
require 'concurrent-ruby'
require 'logger'
require_relative '../helpers/http_helper'

class WebCrawler

  def initialize(start_url, max_time = nil)
    @start_url = start_url
    @max_time = max_time
    @start_time = Time.now
    @url_queue = Queue.new << @start_url
    @content_queue = Queue.new
    @url_count = Concurrent::AtomicFixnum.new(1) 
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
    @stop_accepting_new_tasks = false
    @done = false
    @logger = Logger.new(STDOUT)

    @logger.info("WebCrawler initialized with start URL: #{@start_url} and max time: #{@max_time}")
  end

  def crawl
    return @crawled_pages if @max_time == 0

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
      check_max_time

      break if @stop_accepting_new_tasks && @url_queue.empty?
  
      @mutex.synchronize { @condition.wait(@mutex) while @url_queue.empty? && !@done }

      webpage_url = @url_queue.pop(true) rescue nil
      break unless webpage_url

      @logger.info("Fetching URL: #{webpage_url}")
      response = Helper::HTTPHelper.connect(webpage_url)

      handle_response(webpage_url, response)
    end
  end

  def process_html_content
    while !@done
      check_max_time

      break if @stop_accepting_new_tasks && @content_queue.empty?

      @mutex.synchronize { @condition.wait(@mutex) while @content_queue.empty? && !@done }

      content = @content_queue.pop(true) rescue nil
      break unless content
      extract_links(content[:url], content[:body])

      @mutex.synchronize { close } if @url_count.value == 0 && @content_queue.length == 0
    end
  end

  def handle_response(webpage_url, response)
    if unsuccessful_response(response)
      handle_empty_response(webpage_url, response)
    else
      handle_success_response(webpage_url, response.body)
    end
  end

  def handle_empty_response(webpage_url, response)
    message = "Error fetching #{webpage_url} content"
    message << ", with response code: #{response.code}" if response
    
    @logger.error(message)
    @crawled_pages[webpage_url] = [message]

    @url_count.decrement
    @mutex.synchronize { close } if @url_count.value == 0 && @content_queue.length == 0
  end

  def handle_success_response(webpage_url, body)
    @logger.info("Successfully fetched #{webpage_url}")

    @content_queue << { url: webpage_url, body: body }
    @url_count.decrement
    @condition.broadcast
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
        log_links(full_url)
        links_on_page << full_url
      end
    end

    @crawled_pages[webpage_url] = links_on_page.uniq
    @condition.broadcast
  end

  private

  def unsuccessful_response(response)
    !response || response.body.nil? || response.body.empty? || response.code.to_i >= 400
  end

  def same_domain?(url)
    URI.parse(url).host == URI.parse(@start_url).host
  end

  def non_html_link(url)
    non_html_extensions = ['.jpg', '.jpeg', '.png', '.gif', '.pdf', '.css', '.js', '.json', '.xml']
  
    url.start_with?('mailto:') || non_html_extensions.any? { |ext| url.downcase.end_with?(ext) }
  end

  def log_links(url)
    @logger.info("Found link: #{url}")
    @url_count.increment
    @url_queue << url
    @logged_links.add(url)
  end


  def check_max_time
    return if !@max_time

    elapsed_time = Time.now - @start_time
    if elapsed_time > @max_time
      @logger.info("Maximum time exceeded. Shutting down process...")
      close
    end
  end

  def shut_down_pools
    @crawl_pool.shutdown
    @process_pool.shutdown
    @crawl_pool.wait_for_termination
    @process_pool.wait_for_termination

    @logger.info("Process shutdown complete.")
  end

  def close
    @done = true
    @stop_accepting_new_tasks = true
    @condition.broadcast 
  end
end
