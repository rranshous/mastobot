require 'mastodon'
require 'oauth2'
require 'yaml'


class Details

  attr_accessor :sources, :attrs

  def initialize sources, attrs
    self.sources = sources
    self.attrs = attrs
    setup_accessors
  end

  def setup_accessors
    attrs.each do |attr|
      self.class.class_eval do
        attr_accessor attr.to_sym
      end
    end
  end

  def populate
    sources.each do |source|
      break if fully_populated?
      populate_from source
    end
  end

  def save
    sources.each{|s| save_to s }
  end

  def merge details
    attrs.each do |attr|
      value = details.send attr.to_sym
      self.send "#{attr}=", value
    end
  end

  def to_s
    "<#{self.class.name} #{attrs.map{|a| self.send(a)}.join(' ')}>"
  end
  alias_method :inspect, :to_s

  private

  def save_to source
    attrs.each do |attr|
      source.set attr, self.send(attr)
    end
  end

  def populate_from source
    attrs.zip(source.get(*attrs)).each do |attr, value|
      self.send "#{attr}=", value
    end
  end

  def fully_populated?
    filled_attrs.length == attrs.length
  end

  def filled_attrs
    attrs.select{ |a| self.send a }
  end

  def file *args
    CredsFile.new(*args)
  end

  def prompt *args
    CredsPrompt.new(*args)
  end

  def env *args
    CredsEnv.new(*args)
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

  def set k, v
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
  attr_accessor :prefix

  def initialize prefix=''
    self.prefix = prefix
  end

  def get *tokens
    tokens.map{ |t| from_env("#{prefix}#{t.to_s.upcase}") }
  end

  def set k, v
  end

  private

  def from_env key
    puts "from env: #{key}"
    ENV[key]
  end
end
