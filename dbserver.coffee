'use strict'

class DbServer
	constructor: ->
		MongoClient = require('mongodb').MongoClient
		url = 'mongodb://localhost:27017/campus'
		MongoClient.connect url, (err, db) =>
			process.exit(err) if err
			@db = db
			@raw = db.collection('raw')
			@wifi = db.collection('wifi')

	submit: (json, res) =>
		@raw.insert json, (err) ->
			if err
				res.status(403).end()
			else
				res.status(200).end()

		json.scan.forEach (value) =>
			@wifi.findOne {"BSSID": value.BSSID}, (err, docs) =>
				if docs?
					docWeight = docs.weight
					valueWeight = (2 * (value.level + 100))**2
					newWeight = docWeight + valueWeight
					newX = (docs.x * docWeight + json.x * valueWeight) / newWeight
					newY = (docs.y * docWeight + json.y * valueWeight) / newWeight
					newZ = (docs.z * docWeight + json.z * valueWeight) / newWeight

					@wifi.update {"BSSID":value.BSSID}, {$set:{"x":newX, "y": newY, "weight": newWeight}}, (err) ->
						console.log(err) if err
				else
					record =
						"SSID": value.SSID
						"BSSID": value.BSSID
						"x": json.x
						"y": json.y
						"z": json.z
						"weight": (2 * (value.level + 100))**2

					@wifi.insert record, (err, docs) ->
						console.log(err) if err

	checkout: (res) =>
		@collection.find().toArray (err, docs) ->
			if err
				res.status(500).end()
			else
				res.send(docs)

exports.DbServer = DbServer