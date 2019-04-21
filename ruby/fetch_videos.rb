#!/usr/bin/ruby

###################
# Generate all eligible video IDs by:
# 1) Querying YouTube with keywords
# 2) Taking the top 20 videos per keyword
# 3) Filtering out "blacklisted" videos
###################

require 'yt'

VIDEOS_FILE_PATH = '../js/videos.js'.freeze
VIDEOS_FILE_BLURB = %(
// This list of videos IDs is generated manually by running 'fetch_videos.rb' every so often.
// We would love for this to be completely automatic, but Youtube API Quotas are a thing,
// as well as the fact that private API Keys + GitHub Pages don't go well together =]
)

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
  'sustainable IT technology',
  'sustainable packaging',
]

# Irrelevant videos
BLACKLIST = [
  '2z5vFxNVmK8',
  'r4t7rO-nhOw',
  '-i-Idh56Owk',
  '-q9K0Hjzk6o',
  'EnIJn0SS-3U',
  'yHXVRv_mwAE',
  'uHEfRAooih8',
  'a2KqcvD3m7Q',
  'oUWLR8S1_eA',
  'tF7asIa0SyU',
]

RECOMMENDED = [
  '1Ab9HUmQw44',
  'lnnFx5dWAzY',
]

CHANNELS = [
  'UCsaEBhRsI6tmmz12fkSEYdw', # Hot Mess
  'UCNXvxXpDJXp-mZu3pFMzYHQ', # Our Changing Climate
  'UCi6RkdaEqgRVKi3AzidF4ow', # Global Weirding
]

PLAYLISTS = [
  'PL8CdHFjBJ1d9xB0kPFlmHSlzEgAFM-9Qs',  # Grist explainers
  'PLJ8cMiYb3G5fP5oq01TBp9fgh70vDDSMe',  # Vox climate lab
  'PLeBwUoIvGwcbL_JyJ0c0h9jzCsv2fn9-9',  # Climate Adam: Climate Politics
  'PLeBwUoIvGwcalE3FhvDXR6yiwP63Wqt10',  # Climate Adam: Clarifying Climate Confusion
  'PL6kVAvCBpGR24taZhRDy0SuvbBMzb7Vny',  # Zentouro: Everyday Environmentalism
  'PL6kVAvCBpGR1BowS63FmAlmTdVb2q0HD5',  # Zentouro: Eco Activism and the Environment
  'PLJCnRdvL-3APFuU8osKzeN1d3BOB9Rhng',  # Evan Fraser: Feeding Nine Billion
  'PLzD0K2OhbVfEF5V2aVX541__SOL3q65kA',  # Fully Charged Electric motorbikes, bikes, and scooters,
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
puts "\nWriting .js file"

File.open(VIDEOS_FILE_PATH, "w") do |file|
  file.puts(VIDEOS_FILE_BLURB)
  file.puts()

  file.puts('const VIDEOS = [')
  results.each { |v| file.puts("  '#{v}',") }
  file.puts('];')
  file.puts()

  last_update = Time.now.strftime("%Y/%m/%d")
  file.puts("const LAST_UPDATE = '#{last_update}';")
end

puts "\nWrote #{results.length} total videos to list"
