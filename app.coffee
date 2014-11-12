'use strict'
express = require 'express'
bodyParser = require 'body-parser'
compress = require 'compression'
dbserver = require './dbserver'
collector = require './collector'

app = express()
app.use(express.static(__dirname + '/wwwfiles'))
app.use(bodyParser.json())
app.use(compress())

db = new dbserver.DbServer()
sensor = new collector.Collector()

app.get '/checkout', (req, res) ->
	db.checkout(res)

app.get '/sensor', (req, res) ->
	sensor.checkout(res)

app.post '/submit', (req, res) ->
	# don't be afraid for no check to the post data, body-parser has did that.
	db.submit(req.body, res)

app.post '/query', (req, res) ->
	db.query(req.body, res)

if require.main == module
	app.listen 8000, ->
		console.log "Listening on #{this.address().address}:#{this.address().port}"
else
	exports.app = app
