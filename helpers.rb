# dumping ground

def get_mastodon_client
  require 'mastodon'
  require 'oauth2'
  require_relative 'lib'

  client_details = ClientDetails.new
  client_details.populate

  server_details = ServerDetails.new
  server_details.populate
  server_details.save
  raise "Missing BASE_URL" if server_details.base_url.nil?
  client = Mastodon::REST::Client.new(base_url: server_details.base_url)

  # create application if we don't
  if client_details.client_id.nil?
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

  # use oauth2 to log in user
  oauth_client = OAuth2::Client.new(client_details.client_id,
                                    client_details.client_secret,
                                    site: 'https://offilth.stream')
  token_details = oauth_client.password.get_token(user_details.username,
                                                  user_details.password,
                                                  scope: 'write read')

  # create client w/ token
  rest_client = Mastodon::REST::Client.new(base_url: server_details.base_url,
                                           bearer_token: token_details.token)

  MastodonClient.new rest_client
end
