POLLEN="TESTING" raco pollen render take3.html && yes|cp -p take3.html public/ && curl -f -s -X POST http://127.0.0.1:3000/events/refreshme -d 'change'

