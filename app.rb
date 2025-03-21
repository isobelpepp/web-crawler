require 'sinatra'
require './lib/controllers/crawler_controller.rb' 

set :views, File.join(__dir__, 'lib', 'views')

get '/' do
  erb :crawler
end

post '/' do
  @url = params[:url]
  begin
    @output = CrawlerController.process_url(@url)
  rescue ArgumentError => e
    @error_message = e.message
  end
  erb :crawler
end
