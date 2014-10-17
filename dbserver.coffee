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
					valueWeight = @weight(value.level, value.frequency)
					newWeight = docWeight + valueWeight
					newX = (docs.x * docWeight + json.x * valueWeight) / newWeight
					newY = (docs.y * docWeight + json.y * valueWeight) / newWeight
					newZ = (docs.z * docWeight + json.z * valueWeight) / newWeight

					@wifi.update {"BSSID":value.BSSID}, {$set:{"x":newX, "y": newY, "z": newZ, "weight": newWeight}}, (err) ->
						console.log(err) if err
				else
					record =
						"SSID": value.SSID
						"BSSID": value.BSSID
						"x": json.x
						"y": json.y
						"z": json.z
						"weight": @weight(value.level, value.frequency)

					@wifi.insert record, (err) ->
						console.log(err) if err

	query: (json, res) =>
		scans = json.scan.map (value) ->
			return value.BSSID

		weights = {}
		for index, value of json.scan
			weights[value.BSSID] = @weight(value.level, value.frequency)

		@wifi.find({"BSSID": {$in: scans}}).toArray (err, docs) ->
			console.log(err) if err

			iter = (prev, curr) ->
				currWeight = weights[curr.BSSID]
				return [
					prev[0] + (curr.x * currWeight),
					prev[1] + (curr.y * currWeight),
					prev[2] + (curr.z * currWeight),
					prev[3] + currWeight
				]

			merge = docs.reduce(iter, [0, 0, 0, 0])

			location =
				"x": merge[0] / merge[3]
				"y": merge[1] / merge[3]
				"z": merge[2] / merge[3]
				"weight": merge[3]

			res.send(location)

	checkout: (res) =>
		@wifi.find().sort({"weight":-1}).toArray (err, docs) ->
			if err
				res.status(500).end()
			else
				res.send(docs)

	weight: (dbm, mhz) ->
		exp = (27.55 - (20.0 * Math.log(mhz) / Math.LN10) + Math.abs(dbm)) / 20.0
		return 100.0 / (10.0 ** exp)

exports.DbServer = DbServer