require 'mastodon'
require 'oauth2'

class MastodonClient

  attr_accessor :mastodon_rest_client

  def initialize mastodon_rest_client=nil
    self.mastodon_rest_client = mastodon_rest_client
  end

  def toot message
    mastodon_rest_client.create_status(message)
  end

  def toot_image image_file_path, message=''
    path = File.absolute_path image_file_path
    media = mastodon_rest_client.upload_media(path)
    mastodon_rest_client.create_status(message, nil, [media.id])
  end

  def toot_nsfw_image image_file_path, message=''
    path = File.absolute_path image_file_path
    media = mastodon_rest_client.upload_media(path)
    params = {
      status: message,
      in_reply_to_id: nil,
      'media_ids[]':  [media.id],
      sensitive: 1,
      spoiler_text: '',
    }
    mastodon_rest_client.perform_request_with_object(
      :post, '/api/v1/statuses', params, Mastodon::Status)
  end
end
