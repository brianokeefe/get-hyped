get-hyped
=========

A Hype Machine song scraper written in Ruby. 

Installation
------------

Run <code>bundle install</code> in the <code>get-hyped</code> directory and you should be ready to rock!

Usage
-----

<code>ruby get-hyped.rb [OPTION]... [PLAYLIST]</code>

        --dupes                      Download tracks even if they've already been downloaded
    -a, --album [ALBUM]              Specify the album MP3 tag for tracks being downloaded
    -d, --dir [DIRECTORY]            Specify the target directory

<code>PLAYLIST</code> can be any playlist or username from hypem.com. Examples include:

<ul>
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

Once invoked, the script will attempt to download all of the MP3 files from the specified playlist into the specified target directory. A list of downloaded tracks will be maintained in <code>tracks.txt</code>; a track that has already been downloaded will not be downloaded again unless the <code>--dupes</code> argument is supplied.

TODO
----
<ul>
	<li>Allow the user to specify multiple playlists
	<li>Growl/email notifications</li>
	<li>Logging</li>
	<li>Adjustable timeout values</li>
	<li>Take page number as an argument?</li>
	<li>Optional sleep interval between downloads?
</ul>
