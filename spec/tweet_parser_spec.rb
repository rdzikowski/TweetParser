##################################
#                                #
# Author: Robert Dzikowski       #
# email:  rdzikowski@gmail.com   #
#                                #
##################################


require File.dirname(__FILE__) + '/../lib/tweet_parser'


describe TweetParser, '#parse' do

  before(:each) do
    @tp = TweetParser.new
  end


  it "should raise ArgumentError exception if tweet arg. is nil" do
    lambda { @tp.parse nil }.should raise_error( ArgumentError )
  end

  it "should raise ArgumentError exception if tweet arg. is not a String" do
    lambda { @tp.parse 123.02 }.should raise_error( ArgumentError )
  end

  it "should return nil if tweet arg. has no user name" do
    @tp.parse( 'no user name' ).should be_nil
  end

  it "should return nil for tweets without url" do
    @tp.parse( 'zpinter: just grabbed lunch at Blake St, http:/wrong.com, ' +
               'www.ex.com' ).should be_nil
  end

  it "should return nil for tweets with incorrect url" do
    @tp.parse( 'tom: some url http://www.in_correct.com').should be_nil
  end

  it "should return nil for non existent web page" do
    @tp.parse( 'tom: http://www.rubyinside.com/non-existent' ).should be_nil
  end

  it "should return nil for redirected pdf web document" do
    @tp.parse( 'zpinter: look at this file http://tinyurl.com/6dkmob' ).should be_nil
    # url of this doc is 'http://www.cs.umd.edu/~jfoster/ruby.pdf'
  end

  it "should return nil for Excel document" do
    @tp.parse( 'tom: http://dummy.com/folder1/folder2/doc.xls' ).should be_nil
  end

  it "should return user, url and title for iGoogle web page" do
    a = @tp.parse( 'tom: some url http://www.google.com/ig?hl=en' )
    a[0].should == 'tom'
    a[1].should == 'http://www.google.com/ig?hl=en'
    a[2].should == 'iGoogle'
  end

  it "should return file name as a title for big web image file" do
    a = @tp.parse( 'tom: some file http://gdperftest.com/perftest/gfx/fightingfalcons.jpg')
    a[0].should == 'tom'
    a[1].should == 'http://gdperftest.com/perftest/gfx/fightingfalcons.jpg'
    a[2].should == 'fightingfalcons.jpg'
  end

  it "should return file name as a title if document is an image file" do
    a = @tp.parse( 'tom: http://www.dummy.com/intl/en_ALL/images/logo.1.gif')
    a[0].should == 'tom'
    a[1].should == 'http://www.dummy.com/intl/en_ALL/images/logo.1.gif'
    a[2].should == 'logo.1.gif'
  end
#################################

  
  #Long-lasting tests
#  it "should return nil when url links to unaccesible web server" do
#    @tp.parse( 'tom: some url http://www.11111.com').should be_nil
#  end
#
#  it "should return results for redirected url" do
#    a = @tp.parse( 'mopostal: saturated market = end of detroit ' +
#                   'as we know it http://bit.ly/qaUN' )
#    a[0].should == 'mopostal'
#    a[1].should == 'http://blogs.moneycentral.msn.com/topstocks/archive/' +
#                   '2008/11/17/why-a-bailout-won-t-save-detroit.aspx'
#    a[2].should == "Why bailout won't save Detroit - Top Stocks Blog - MSN Money"
#  end

end



















