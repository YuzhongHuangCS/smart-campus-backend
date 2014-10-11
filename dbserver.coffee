'use strict'

class DbServer
	constructor: ->
		MongoClient = require('mongodb').MongoClient
		url = 'mongodb://localhost:27017/campus'
		MongoClient.connect url, (err, db) =>
			process.exit(err) if err
			@db = db
			@collection = db.collection('raw');

	submit: (data, res) =>
		@collection.insert data, (err) ->
			if err
				res.status(403).end()
			else
				res.status(200).end()

	checkout: (res) =>
		@collection.find().toArray (err, docs)->
			if err
				res.status(500).end()
			else
				res.send(docs)

exports.DbServer = DbServer