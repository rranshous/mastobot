require 'mastodon'
require 'oauth2'
require 'yaml'


class ClientDetails

  attr_accessor :client_id, :client_secret

  def populate
    populate_from(env) or populate_from(file)
  end

  def save
    save_to(file)
  end

  def update_from details
    self.client_id = details.client_id
    self.client_secret = details.client_secret
  end

  def to_s
    "<ClientDetails #{client_id} #{client_secret}>"
  end
  alias_method :inspect, :to_s

  private

  def save_to source
    source.set :client_id, client_id
    source.set :client_secret, client_secret
  end

  def populate_from source
    puts "populating from #{source}"
    self.client_id, self.client_secret = source.get(:client_id, :client_secret)
    client_id && client_secret
  end

  def file
    CredsFile.new
  end

  def prompt
    CredsPrompt.new
  end

  def env
    CredsEnv.new
  end

end

class CredsFile
  attr_accessor :file_path

  def initialize file_path='./.creds.yml'
    self.file_path = file_path
  end

  def get *tokens
    tokens = tokens.map(&:to_s)
    File.open(file_path) do |fh|
      data = YAML.load(fh.read)
      tokens.map { |t| data[t] }
    end
  rescue Errno::ENOENT
    []
  end

  def set k, v
    begin
      new_data = File.open(file_path, 'r') do |fh|
        YAML.load(fh.read).merge(k.to_s => v)
      end
    rescue Errno::ENOENT
      new_data = { k.to_s => v }
    end
    File.write(file_path, YAML.dump(new_data))
  end
end

class CredsPrompt

  attr_accessor :pipe_in, :pipe_out

  def initialize pipe_in=STDIN, pipe_out=STDOUT
    self.pipe_in = pipe_in
    self.pipe_out = pipe_out
  end

  def get *tokens
    tokens.map do |token|
      write("enter #{token}: ")
      read
    end
  end

  private

  def write msg
    pipe_out.write msg
  end

  def read
    pipe_in.gets
  end
end

class CredsEnv
  def get *tokens
    tokens.map{ |t| ENV["OAUTH_#{t.upcase}"] }
  end
end
