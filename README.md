get-hyped
=========

A Hype Machine song scraper written in Ruby. 

Installation
------------

Run <code>bundle install</code> in the <code>get-hyped</code> directory and you should be ready to rock!

Usage
-----

<code>ruby get-hyped.rb [OPTION]... [PLAYLIST] [TARGET DIRECTORY]</code>

    -d, --dupes                      Download tracks even if they've already been downloaded

<code>PLAYLIST</code> can be any playlist or username from hypem.com. Examples include:

<ul>
	<li>popular</li>
	<li>latest</li>
	<li>latest/noremix</li>
	<li>popular</li>
	<li>popular/lastweek</li>
	<li>chillwave</li>
	<li>indie</li>
	<li>brianok</li>
	<li>brianok/3</li>
</ul>

Note how the last example included a "/3" to indicate page 3 of the playlist (higher numbered pages contain older songs). For more playlists, you can take a look at the top navigation bar on hypem.com. 

Once invoked, the script will attempt to download all of the MP3 files from the specified playlist into the specified target directory. A list of downloaded tracks will be maintained in <code>tracks.txt</code>; a track that has already been downloaded will not be downloaded again unless you supply the <code>-d</code> argument.

TODO
----
<ul>
	<li>Properly name and tag downloaded MP3 files
	<li>Optional sleep interval between downloads?
</ul>