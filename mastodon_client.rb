require 'mastodon'
require 'oauth2'

class MastodonClient

  attr_accessor :mastodon_rest_client

  def initialize mastodon_rest_client=nil
    self.mastodon_rest_client = mastodon_rest_client
  end

  def toot_image image_file_path, message=''
    path = File.absolute_path image_file_path
    media = mastodon_rest_client.upload_media(path)
    mastodon_rest_client.create_status(message, nil, [media.id])
  end
end
