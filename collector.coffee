'use strict'

class Collector
	constructor: ->
		MongoClient = require('mongodb').MongoClient
		url = 'mongodb://localhost:27017/sensor'
		MongoClient.connect url, (err, db) =>
			process.exit(err) if err
			@db = db
			@data = db.collection('data')

	checkout: (res) =>
		@data.aggregate {$group: {_id : "$node_guid", records: {$push: "$$ROOT"}}}, (err, docs) ->
			if err
				res.status(500).end()
			else
				res.send(docs)

exports.Collector = Collector