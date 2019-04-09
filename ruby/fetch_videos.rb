#!/usr/bin/ruby

###################
# Generate all eligible video IDs by:
# 1) Querying YouTube with keywords
# 2) Taking the top 50 videos per keyword
# 3) Filtering out "blacklisted" videos
###################

require 'yt'

DEVELOPER_KEY = ''.freeze;

YOUTUBE_API_SERVICE_NAME = 'youtube'
YOUTUBE_API_VERSION = 'v3'

KEYWORDS = [
  'Environmental sustainability',
  'Food security',
  'Food justice',
  'Waste management',
  'Waste reduction',
  'Low waste movement',
  'minimalism and no impact',
  'Climate Lab',
  'Recycling',
  'Climate change practical solutions',
  'Emissions reduction',
  'Tradesoffs sustainability',
  'Eco-friendly cities',
  'Environmental urban density',
  'Environmental management talk',
  'Environmental news',
  'Sustainable agriculture',
  'Sustainable farming',
  'Sustainable food systems',
  'Holistic sustainability',
  'Sustainable design',
  'Circular economy news',
  'Environmental issues',
  'Environmental education talk',
  'Green buildings',
  'Green passive housing',
  'Visualizing climate change',
  'Sustainable Development Goals',
  'Sustainability economics',
  'Green transportation',
  'Sustainable mobility',
  'Green spaces',
  'Resource based economies',
  'Passive house',
  'Biophilic Design',
  'Renewable energy',
  'The investment logic for sustainability',
]

BLACKLIST = [
  '2z5vFxNVmK8',
  'r4t7rO-nhOw',
  '-i-Idh56Owk',
  '-q9K0Hjzk6o',
  'EnIJn0SS-3U',
]

RECOMMENDED = [
  '1Ab9HUmQw44',
]

CHANNELS = [
  'UCsaEBhRsI6tmmz12fkSEYdw', # Hot Mess
  'UCNXvxXpDJXp-mZu3pFMzYHQ', # Our Changing Climate
]

PLAYLISTS = [
  'PL8CdHFjBJ1d9xB0kPFlmHSlzEgAFM-9Qs',  # Grist explainers
]

# Initialize Yt
#----------------------------------------------
Yt.configure do |config|
  config.log_level = :debug
  config.api_key = DEVELOPER_KEY
end

videos = Yt::Collections::Videos.new

# Fetch first 30 videos per keyword by relevance
#-----------------------------------------------
results = []

KEYWORDS.each do |keyword| 
  puts "Searching for keyword #{keyword}"
  results.push(*videos.where(q: keyword, order: 'relevance', in: 'us').first(20))
end

# Pull all the videos from channels
# -----------------------------------------------
CHANNELS.each do |channel_id|
  puts "\nPulling videos from channel #{channel_id}"
  channel = Yt::Channel.new id: channel_id
  channel.videos.each { |v| results << v }
end

# Pull all the videos from playlists
# -------------------------------------------------
PLAYLISTS.each do |playlist_id|
  puts "\nPulling videos from playlist #{playlist_id}"
  playlist = Yt::Playlist.new id: playlist_id
  playlist.playlist_items.each { |item| results << item.video }
end

# Eliminate any results with time < 2 minutes and more than 40m
# Also eliminate any results in our blacklist
#-----------------------------------------------
puts "\nEliminating videos too long/short or in blacklist"
results = results.reject do |v|
  duration_in_seconds = v.duration
  minutes = duration_in_seconds / 60

  invalidDuration = minutes < 2 || minutes > 40
  inBlacklist = BLACKLIST.include? v.id

  eliminate = invalidDuration || inBlacklist
  puts "\nEliminating video: '#{v.title}'"  if eliminate
  
  eliminate
end

# Remove any duplicates
#-----------------------------------------------
puts "\nEliminating duplicates"
results = results.map(&:id).uniq

# Add in our recommended videos
# -----------------------------------------------
puts "\nAdding recommended videos"
results.push(*RECOMMENDED)

# Shuffle the results
#-----------------------------------------------
puts "\nShuffling list"
results.shuffle

# Write latest results to a file
#-----------------------------------------------
puts "\nWriting file"
File.open("videos.txt", "w") do |file|
  file.puts "Last update: #{Time.now.strftime("%Y/%m/%d")}\n\n"

  results.each { |v| file.puts v}
end

puts "\nWrote #{results.length} total videos to list"
