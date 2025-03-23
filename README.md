# Web Crawler

## Summary 

This is a simple web crawler that:

- Takes a starting URL as input.
- Visits each URL on the same domain as the starting URL.
- Prints all URLs visited and lists all the links found on each page.

## Getting Started

### Prerequisites

Before you can run this application, you will need Ruby 3.3.1 installed. Below are MacOS instructions for using a Ruby version manager (skip if you have Ruby installed).

#### 1. **Homebrew**

  Install Homebrew

  ```
  Homebrew - /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ```

  After installation, follow homebrew instructions in adding it to the right path.

#### 2. **RVM**

  Run the following commands in your terminal to install RVM:
  ```bash
  \curl -sSL https://get.rvm.io | bash -s stable
  ```

  ```
  source /Users/admin/.rvm/scripts/rvm
  ```

#### 3. **Ruby 3.3.1**

```
rvm install 3.3.1
```

#### 4. **Troubleshooting**

If you get an error from the above when compiling please try:

```
brew install openssl@3 
```

```
rvm install 3.3.1 --with-openssl-dir=$(brew --prefix openssl@3)
```

#### 5. **Bundler**

To install bundler:

```
gem install bundler   
```

### Running

To start up the app, run the following within the project directory :

```
bundle install
```

```
rerun 'ruby app.rb'
```

- **Visit localhost:4567** and input your choice of URL.

### Testing

To run all the tests, run the following within the main project directory:

```
rspec
```

## Future Improvements

- **Retry on specific HTTP responses**: Implement retries for `202 Accepted` and `429 Too Many Requests`.
- **Testing**: Improve testing around concurrency / race conditions.
- **Error handling**: Improve error handling when making HTTP requests (instead of just returning nil).
- **Enhanced HTTP requests**:  Add support for custom headers, persistent connections, and checking the `robots.txt` file for crawl restrictions.
- **Redirect Handling**: Improve clarity surrounding redirected requests.
- **Mid crawl interruption**: Allow for user to stop the crawl and output data collected so far.
- **Real-time updates**: Dynamically update page with latest crawl information.
