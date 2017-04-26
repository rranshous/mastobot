require 'mastodon'
require 'oauth2'
require_relative 'helpers'

client = get_mastodon_client()
client.toot_nsfw_image './robot_nsfw.jpg', 'robot love'
client.toot_image './robot.jpg', 'bot test (with image)'
client.toot 'bot test'

puts
puts "DONE"
