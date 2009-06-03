require 'net/imap'
require 'rubygems'
require 'scruffy'

fail "Usage: ruby load_data.rb <username> <password>" unless ARGV.size == 2
imap = Net::IMAP.new('imap.gmail.com', 993, true)
imap.login(ARGV[0], ARGV[1])
imap.select("MintStatements")
worths = Array.new
imap.search(["SINCE", "27-Feb-2009"]).each do |message_id|
  body = imap.fetch(message_id, "RFC822.TEXT")[0].attr["RFC822.TEXT"]
  if /Net Worth:  \$(\d+),(\d+)\r\n/ =~ body
    net_worth = $~.captures.join.to_i
    worths << net_worth
  end
  envelope = imap.fetch(message_id, "ENVELOPE")[0].attr["ENVELOPE"]
#  puts "#{message_id}: \t#{net_worth.to_s}"
end

graph = Scruffy::Graph.new
graph.title = "My Net Worth According to Mint.com"
graph.renderer = Scruffy::Renderers::Standard.new

graph.add :bar, 'Net Worth', worths

graph.render :to => "mynetworth.svg"
#Seems like this requires RMagick to be installed
#graph.render  :width => 300, :height => 200, :to => "mynetworth.png", :as => 'png'

imap.logout()
imap.disconnect()
