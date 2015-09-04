#lang pollen

◊h1{Take Three. Automate the world.}

◊section{
This take is all about infrastructure to ease Pollen authoring. Make sure to follow the instructions on installing, configuring, and starting Nginx. Also be sure you have ◊code{fswatch} and ◊code{curl} installed.

There is already a ◊code{testing.sh} shell script in this directory. It renders this document, then sends a message, the string "now", to an Nginx channel called "refreshme"—this is done using ◊code{curl}.

Run ◊code{./testing.sh}. If you don't already have it open, visit ◊a['((href "http://localhost:8080/take3.html"))]{localhost:8080/take3.html}. 

Also run ◊code{fswatch.sh}, which sets up an fswatch that runs ◊code{testing.sh} whenever either this Pollen markup file or the template changes. This script will take over your terminal, so start it somewhere out of the way.

Now, edit this file and save it. In a second, you'll see your browser refresh with the new contents.

}
