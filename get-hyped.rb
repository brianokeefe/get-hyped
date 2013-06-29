require 'curb'
require 'nokogiri'
require 'json'
require 'optparse'
require 'fileutils'
require 'mp3info'

class HypeScraper
	def initialize(options)
		@curl = Curl::Easy.new do |curl|
			curl.headers["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.79 Safari/537.4"
			curl.enable_cookies = true
			curl.cookiejar = "cookies.txt"
			curl.follow_location = true
			curl.timeout = 20
		end

		@options = options
	end

	def get_from_playlist(playlist)
		begin
			parseCount = 0
			downCount = 0
			get_track_list(playlist).each do |track|
				parseCount += 1
				if not downloaded?(track["id"])
					puts "Downloading: #{track['artist']} - #{track['song']}"
					begin
						url = get_mp3_url(track["id"], track["key"])
						puts "   - #{url}"
						get_mp3(track, url)
						add_to_downloaded(track["id"])
						puts "   Success!"
						downCount += 1
					rescue
						warn "   [ERROR] Couldn't download #{track['artist']} - #{track['song']}"
					end
					sleep 2
				end
			end
		rescue
			warn "Couldn't get specified playlist."
		end
		if parseCount == 0
			puts "Playlist is empty!"
		else
			puts "Complete! Parsed #{parseCount}, Downloaded #{downCount}"
		end
	end

	private

	def get_track_list(playlist)
		JSON.parse(Nokogiri::HTML(curl("http://hypem.com/#{playlist}/?ax=1")).xpath("//*[@id='displayList-data']").first)["tracks"]
	end

	def get_mp3_url(id, key)
		JSON.parse(curl("http://hypem.com/serve/source/#{id}/#{key}?_=#{Time.now.to_i}"))["url"].gsub(' ', '%20')
	end

	def get_mp3(track, url)
		@curl.timeout = 120

		file_dir = "#{@options[:directory]}/#{track['artist']} - #{track['song'].gsub('.', '')}.mp3"

		File.open(file_dir, 'wb') do |file|
			file.write(curl(url))
		end

		Mp3Info.open(file_dir) do |mp3|
			mp3.tag.title = track["song"]
			mp3.tag.artist = track["artist"]
			mp3.tag.album = @options[:album]
		end
	end

	def add_to_downloaded(id)
		File.open("tracks.txt", "a+") do |file|
			file.write("#{id}\n")
		end
	end

	def downloaded?(id)
		@options[:dupes] == true ? false : File.read("tracks.txt").include?(id)
	end

	def curl(url)
		@curl.url = url
		@curl.perform
		@curl.body_str
	end
end

# parameters
options = Hash.new
options[:dupes] = false
options[:album] = "Hype Machine"
options[:directory] = "mp3"
options[:list] = false

opt = OptionParser.new do |o|
	o.banner = "Usage: get-hyped [OPTION]... [PLAYLIST]"

	o.on("--dupes", "Download tracks even if they've already been downloaded") do 
		options[:dupes] = true
	end

	o.on("-a", "--album [ALBUM]", String, "Specify the album MP3 tag for tracks being downloaded") do |s|
		options[:album] = s
	end

	o.on("-d", "--dir [DIRECTORY]", String, "Specify the target directory") do |s|
		options[:directory] = s
	end

	o.on("-l", "--list [FILE]", String, "Use a list of playlists") do |s|
		options[:list] = s
	end
end

# parse parameters
opt.parse!(ARGV)
if (!options[:list])
	if (ARGV[0].nil?)
		puts "Please specify a playlist."
		Process.exit
	end
	playlists = [ARGV[0]]
else
	playlists = File.readlines(options[:list])
end

# do it
begin
	puts "Using target directory: #{options[:directory]}"
	if (!File.directory?(options[:directory]))
		Dir.mkdir(options[:directory])
	end
	FileUtils.touch("tracks.txt")
	begin
		for playlist in playlists
			HypeScraper.new(options).get_from_playlist(playlist)
		end
	rescue Interrupt
		puts "\nExiting..."
	end
rescue
	warn "Could not write necessary files."
end
