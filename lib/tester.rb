require 'rss/2.0'
require 'open-uri'
#require File.dirname(__FILE__) + '/lib/tweet_parser'
require 'tweet_parser'


tp = TweetParser.new

url = 'http://twitter.com/statuses/user_timeline/657863.rss' #Kevin Rose
url = 'http://twitter.com/statuses/user_timeline/14326840.rss' #Dvorak
url = 'http://twitter.com/statuses/user_timeline/14964767.rss' #thurrott
url = 'http://twitter.com/statuses/user_timeline/127583.rss'
url = 'http://twitter.com/statuses/user_timeline/3829151.rss' #Leo
url = 'http://twitter.com/statuses/user_timeline/6451212.rss' #Zachary

feed = RSS::Parser.parse(open(url).read, false)
puts "=== Channel: #{feed.channel.title} ==="

i = 1
s_time = Time.new

feed.items.each do |item|
  #a = tp.parse(item.title)
  a = tp.parse(item.description)
  if a != nil
    puts i
    puts a
    puts
    i += 1
  end
  
end

tot_time = Time.new - s_time
puts tot_time  #16.29s


#tweet = 'leolaporte: I am LOVING this Wi-Fi Radio. I can add podcasts to Reciva.com ' +
#        'and they show up. TWiT Live, too. And 14,000 other stations. http://tr.im/14om'
#
#tw3 = 'Ah... loving http://timesvr.com My virtual assistant an hour'
#
#tw4 = 'Pownce  by @sixapart - here: http://tinyurl.com/6goqs3'
#
#tw5 = 'leolaporte: I ♥ Foxmarks. http://foxmarks.com Just another reason to use Firefox everywhere.'
#
#a = $tp.parse(tw5)
#
#puts a
