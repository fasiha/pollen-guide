POLLEN="TESTING" raco pollen render take3.html && curl -f -s -X POST 'http://localhost:8080/pub?id=refreshme' -d 'now'

