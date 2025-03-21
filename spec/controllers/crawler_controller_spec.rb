require 'rspec'
require_relative '../../lib/controllers/crawler_controller'

RSpec.describe CrawlerController do

  describe '.url_exists?' do

    it 'returns true for valid HTTP URLs' do
      uri = URI.parse('http://example.com')
      allow(Net::HTTP).to receive(:get_response).with(uri).and_return(double('response', is_a?: true, code: '200'))
      expect(CrawlerController.url_exists?('http://example.com')).to be true
    end

    it 'returns true for valid HTTPs URLs' do
      uri = URI.parse('https://example.com')
      allow(Net::HTTP).to receive(:get_response).with(uri).and_return(double('response', is_a?: true, code: '200'))
      expect(CrawlerController.url_exists?('https://example.com')).to be true
    end

    it 'returns false for non-URLs' do
      expect(CrawlerController.url_exists?('bad_url')).to be false
      expect(CrawlerController.url_exists?('ht://example.com')).to be false
      expect(CrawlerController.url_exists?(':)')).to be false
    end

    it 'returns false for invalid URLs' do
      uri = URI.parse('http://invalid.com/invalid')
      allow(Net::HTTP).to receive(:get_response).with(uri).and_raise(StandardError)
      expect(CrawlerController.url_exists?('http://invalid.com/invalid')).to be false
    end

    it 'returns false for invalid URLs' do
      uri = URI.parse('http://')
      allow(Net::HTTP).to receive(:get_response).with(uri).and_raise(StandardError)
      expect(CrawlerController.url_exists?('http://')).to be false
    end
  end
end
