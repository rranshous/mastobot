require 'mastodon'
require 'oauth2'
require 'pry'


# check if we already have client id and secret
puts "reading"
client_id, client_secret = File.read('./.creds.txt').split(' ') rescue []
client_details = OpenStruct.new client_id: client_id,
                                client_secret: client_secret
puts "read: #{client_details}"

base_url = ENV['BASE_URL']
raise "Missing BASE_URL" if base_url.nil?
client = Mastodon::REST::Client.new(base_url: base_url)

# create application if we don't
if client_details.client_id.nil?
  puts "creating app"
  client_details = client.create_app('codebot',
                                     'urn:ietf:wg:oauth:2.0:oob',
                                     'read write')
  puts "client_details: #{client_details}"
  puts " client_id: #{client_details.client_id}"
  puts " client_secret: #{client_details.client_secret}"
  puts "writing"
  File.open('./.creds.txt', 'w') do |fh|
    fh.write("#{client_details.client_id} #{client_details.client_secret}")
  end
  puts "done writing"
end

# log user in through application
user_details = OpenStruct.new(username: ENV['OAUTH_USERNAME'],
                              password: ENV['OAUTH_PASSWORD'])
if user_details.username.nil?
  write "username: "
  user_details.username = gets.chomp
end
if user_details.password.nil?
  write "password: "
  user_details.password = gets.chomp
  puts "logging in user"
end
puts "logging in: #{user_details}"

# use oauth2 to log in user
oauth_client = OAuth2::Client.new(client_details.client_id,
                                  client_details.client_secret,
                                  site: 'https://offilth.stream')
token_details = oauth_client.password.get_token(user_details.username,
                                                user_details.password,
                                                scope: 'write read')
puts "logged in! [#{token_details.token}]"

# create client w/ token
client = Mastodon::REST::Client.new(base_url: base_url,
                                    bearer_token: token_details.token)

# post toot via user
path = File.absolute_path("./robot.jpg")
puts "uploading image: #{path}"
media = client.upload_media(path)
puts "uploaded success: #{media.id} #{media.preview_url}"
puts "tooting"
#status = client.create_status("bot test")
client.create_status("bot test (with image)",nil,[media.id])


puts
puts "DONE"
