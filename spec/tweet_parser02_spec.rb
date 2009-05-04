##################################
#                                #
# Author: Robert Dzikowski       #
# email:  rdzikowski@gmail.com   #
#                                #
##################################


#require 'tweet_parser'
require File.dirname(__FILE__) + '/../lib/tweet_parser'


describe TweetParser, '#get_web_document' do

  before(:each) do
    @tp = TweetParser.new
  end

  
  it "should raise URI::InvalidURIError exception for tweets with incorrect url" do
    lambda { @tp.get_web_document 'http://www.in_correct.com' }.should \
      raise_error(URI::InvalidURIError)
  end


  it "should not raise Timeout::Error exception when url links to accesible web server" do
    lambda { @tp.get_web_document 'http://www.google.com' }.should_not \
      raise_error( Timeout::Error )
  end


  it "should return nil for non existent web page" do
    @tp.get_web_document( 'http://www.rubyinside.com/non-existent' ).should be_nil
  end


  it "should return body of a web document and final url" do
#    h = @tp.get_web_document( 'http://www.rubyinside.com/test.txt' )
#    h[:doc].should == "Hello Beginning Ruby reader!\n"
#    h[:url].should == 'http://www.rubyinside.com/test.txt'

    h = @tp.get_web_document( 'http://www.google.com/ig?hl=en' )
    h[:doc].should_not be_empty
    h[:url].should == 'http://www.google.com/ig?hl=en'
  end


  it "should return body of a web document and final url for redirected url" do
    h = @tp.get_web_document( 'http://bit.ly/qaUN' )
    h[:doc].should_not be_empty
    h[:url].should == 'http://blogs.moneycentral.msn.com/topstocks/archive/' +
                   '2008/11/17/why-a-bailout-won-t-save-detroit.aspx'                 
  end


  it "should not return body of big image, but should return its url" do
    h = @tp.get_web_document( 'http://gdperftest.com/perftest/gfx/fightingfalcons.jpg')
    h[:doc].should == TweetParser::IMAGE
    h[:url].should == 'http://gdperftest.com/perftest/gfx/fightingfalcons.jpg'
  end


  it "should return nil for pdf web document" do
    @tp.get_web_document( 'http://tinyurl.com/6dkmob' ).should be_nil
#    h[:doc].should_not be_empty
#    h[:url].should == 'http://www.cs.umd.edu/~jfoster/ruby.pdf'
  end


  it "should raise Timeout::Error exception when url links to unaccesible web server" do
    lambda { @tp.get_web_document 'http://www.11111.com' }.should \
      raise_error( Timeout::Error )
  end
end



