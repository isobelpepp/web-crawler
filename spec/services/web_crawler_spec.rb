require_relative '../../lib/services/web_crawler'

RSpec.describe WebCrawler do
  let(:start_url) { "https://example.com/" }
  let(:crawler) { WebCrawler.new(start_url) }

  describe "#initialize" do
    it 'initializes with a start URL' do
      crawler = WebCrawler.new("https://example.com")
    
      expect(crawler.instance_variable_get(:@start_url)).to eq("https://example.com")
    end
  end

  describe "#crawl" do
    it "crawls the starting URL and collects all page links" do
    # stub http requests

    # call crawl

    # expected links = 

    # expect the output to be the same as expected links
    end
    it 'avoids crawling the same url twice' do
      # stub pages with a loop

      # crawl
    
      # expected links

      # expect output to be the same as empty links
    end
  end

  context "Network responses" do
    it 'goes on to process page if status is 200' do
    end
    it 'follows redirects correctly' do
      # stub an empty page
    
      # crawl
    
      # expected links

      # expect output to be the same as empty links
    end

    it 'handles timeout errors gracefully' do
      # simulate a timeout for a page

      # crawl
    
      # expected links

      # expect output to be the same as empty links
    end

    it 'handles 404 and 500 errors' do
      # stub a 404 error page

      # stub a 500 error page

      # crawl
    
      # expected links

      # expect output to be the same as empty links
    end
  end

  context "HTML processing" do
    it "extracts all links from a page's content" do
      # create body url and body to pass through

      # call extract content

      # expect output
    end
    it 'handles empty pages' do
      # stub an empty page
    
      # carwl
    
      # expected links

      # expect output to be the same as empty links
    end

    it 'handles pages with a large number of links' do
      # stub a page with many links

      # crawl
    
      # expected links

      # expect output to be the same as empty links
    end
    it 'skips non-HTML pages' do
      # stub a non-HTML page (e.g., PDF)

      # crawl
    
      # expected links

      # expect output to be the same as empty links
    end
  end

  context "URL resolution" do

    it 'handles invalid URLs gracefully' do
      # stub an invalid URL

      # crawl
    
      # expected links
    
      # expect output to be same as expected links
    end

    it 'correctly handles relative and absolute URLs' do
      # stub a page with relative and absolute URLs

      # crawl
    
      # expected links

      # expect output to be the same as empty links
    end
  end
end