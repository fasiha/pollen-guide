#lang pollen

◊h1{Take Three. Automate the world.}


◊section{
This take is all about infrastructure to ease Pollen authoring. Make sure you have ◊code{fswatch} and ◊code{curl} installed. Also be sure to follow the instructions on installing, configuring, and starting Nginx.

Run ◊code{$ ./testing.sh} shell script in this directory. This renders this document, then using ◊code{curl} sends a message to the HTTP server.

Open ◊a['((href "http://localhost:8080/take3.html"))]{localhost:8080/take3.html} and position your browser window so you can watch it while you edit this document.

Run ◊code{$ ./fswatch.sh}. This script will re-run ◊code{testing.sh} when this Pollen markup file or the template changes. (This script will take over your terminal, so start it somewhere out of the way.)

Now, edit this file and save it. In a second, you'll see your browser refresh with the new contents.

}
