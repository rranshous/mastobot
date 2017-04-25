require_relative 'mastodon_client'
require_relative 'details'

class ServerDetails < Details
  def _sources
    [ file('server.yml'), env, prompt ]
  end
  def _attrs
    [ :base_url ]
  end
end

class ClientDetails < Details
  def _sources
    [ file('.client_creds.yml'), env ]
  end
  def _attrs
    [ :client_id, :client_secret ]
  end
end

class UserDetails < Details
  def _sources
    [ file('.user_creds.yml'), env('OAUTH_'), prompt ]
  end
  def _attrs
    [ :username, :password ]
  end
end
