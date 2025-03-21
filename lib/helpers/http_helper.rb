require 'httparty'

module Helper
  class HTTPHelper
    class << self

      def connect(webpage_url)
        begin
          HTTParty.get(webpage_url)
        rescue HTTParty::Error => e
          puts "HTTParty error: #{e.message} while connecting to #{webpage_url}"
        rescue StandardError => e
          puts "Standard error: #{e.message} while connecting to #{webpage_url}"
        end
      end

    end
  end
end
