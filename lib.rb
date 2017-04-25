require_relative 'details'

class ServerDetails < Details
  def initialize
    sources = [ file('server.yml'), env, prompt ]
    attrs = [ :base_url ]
    super sources, attrs
  end
end

class ClientDetails < Details
  def initialize
    sources = [ file('.client_creds.yml'), env ]
    attrs = [ :client_id, :client_secret ]
    super sources, attrs
  end
end

class UserDetails < Details
  def initialize
    sources = [ file('.user_creds.yml'), env('OAUTH_'), prompt ]
    attrs = [ :username, :password ]
    super sources, attrs
  end
end
