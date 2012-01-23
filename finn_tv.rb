require "rubygems"
require "mechanize"

# "http://nzbmatrix.com/account-login.php"

cookies = []

unless !!ENV["NZBM_USER"] and !!ENV["NZBM_PASS"]
  puts "please specify NZBM_USER/PASS"
  exit!
end

%x{curl -s -i -F "username=#{ENV["NZBM_USER"]}" -F "password=#{ENV["NZBM_PASS"]}" "http://nzbmatrix.com/account-login.php"}.split("\n").each do |line|
  if line.include?("Set-Cookie")
    cookies.push(line[12..-1])
  end
end

if cookies.length == 2
  puts "Logged in!"
else
  puts "Not logged in!"
  exit!
end
