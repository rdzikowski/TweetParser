
Tweet Parser specification
--------------------------

Tasks


•Create a ruby class to parse twitter messages

?Given a string that contains a username and a URL
?Parses that string, finds the username and the URL
?Opens that URL using Net/HTTP
¦If fetching the location returns a 301 or 307 redirect, then instead open that URL using Net/HTTP
?If the URL is an html page, use Hpricot to parse the title tag of the page
?If the URL is an image, try to find the name of the file in the URL  (ex:  http://www.google.com/intl/en_ALL/images/logo.gif becomes logo.gif)
?If the URL is any other type of data, ignore it (return nil)

?Ultimately, the parse function  will return:
¦The username that created the tweet

¦The URL that was parsed
¦The title of the URL



Structure of the class

class TweetParser
    #tweet is a string
 
    #returns:
    #  user is a string, such as zpinter
    #  url is a string, such as http://www.google.com/intl/en_ALL/images/logo.gif
    #  title is a string, such as logo.gif

    def parse(tweet)
        #... code here

        return [user, url, title]
    end
    
end


Example run

tp = TweetParser.new
res = tp.parse("mopostal: saturated market = end of detroit as we know it http://bit.ly/qaUN")

# Results
# res[0] = "mopostal"
# res[1] = "http://blogs.moneycentral.msn.com/topstocks/archive/2008/11/17/why-a-bailout-won-t-save-detroit.aspx"
# res[2] = "Why bailout won't save Detroit - Top Stocks Blog - MSN Money"


Example run where the URL links to a PDF


res = tp.parse("zpinter: look at this file http://tinyurl.com/6dkmob")

# Results
# res = nil


Example run with no URL

res = tp.parse("zpinter: just grabbed lunch at Blake St")

# Results
# res = nil
