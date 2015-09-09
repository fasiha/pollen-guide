"use strict";

/*

Usage: 

$ node server.js [file to watch] [port]

Open http://localhost:3000/take3.html

Whenever the text file is edited

 */

console.log('ARGV: ', process.argv);
var FILE_TO_WATCH = process.argv[2] || '';
var COMMAND_TO_RUN = process.argv[3] || '';
var PORT = process.argv[4] || 3000;

var fs = require('fs');
var child_process = require('child_process');
var EventEmitter = require('events');
var express = require('express');
var onFinished = require('on-finished');
var bodyParser = require("body-parser");

var events = {refreshme : new EventEmitter()};

var app = express();
app.use('/public', express.static('public'));
app.use(bodyParser.text({ type: '*/*' }));

app.get('/', function(req, res) { res.send('Hello World!'); });

app.post("/events/:id", function(req, res) {
  // This was helpful: http://www.html5rocks.com/en/tutorials/eventsource/basics/
  var id = req.params.id;
  if (!(id in events)) {
    events[id] = new EventEmitter();
  }
  events[id].emit('sendMessage', 'sendMessage', req.body || "empty");
  res.status(200).send('Thanks\n');
});

app.get("/events/:id", function(req, res) {
  console.log('Subscription received');
  var id = req.params.id;

  res.writeHead(200, {
    'Content-Type' : 'text/event-stream',
    'Cache-Control' : 'no-cache',
    'Connection' : 'keep-alive'
  });
  res.write("\n");

  // From http://www.futureinsights.com/home/real-time-the-easy-way-with-eventsource-angularjs-and-nodejs.html
  function sendSse(eventname, data, id) {
    console.log('Event transmitted. Event:', eventname, 'data:', data, 'id:',
                id);
    res.write("event: " + eventname + "\n");
    if (id) {
      res.write("id: " + id + "\n");
    }
    res.write("data: " + JSON.stringify(data) + "\n\n");
  }
  if (!(id in events)) {
    events[id] = new EventEmitter();
  }
  events[id].on('sendMessage', sendSse);

  onFinished(res, function(err, res) {
    events[id].removeListener('sendMessage', sendSse);
  });

});

var server = app.listen(PORT, function() {
  var host = server.address().address;
  var port = server.address().port;

  console.log('Example app listening at http://%s:%s', host, port);
});

var handleFiles = function() {
  if (FILE_TO_WATCH !== '') {
    var watch = fs.watch(FILE_TO_WATCH, function(ev, fname) {
      var transmitMessage = function() {
        events.refreshme.emit('sendMessage', 'sendMessage', ev);
        console.log('File change detected and transmitted:', ev);
      };

      if (COMMAND_TO_RUN !== '') {
        child_process.exec(COMMAND_TO_RUN, function(err, stdout, stderr) {
          console.log('Command run: \n', stdout);
          transmitMessage();
        })
      } else {
        transmitMessage();
      }

      if (ev==='rename') {
        handleFiles();
      }
    });
  }
}
handleFiles();
