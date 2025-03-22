require 'sinatra'
require './lib/controllers/crawler_controller.rb' 

set :views, File.join(__dir__, 'lib', 'views')

get '/' do
  erb :crawler
end

post '/' do
  @url = params[:url]
  @max_time = params[:max_time]
  begin
    @output = CrawlerController.process_url(@url, @max_time)
  rescue ArgumentError => e
    @error_message = e.message
  end
  erb :crawler
end
