'use strict'
express = require 'express'
bodyParser = require 'body-parser'
compress = require 'compression'
dbserver = require './dbserver'

app = express()
app.use(express.static('/home/hyz/smart-campus-backend/wwwfiles'))
app.use(bodyParser.json())
app.use(compress())

process.on 'uncaughtException', (err) ->
	console.log err

db = new dbserver.DbServer()

app.get '/checkout', (req, res) ->
	db.checkout(res)

app.post '/submit', (req, res) ->
	# don't be afraid for no check to the post data, body-parser has did that.
	db.submit(req.body, res)

app.listen 9000, ->
	console.log "Listening on #{this.address().address}:#{this.address().port}"