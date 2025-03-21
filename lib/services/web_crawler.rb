class WebCrawler
  def initialize(start_url)
    @start_url = start_url
  end

  def crawl
    # Add start URL to queue

    # Fetch html content from url
      # crawl_url

    # Process content queue for more urls
      # process_html_content

    # Finish process
  end

  def crawl_url
    # while loop - execute while process is running (@done flag)

    # make sure to wait until there are urls in the queue

    # take url from the queue

    # connect to url + get html content
      # response = fetch_webpage (bring in helper to handle this)
      # decrease the URL count

    # add html contents to the queue to be processed
      # add_html_to_queue(respone)
  end

  def add_html_to_queue(respone)
    # if response is a success
      # add html content to queue
        # increase content count 
        # broadcast this change

    # else
      # add URL to final list with error message
      # if this is the last URL and there is no more content to process then shutdown
  end


  def process_html_content
    # while loop - execute while process is running (@done flag)

    # wait until the contents queue is populated

    # extract any links from the html
      # extract_links

    # decrease the number of content to process

    # close if there is no more content to process (and no more urls in the queue)

  end

  def extract_links(webpage_url, body)
    # parse the HTML

    # loop through all the links
      # check that the link is a proper link
        # return if it isn't a proper link
      # check if it is in the same domain
        # if it isn't then add it to the end result for the URL and return
      # check if the link has already been added to the url queue (use logged_links bc queue will remove urls once processed)
        # if it has already been logged then add to end result and return

      # if it is a new link 
        # add it to the url queue
        # increase the url_count to process
        # add it to logged links
        # add it to end result for url being processed
    
    # at end of loop
      # add all of the links found to the final object 
      # broadcast the changes to url queue and count
  
    # if there were no links found then add that result to the final object

  end
end
