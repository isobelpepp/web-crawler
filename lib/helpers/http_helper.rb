require 'httparty'
require 'logger'

module Helper
  class HTTPHelper
    class << self

      def connect(webpage_url)
        logger = Logger.new(STDOUT)
        begin
          HTTParty.get(webpage_url)
        rescue HTTParty::Error => e
          nil
          logger.error("HTTParty error: #{e.message} while connecting to #{webpage_url}")
        rescue StandardError => e
          nil
          logger.error("Standard error: #{e.message} while connecting to #{webpage_url}")
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
