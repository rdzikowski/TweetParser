##################################
#                                #
# Author: Robert Dzikowski       #
# email:  rdzikowski@gmail.com   #
#                                #
##################################


require 'uri'
require 'net/http'
require 'timeout'

require 'rubygems'
require 'hpricot'

$MY_DEBUG = false


class TweetParser

  SERVER_TIMEOUT = 5  #Timeout in sec. for waiting on web server
  
  IMAGE_EXT = /\.bmp|\.gif|\.jpg|\.jpeg|\.png|\.tif|\.tiff/
  IMAGE = 'image file' #This constant is returned when url links to an image

  DOC_EXT = /\.doc|\.pdf|\.ppt|\.ps|\.rtf|\.xls|\.xml|\.swf|\.txt/

  
  #Arguments:
  # - tweet is a string
  #
  #Returns:
  # - user is a string, such as zpinter;
  #   url is a string, such as http://www.google.com/intl/en_ALL/images/logo.gif;
  #   title is a string, such as logo.gif
  #
  # - nil when parse can't get user or url or title
  #
  #Exceptions:
  # - ArgumentError is raised when tweet arg. isn't a String or is nil
  #
  def parse( tweet )

    if ( tweet == nil ) or ( tweet.class != String )
      raise ArgumentError, 'the argument is not a String or is nil'
    end
    
    begin
      result = parse_tweet( tweet )
    rescue NoUserNameError => ex
      STDERR.puts "parse(): #{ex.message}"
      return nil
    end

    return nil if result == nil
    
    user = result[:user_name]
    trans_url = result[:trans_url]

    begin
      result = get_web_document( trans_url )
    rescue Timeout::Error => ex
      STDERR.puts '<---------        Timeout        --------->'
      STDERR.puts
      return nil
    rescue URI::InvalidURIError => ex
      return nil
    rescue => ex
      STDERR.puts "parse(): #{ex.class}, #{ex.message}"
      return nil
    end

    return nil if result == nil

    doc = result[:doc]
    url = result[:url]

    title = scraper( :url => url, :doc => doc )

    return nil if title == nil

    return [user, url, title]
  end

##################################################################################




private

  #Arguments:
  # - tweet is a String
  #
  #Returns:
  # - :user_name is a string. user_name are characters from beginning of a tweet
  #     to a colon, eg. "zpinter: just ..." - user_name is zpinter.
  #   :trans_url is a string.
  #     If url isn't delimited by white space at its end
  #     then incorrect string maybe be returned, e.g. if tweet contains
  #     "http://some-url.com.rest of the text" then "http://some-url.com.rest"
  #     will be returned instead of "http://some-url.com".
  #
  # - nil if tweet doesn't contain url starting with "http://"
  #
  #Exceptions:
  #- NoUserNameError is raised if tweet doesn't contain a colon character or
  #  user_name is shorter than two characters.
  #
  def parse_tweet( tweet )

    if ( ! tweet.index( ':' ))  or  ( ! (tweet.index( ':' ) >= 2) )
      raise NoUserNameError
    end

    #Return nil if tweet doesn't contain "http://" string
    return nil unless tweet.index('http://')

    #Find user name
    user = tweet[0 .. tweet.index( ':' ) - 1]

    #Find first occurence of "http://" string and all following characters
    #upto first white space.
    t_url = tweet.match(/http:\/\/\S+/)[0]

    #Cut last character if it is one of "." "," ";" ":"
    if t_url[-1, 1].match(/[.,;:]/)
      t_url.chop!
    end

    return { :user_name => user, :trans_url => t_url }

  end


  class NoUserNameError < StandardError
    # This exception is raised when
    # there is no colon (i.e. user name) in a tweet;
    # or when the user name is shorter than two characters.

    def message
      'There is no user name in the tweet message.'
    end
  end




  #Arguments:
  #- trans_url is a String
  #
  #Returns:
  #- String :doc is the web document or IMAGE constant;
  #  String :url is a url of this document.
  #
  #- nil if HTTP error (like non existent web page) was encountered or
  #      if extension of the document is DOC_EXT - non html document
  #
  #Exceptions:
  #- Timeout::Error is raised when web server pointed by trans_url is unaccessible
  #
  #- URI::InvalidURIError is raised for incorrect trans_url
  #
  def get_web_document( trans_url )
    uri = URI.parse( trans_url )

    #I am checking doc types here in order not to download big files
    if is_it_image?( uri.to_s )
      return  { :doc => IMAGE, :url => uri.to_s }
    end
    if is_it_non_html_doc?( uri.to_s )
      return nil
    end

    #puts 'connecting to server' if $MY_DEBUG
    
#    response = Timeout::timeout( SERVER_TIMEOUT ) do
#      Net::HTTP.get_response( uri )
#    end
    response = Timeout::timeout( SERVER_TIMEOUT ) do
      Net::HTTP.get_with_headers( uri,
                                  'User-Agent' => \
                                  'Mozilla/4.0 (compatible; MSIE 5.5; Windows NT 5.0)' )
    end
    
    case response
      when Net::HTTPSuccess:
        return { :doc => response.body, :url => uri.to_s }
      when Net::HTTPRedirection:
        puts 'redirected...' if $MY_DEBUG
        return get_web_document( response['Location'] )
      else
        return nil
    end #case
  end




  #Arguments:
  #- :url is a String, it is url of the web document
  #- :doc is a String, it contains the web document or IMAGE constant
  #
  #Returns:
  #- nil if the document isn't image file or html page
  #  
  #- String, which is:
  #  - file name if the document is an image file or
  #  - contents of <title> element if the document is a html page
  #
  def scraper( args )

    url = args[:url]
    document = args[:doc]

    # Return file name for urls marked with IMAGE
    if document == IMAGE
      return url[( url.rindex('/') + 1 ) .. -1]
    end

    # if the document doesn't have a <title> element inside <head> element
    # then return nil
    # else return title of this document
    Hpricot.buffer_size = 262144  #for html pages with very long attributes
    doc = Hpricot( document )
    arr = doc.search( "head/title" )

    if arr.empty?
      return nil  #This isn't image file or html document
    else
      title = arr[0].inner_html.strip
      return title
    end    
  end
########################################################################



  
  def is_it_image?( url )
    return url[url.rindex('.') .. -1] =~ IMAGE_EXT
  end

  def is_it_non_html_doc?( url )
    return url[url.rindex('.') .. -1] =~ DOC_EXT
  end
end
########################################################################




#A simple wrapper method that accepts either strings or URI objects
#and performs an HTTP GET.
module Net

  class HTTP

    def HTTP.get_with_headers(uri, headers=nil)
      uri = URI.parse(uri) if uri.respond_to? :to_str

      if uri.path.empty? or uri.path.nil?
        uri.path = '/'
      end

      start(uri.host, uri.port) do |http|
        return http.get(uri.path, headers)
      end
    end
  end #class HTTP

end
















