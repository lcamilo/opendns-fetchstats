## NAME

   ___                   ____  _   _ ____    ____  _        _         _____    _       _               
  / _ \ _ __   ___ _ __ |  _ \| \ | / ___|  / ___|| |_ __ _| |_ ___  |  ___|__| |_ ___| |__   ___ _ __ 
 | | | | '_ \ / _ \ '_ \| | | |  \| \___ \  \___ \| __/ _` | __/ __| | |_ / _ \ __/ __| '_ \ / _ \ '__|
 | |_| | |_) |  __/ | | | |_| | |\  |___) |  ___) | || (_| | |_\__ \ |  _|  __/ || (__| | | |  __/ |   
  \___/| .__/ \___|_| |_|____/|_| \_|____/  |____/ \__\__,_|\__|___/ |_|  \___|\__\___|_| |_|\___|_|   
       |_|                                                                                             


## SYNOPSIS
	fetchstats <username> <network_id> <YYYY-MM-DD> [<YYYY-MM-DD>]

## DESCRIPTION
	Automatically fetch your OpenDNS Top Domains data for the given
	date range in CSV format.  Fetches all pages and combines them
	into one CSV file, which is writed at current folder.

## INSTALLATION
	The script doesn't need to be "installed" but it is nice to put
	it on your PATH somewhere.

## DEPENDENCIES FOR WINDOWS
	None

## VERSION
	0.2 - Some corrections to work with actual opendns site
	    - Some console informations
	    - Writing results to file
	    - When large date range, wait 2 mitues when receive 20 hits reached message
	    - Removed linux version (I am not able to maintain the linux version)

	0.1 - Base code

## AUTHOR
	Leandro Camilo <3925979+lcamilo@users.noreply.github.com>

## THANKS TO
	Richard Crowley <richard@opendns.com>
	Brian Hartvigsen <brian.hartvigsen@opendns.com>
	For base code.

## LICENSE
	This work is licensed under a Creative Commons
	Attribution-Share Alike 3.0 Unported License
	<http://creativecommons.org/licenses/by-sa/3.0/>
