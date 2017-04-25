require 'mastodon'
require 'oauth2'
require_relative 'lib'
require 'pry'


client_details = ClientDetails.new
client_details.populate
puts "loaded: #{client_details}"

base_url = ENV['BASE_URL']
raise "Missing BASE_URL" if base_url.nil?
client = Mastodon::REST::Client.new(base_url: base_url)

# create application if we don't
if client_details.client_id.nil?
  puts "creating app"
  retrieved_client_details = client.create_app('codebot',
                                               'urn:ietf:wg:oauth:2.0:oob',
                                               'read write')
  client_details.merge retrieved_client_details
  client_details.save
end

# log user in through application
user_details = UserDetails.new
user_details.populate
user_details.save
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
#client.create_status("bot test")
client.create_status("bot test (with image)",nil,[media.id])


puts
puts "DONE"
