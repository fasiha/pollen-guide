#lang pollen

◊h1{Take Three. Automate the world.}


◊section{
This take is all about infrastructure to ease Pollen authoring. Make sure you installed and set up ◊a['((href "https://nodejs.org"))]{node.js}. If you are using Internet Explorer or Edge or any browser that doesn't support EventSource (listed in red at ◊a['((href "http://caniuse.com/#feat=eventsource"))]{Can I Use}), pay attention to the instructions for you.

Run ◊code{$ node server take3.html.pm "POLLEN=TESTING raco pollen render take3.html"}. This starts the webserver and auxiliary code to watch this ◊code{take3.html.pm} file for changes.

Open ◊a['((href "http://localhost:3000/take3.html"))]{localhost:3000/take3.html} and position your browser window so you can watch it while you edit this document.

Now, edit this Pollen file and save it. In a second or three, you'll see your browser refresh with the new contents.

Caveat: for annoying technical reasons, the page will update twice, in rapid succession, every time you save this Pollen file.

This works fine now..... under Ubuntu Linux

I wonder if this will make a difference
}
