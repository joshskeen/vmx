//config
var MIDI_SERVER_PORT = 8080;
var APPLICATION_SERVER_PORT = 3000;

var express = require('express');
var app = express.createServer(); 
var fs = require('fs');
var ejs = require('ejs');
console.log("ffff");
var midi = require('midi'); //receive midi messages
console.log(midi_input);
var midi_input = new midi.input();
var io = require('socket.io').listen(MIDI_SERVER_PORT); //socket.io  

var socket_reference;



io.sockets.on('connection', function (socket) {
try{	
 	midi_input.openPort(0); 
 }catch(err){
 	console.log(err);
 }

 socket_reference = socket;

 //get list of videos
 fs.readdir("../public/vids", function(err, files){
 	socket.emit('videos', files);
 });
  //close the port
 socket.on('disconnect', function () {
 	try{	
   		midi_input.closePort(0); 
	}catch(err){
		console.log(err);
	}
   //midi_input = new midi.input();
 });
});


midi_input.on('message', function(deltaTime, message) {
  		 socket_reference.emit('message', message);
});


var indexTemplate = fs.readFileSync(__dirname + '/../public/index.html', 'utf8');
app.listen(APPLICATION_SERVER_PORT);
app.use("/css", express.static(__dirname + '/../public/css'));
app.use("/images", express.static(__dirname + '/../public/images'));
app.use("/js", express.static(__dirname + '/../public/js'));
app.use("/vids", express.static(__dirname + '/../public/vids'));
app.get('/', function(req, res){
    res.end(ejs.render(indexTemplate, {}));
});