require 'curb'
require 'nokogiri'
require 'json'
require 'optparse'
require 'fileutils'

class HypeScraper
	def initialize(directory, options)
		@curl = Curl::Easy.new do |curl|
			curl.headers["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.79 Safari/537.4"
			curl.enable_cookies = true
			curl.cookiejar = "cookies.txt"
			curl.follow_location = true
			curl.timeout = 10
		end

		@directory = directory
		@options = options
	end

	def get_from_playlist(playlist)
		begin
			get_track_list(playlist).each do |track|
				if not downloaded?(track["id"])
					puts "Downloading: #{track['artist']} - #{track['song']}"

					begin
						url = get_mp3_url(track["id"], track["key"])
						puts "   - #{url}"
						get_mp3(track, url)
						add_to_downloaded(track["id"])
						puts "   Success!"
					rescue
						puts "   [ERROR] Couldn't download #{track['artist']} - #{track['song']}"
					end

					sleep 2
				end
			end
		rescue
			puts "Couldn't get specified playlist."
		end
			puts "Complete!"
	end

	private

	def get_track_list(playlist)
		JSON.parse(Nokogiri::HTML(curl("http://hypem.com/#{playlist}/?ax=1")).xpath("//*[@id='displayList-data']").first)["tracks"]
	end

	def get_mp3_url(id, key)
		JSON.parse(curl("http://hypem.com/serve/source/#{id}/#{key}?_=#{Time.now.to_i}"))["url"]
	end

	def get_mp3(track, url)
		File.open("#{@directory}/#{track['id']}.mp3", 'wb') do |file|
			file.write(curl(url))
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
options = {}
opt = OptionParser.new do |o|
	o.banner = "Usage: get-hyped [OPTION]... [PLAYLIST] [TARGET DIRECTORY]"

	o.on("-d", "--dupes", "Download tracks even if they've already been downloaded") do 
		options[:dupes] = true
	end
end

# parse parameters
opt.parse!(ARGV)
playlist, directory = ARGV[0..1]

if (directory.nil? || directory.empty?) 
	directory = "mp3"
end

# do it
begin
	puts "Using target directory: #{directory}"
	if (!File.directory?(directory))
		Dir.mkdir(directory)
	end
	FileUtils.touch("tracks.txt")
	if (!playlist.nil?)
		begin
			HypeScraper.new(directory, options).get_from_playlist(playlist)
		rescue Interrupt
			puts "\nExiting..."
		end
	else
		puts "Please specify a playlist."
	end
rescue
	puts "Could not write necessary files."
end