require "rubygems"
require "mechanize"

unless !!ENV["NZBM_USER"] and !!ENV["NZBM_PASS"]
  puts "please specify NZBM_USER/PASS"
  exit!
end


# A simple Client for NZBMatrix.com
#
# nzbm_client = NZBMatrixClient.new
# nzbm_client.authenticate!("user", "pass")
# results = nzbm_client.search("simpsons")
#
class NZBMatrixClient

  NZBMatrixURL = "http://nzbmatrix.com/"
  NZBMatrixLoginPath = "account-login.php"
  

  NZBMatrixSearchPath = "nzb-search.php"
  NZBMatrixCategories = {
    "all" => 0, 
    "TV_HD" => 41 
  }

  def initialize
    @cookies = []
  end

  def authenticate!(user,pass)
    header = send_request(NZBMatrixLoginPath, {"username" => user, "password" => pass}, "-i")

    header.split("\n").each do |line|
      if line.include?("Set-Cookie")
        @cookies.push(line[12..-1].split(";")[0])
      end
    end

    @cookies.length == 2
  end

  def search(query,category)
    send_request(NZBMatrixSearchPath, {"search" => query, "cat" => category}, "-i")
  end

private

  def send_request(path,params,curlopts)
    cookie_part = @cookies.join(";")
    params_part = params.map{ |key, value| "-F \"#{key}=#{value}\"" }.join(" ")
    puts cookie_part
    puts %Q{curl -s #{curlopts} #{params_part} -b "#{cookie_part}" "#{NZBMatrixURL}#{path}"}
    %x{curl -s #{curlopts} #{params_part} -b "#{cookie_part}" "#{NZBMatrixURL}#{path}"}
  end

end

nzbm_client = NZBMatrixClient.new

if nzbm_client.authenticate!(ENV["NZBM_USER"], ENV["NZBM_PASS"])
  puts "[x] logged in"
else
  exit!
end

suche = nzbm_client.search("simspons", NZBMatrixClient::NZBMatrixCategories["all"])

puts suche
