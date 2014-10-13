'use strict'
express = require 'express'
bodyParser = require 'body-parser'
compress = require 'compression'
dbserver = require './dbserver'

app = express()
app.use(express.static(__dirname + '/wwwfiles'))
app.use(bodyParser.json())
app.use(compress())

db = new dbserver.DbServer()

app.get '/checkout', (req, res) ->
	db.checkout(res)

app.post '/submit', (req, res) ->
	# don't be afraid for no check to the post data, body-parser has did that.
	db.submit(req.body, res)

exports.app = app
