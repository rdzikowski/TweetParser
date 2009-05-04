##################################
#                                #
# Author: Robert Dzikowski       #
# email:  rdzikowski@gmail.com   #
#                                #
##################################


#require 'tweet_parser'
require File.dirname(__FILE__) + '/../lib/tweet_parser'

describe TweetParser, '#parse_tweet' do

  before(:each) do
    @tp = TweetParser.new
  end

  it "should raise NoUserNameError exception for tweets without a colon character" do
    lambda { @tp.parse_tweet 'message without a colon' }.should \
      raise_error(TweetParser::NoUserNameError)

    lambda { @tp.parse_tweet '' }.should \
      raise_error(TweetParser::NoUserNameError)
  end


  it "should raise NoUserNameError exception for tweets with user name " +
     "shorter than two characters" do
    lambda { @tp.parse_tweet '1: message with colon' }.should \
      raise_error(TweetParser::NoUserNameError)

    lambda { @tp.parse_tweet ':' }.should \
      raise_error(TweetParser::NoUserNameError)
  end


  it "should not raise NoUserNameError exception for tweets with correct user name" do
    lambda { @tp.parse_tweet 'tom: msg with colon and user name' }.should_not \
      raise_error(TweetParser::NoUserNameError)

    lambda { @tp.parse_tweet 'tom:msg with colon and user name' }.should_not \
      raise_error(TweetParser::NoUserNameError)
  end


  it "should return nil for tweets without url" do
    @tp.parse_tweet( 'tom: message http:/wrong.com, www.ex.com' ).should be_nil
  end


  it "should return user name and url for tweets with url" do
    @tp.parse_tweet( 'tom: msg with url : ' +
                      'http://www.example.com.').should \
                      == { :user_name =>'tom',
                           :trans_url =>'http://www.example.com'}
    @tp.parse_tweet( 'tom:wrong url http:/wrong.com :' +
                      'www.ex.com andhttp://h-page.com').should \
                      == { :user_name =>'tom',
                           :trans_url => 'http://h-page.com'}
    @tp.parse_tweet( 'tom:http://111.33.33.33, : ' +
                      'http://second.com').should \
                      == { :user_name =>'tom',
                           :trans_url => 'http://111.33.33.33'}
    @tp.parse_tweet( 'tom: http://sth.com:8888/sth.htm, : ' +
                      'http://second.com').should \
                      == { :user_name =>'tom',
                           :trans_url => 'http://sth.com:8888/sth.htm'}
    @tp.parse_tweet( 'mopostal: saturated market = end of detroit as we know it ' +
                      'http://bit.ly/qaUN').should \
                      == { :user_name =>'mopostal',
                           :trans_url => 'http://bit.ly/qaUN'}
  end
end




describe TweetParser, '#scraper' do

  before(:each) do
    @tp = TweetParser.new
  end

  it "should return file name if document is an image file" do
    @tp.scraper( :url => 'http://www.dummy.com/intl/en_ALL/images/logo.gif',
                  :doc => TweetParser::IMAGE).should == 'logo.gif'

    @tp.scraper( :url => 'http://www.dummy.com/chrome/intl/en/images/dlpage_lg.jpg',
                  :doc => TweetParser::IMAGE).should == 'dlpage_lg.jpg'
  end

  it "should return nil if document isn't image file or html/xhtml document" do
    @tp.scraper( :url => 'http://dummy.com/folder1/folder2/doc.pdf',
                  :doc => 'dummy' ).should be_nil
  end

  it "should return title of dummy html document" do
    @tp.scraper( :url => 'http://www.dummy.com',
                  :doc => ('<html> <title>wrong title</title> ' +
                           '<head> <title>My Title</title> </head></html>')).should \
                  == 'My Title'
  end

  it "should return title of html document loaded from the web" do
    h = @tp.get_web_document( 'http://www.google.com/ig?hl=en' )
    @tp.scraper( :url => h[:url],
                  :doc => h[:doc] ).should == 'iGoogle'
  end

#  @doc = File.read( File.dirname(__FILE__) + '/ig.htm' )
##  puts "Class is #{@doc.class}"         #class is String
#
#  it "should return title of web document if it is html/xhtml document" do
#    @tp.scraper( 'http://www.dummy.com/ig?hl=en', @doc.to_s ).should == 'iGoogle'
#  end

end





