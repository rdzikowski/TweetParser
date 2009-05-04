require 'rss/2.0'
require 'open-uri'
#require File.dirname(__FILE__) + '/lib/tweet_parser'
require 'tweet_parser'


tp = TweetParser.new

url = 'http://twitter.com/statuses/user_timeline/657863.rss' #Kevin Rose
url = 'http://twitter.com/statuses/user_timeline/14326840.rss' #Dvorak
url = 'http://twitter.com/statuses/user_timeline/127583.rss'
url = 'http://twitter.com/statuses/user_timeline/3829151.rss' #Leo
url = 'http://twitter.com/statuses/user_timeline/6451212.rss' #Zachary
url = 'http://twitter.com/statuses/user_timeline/14964767.rss' #thurrott

feed = RSS::Parser.parse(open(url).read, false)
puts "=== Channel: #{feed.channel.title} ==="

i = 1
arr = []
s_time = Time.new

feed.items.each do |item|
  #a = tp.parse(item.title)
  arr[i] = Thread.new do
    tp.parse(item.description)
  end
  i += 1
end

arr.each_with_index do |thread, i|
  #if thread.value != nil  #undefined method `value' for nil:NilClass (NoMethodError)
  if thread != nil and thread.value != nil
    puts i
    puts thread.value
    puts
  end
end

tot_time = Time.new - s_time
puts tot_time  #ruby 3.00s, jruby 4.14s
