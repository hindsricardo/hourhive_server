module.exports = (server, db) ->
  validateRequest = require('../auth/validateRequest')
  validateOrgRequest = require('../auth/validateOrgRequest')
  server.get '/api/v1/bucketList/data/list', (req, res, next) ->
    validateRequest.validate req, res, db, ->
      db.bucketLists.find {}, (err, list) ->
        res.writeHead 200, 'Content-Type': 'application/json; charset=utf-8'
        res.end JSON.stringify(list)
        return
      return
    next()
  server.get '/api/v1/bucketList/org/data/list', (req, res, next) ->
    validateOrgRequest.validate req, res, db, ->
      db.bucketLists.find { accountUsername: req.params.token }, (err, list) ->
        res.writeHead 200, 'Content-Type': 'application/json; charset=utf-8'
        res.end JSON.stringify(list)
        return
      return
    next()
  server.get '/api/v1/bucketList/data/item/:id', (req, res, next) ->
    validateRequest.validate req, res, db, ->
      db.bucketLists.findOne { _id: db.ObjectId(req.params.id) }, (err, data) ->
        res.writeHead 200, 'Content-Type': 'application/json; charset=utf-8'
        res.end JSON.stringify(data)
        return
      return
    next()
  server.get '/api/v1/bucketList/data/item/org/:id', (req, res, next) ->
    validateOrgRequest.validate req, res, db, ->
      db.bucketLists.findOne { _id: db.ObjectId(req.params.id) }, (err, data) ->
        res.writeHead 200, 'Content-Type': 'application/json; charset=utf-8'
        res.end JSON.stringify(data)
        return
      return
    next()
  server.post '/api/v1/bucketList/data/item', (req, res, next) ->
    validateOrgRequest.validate req, res, db, ->
      item = req.params
      db.bucketLists.save item, (err, data) ->
        res.writeHead 200, 'Content-Type': 'application/json; charset=utf-8'
        res.end JSON.stringify(data)
        return
      return
    next()
  server.put '/api/v1/bucketList/data/item/update/:id', (req, res, next) ->
    validateOrgRequest.validate req, res, db, ->
      db.bucketLists.update { _id: db.ObjectId(req.params.id) }, { $set:
        type: req.params.type
        title: req.params.title
        capacity: req.params.capacity
        updated: req.params.updated
        archived: req.params.archived
        location: req.params.location
        description: req.params.description
        customFields: req.params.customFields }, { multi: false }, (err, data) ->
        res.writeHead 200, 'Content-Type': 'application/json; charset=utf-8'
        res.end JSON.stringify(data)
        return
      return
    next()
  server.put '/api/v1/bucketList/data/item/book/:id', (req, res, next) ->
    validateRequest.validate req, res, db, ->
      query = JSON.parse(req.params.query)
      db.bucketLists.update { _id: db.ObjectId(req.params.id) }, query, { multi: true }, (err, data) ->
        res.writeHead 200, 'Content-Type': 'application/json; charset=utf-8'
        res.end JSON.stringify(data)
        return
      return
    next()
  server.del '/api/v1/bucketList/data/item/:id', (req, res, next) ->
    validateOrgRequest.validate req, res, db, ->
      db.bucketLists.remove { _id: db.ObjectId(req.params.id) }, (err, data) ->
        res.writeHead 200, 'Content-Type': 'application/json; charset=utf-8'
        res.end JSON.stringify(data)
        return
      next()
    return
  return
