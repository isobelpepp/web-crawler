require 'sinatra'

set :views, File.join(__dir__, 'lib', 'views')

get '/' do
  erb :crawler
end

post '/' do
  # Call crawler controller to process url

  # mock output
  @output = { "url1": ["url2", "url3"], "url2": ["url3"]}
  erb :crawler
end
