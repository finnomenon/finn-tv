require "rubygems"
require "mechanize"

unless !!ENV["NZBM_USER"] and !!ENV["NZBM_PASS"]
  puts "please specify NZBM_USER/PASS"
  exit!
end

class NZBMatrixClient

  NZBMatrixURL = "http://nzbmatrix.com/"
  NZBMatrixLoginPath = "account-login.php"

  def initialize
    @cookies = []
  end

  def authenticate!(user,pass)
    header = send_request(NZBMatrixLoginPath, {"username" => user, "password" => pass}, "-i")

    header.split("\n").each do |line|
      if line.include?("Set-Cookie")
        @cookies.push(line[12..-1])
      end
    end

    @cookies.length == 2
  end

private

  def send_request(path,params,curlopts)
    params_part = params.map{ |key, value| "-F \"#{key}=#{value}\"" }.join(" ")
    %x{curl -s #{curlopts} #{params_part} "#{NZBMatrixURL}#{path}"}
  end

end

nzbm_client = NZBMatrixClient.new
logged_in = nzbm_client.authenticate!(ENV["NZBM_USER"], ENV["NZBM_PASS"])

puts  "Logged in? - " + logged_in.inspect
if !logged_in
  exit!
end


#    nzbm_client.get_latest_shows

