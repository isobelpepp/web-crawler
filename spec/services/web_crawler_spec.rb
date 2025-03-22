require 'webmock/rspec'
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
      stub_request(:get, "https://example.com/")
        .to_return(status: 200, body: '<html><a href="https://example.com/page1">Page 1</a><a href="https://example.com/page2">Page 2</a></html>', headers: {})
      stub_request(:get, "https://example.com/page1")
        .to_return(status: 200, body: '<html></html>', headers: {})
      stub_request(:get, "https://example.com/page2")
        .to_return(status: 200, body: '<html></html>', headers: {})

       response = crawler.crawl

        expected_links = {
        "https://example.com/" => ["https://example.com/page1", "https://example.com/page2"],
        "https://example.com/page1" => ["No links found."],
        "https://example.com/page2" => ["No links found."]
        }

        expect(response).to eq(expected_links)
    end
    
    it "crawls the starting URL and collects all relative page links" do
      stub_request(:get, "https://example.com/")
        .to_return(status: 200, body: '<html><a href="/page1">Page 1</a><a href="/page2">Page 2</a></html>', headers: {})
      stub_request(:get, "https://example.com/page1")
        .to_return(status: 200, body: '<html></html>', headers: {})
      stub_request(:get, "https://example.com/page2")
        .to_return(status: 200, body: '<html></html>', headers: {})

       response = crawler.crawl

        expected_links = {
        "https://example.com/" => ["https://example.com/page1", "https://example.com/page2"],
        "https://example.com/page1" => ["No links found."],
        "https://example.com/page2" => ["No links found."]
        }

        expect(response).to eq(expected_links)
    end

    it "crawls the starting URL and collects all page links" do
      stub_request(:get, "https://example.com/")
        .to_return(status: 200, body: '<html><a href="/page1">Page 1</a></html>', headers: {})
  
      stub_request(:get, "https://example.com/page1")
        .to_return(status: 200, body: '<html><a href="/page2">Page 2</a><a href="/page3">Page 23/a></html>', headers: {})
  
      stub_request(:get, "https://example.com/page2")
        .to_return(status: 200, body: '<html><a href="/page3">Page 3</a></html>', headers: {})
  
      stub_request(:get, "https://example.com/page3")
        .to_return(status: 200, body: '<html><a href="/page4">Page 4</a></html>', headers: {})
  
      stub_request(:get, "https://example.com/page4")
        .to_return(status: 200, body: '<html><a href="/page5">Page 5</a><a href="/page3">Page 3</a></html>', headers: {})
  
      stub_request(:get, "https://example.com/page5")
        .to_return(status: 200, body: '<html><a href="/page6">Page 6</a></html>', headers: {})
  
      stub_request(:get, "https://example.com/page6")
        .to_return(status: 200, body: '', headers: {})
    
      response = crawler.crawl

      expected_links = {
      "https://example.com/" => ["https://example.com/page1"],
      "https://example.com/page1" => ["https://example.com/page2", "https://example.com/page3"],
      "https://example.com/page2" => ["https://example.com/page3"],
      "https://example.com/page3" => ["https://example.com/page4"],
      "https://example.com/page4" => ["https://example.com/page5", "https://example.com/page3"],
      "https://example.com/page5" => ["https://example.com/page6"],
      "https://example.com/page6" => ["No links found."]
    }

      expect(response).to eq(expected_links)
    end

    it 'avoids crawling the same url twice' do
      stub_request(:get, "https://example.com/")
        .to_return(status: 200, body: '<html><a href="/page1">Page 1</a></html>', headers: {})
      stub_request(:get, "https://example.com/page1")
        .to_return(status: 200, body: '<html><a href="/page2">Page 2</a></html>', headers: {})
      stub_request(:get, "https://example.com/page2")
        .to_return(status: 200, body: '<html><a href="/page1">Page 1</a></html>', headers: {})
    
      response = crawler.crawl

      expected_links = {
        "https://example.com/" => ["https://example.com/page1"],
        "https://example.com/page1" => ["https://example.com/page2"],
        "https://example.com/page2" => ["https://example.com/page1"]
      }
    
      expect(response).to eq(expected_links)
    end
  end

  context "Network responses" do
    it 'follows redirects correctly' do
      # stub an empty page
    
      # crawl
    
      # expected links

      # expect output to be the same as empty links
    end

    it 'handles timeout errors' do
      stub_request(:get, "https://example.com/")
        .to_return(status: 200, body: '<html><a href="/page1">Page 1</a></html>', headers: {})
      stub_request(:get, "https://example.com/page1")
        .to_return(status: 200, body: '<html><a href="/timeout">Page 2</a></html>', headers: {})
      stub_request(:get, "https://example.com/timeout")
        .to_timeout
    
      response = crawler.crawl

      expected_links = {
        "https://example.com/" => ["https://example.com/page1"],
        "https://example.com/page1" => ["https://example.com/timeout"],
        "https://example.com/timeout" => ["Error fetching: https://example.com/timeout"]
      }
    
      expect(response).to eq(expected_links)
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
      body = "<html><a href='/page1'>Link 1</a><a href='/page2'>Link 2</a></html>"
      webpage_url = "https://example.com/start"

      crawler.extract_links(webpage_url, body)

      page_links = crawler.instance_variable_get(:@crawled_pages)
      expect(page_links[webpage_url]).to contain_exactly(
        "https://example.com/page1",
        "https://example.com/page2"
      )
    end

    it 'handles empty pages' do
      stub_request(:get, "https://example.com/")
      .to_return(status: 200, body: '<html></html>', headers: {})
    
      response = crawler.crawl

      expected_links = {
        "https://example.com/" => ["No links found."]
      }
    
      expect(response).to eq(expected_links)
    end

    it 'does not duplicate the same link and can handle a large amount of links' do
      large_html = '<html>' + ('<a href="/page">Link</a>' * 1000) + '</html>'
      stub_request(:get, "https://example.com/")
        .to_return(status: 200, body: large_html, headers: {})
      stub_request(:get, "https://example.com/page")
        .to_return(status: 200, body: '', headers: {})
    
      response = crawler.crawl

      expected_links = {
        "https://example.com/" => ["https://example.com/page"],
        "https://example.com/page" => ["No links found."]
      }
    
      expect(response).to eq(expected_links)
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
  end
end