require 'httparty'
require 'logger'
require_relative '../../lib/services/web_crawler'

RSpec.describe Helper::HTTPHelper, type: :module do
  describe '.connect' do
    let(:webpage_url) { 'https://example.com' }
    let(:logger) { instance_double(Logger) }

    before do
      allow(Logger).to receive(:new).and_return(logger)
    end

    context 'when the request is successful' do
      before do
        allow(HTTParty).to receive(:get).with(webpage_url).and_return(double('response', code: 200))
      end

      it 'makes a GET request to the URL' do
        response = Helper::HTTPHelper.connect(webpage_url)
        expect(response.code).to eq(200)
      end
    end

    context 'when there is an HTTParty error' do
      before do
        allow(HTTParty).to receive(:get).and_raise(HTTParty::Error.new('Connection error'))
      end

      it 'logs the error and returns nil' do
        expect(logger).to receive(:error).with("HTTParty error: Connection error while connecting to #{webpage_url}")
        result = Helper::HTTPHelper.connect(webpage_url)
        expect(result).to be_nil
      end
    end

    context 'when there is a standard error' do
      before do
        allow(HTTParty).to receive(:get).and_raise(StandardError.new('Unknown error'))
      end

      it 'logs the error and returns nil' do
        expect(logger).to receive(:error).with("Standard error: Unknown error while connecting to #{webpage_url}")
        result = Helper::HTTPHelper.connect(webpage_url)
        expect(result).to be_nil
      end
    end
  end

  describe '.resolve_url' do
    let(:base_url) { 'https://example.com' }

    context 'when the relative URL is valid' do
      let(:relative_url) { '/about' }

      it 'resolves the relative URL to the full URL' do
        result = Helper::HTTPHelper.resolve_url(base_url, relative_url)
        expect(result).to eq('https://example.com/about')
      end
    end

    context 'when the relative URL is nil' do
      let(:relative_url) { nil }

      it 'returns nil' do
        result = Helper::HTTPHelper.resolve_url(base_url, relative_url)
        expect(result).to be_nil
      end
    end

    context 'when the relative URL had base url in it' do
      let(:relative_url) { 'https://example.com/page1' }

      it 'returns nil' do
        result = Helper::HTTPHelper.resolve_url(base_url, relative_url)
        expect(result).to eq("https://example.com/page1")
      end
    end

    context 'when the relative URL starts with a hash' do
      let(:relative_url) { '#section' }

      it 'returns nil' do
        result = Helper::HTTPHelper.resolve_url(base_url, relative_url)
        expect(result).to be_nil
      end
    end
  end
end