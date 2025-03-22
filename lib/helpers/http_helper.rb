require 'httparty'

module Helper
  class HTTPHelper
    class << self

      def connect(webpage_url)
        begin
          HTTParty.get(webpage_url)
        rescue HTTParty::Error => e
          nil
          puts "HTTParty error: #{e.message} while connecting to #{webpage_url}"
        rescue StandardError => e
          nil
          puts "Standard error: #{e.message} while connecting to #{webpage_url}"
        end
      end

      def resolve_url(base_url, relative_url)
        return nil if relative_url.nil? || relative_url.start_with?('#')
        URI.join(base_url, relative_url).to_s
      rescue URI::InvalidURIError => e
        nil
      end

    end
  end
end
