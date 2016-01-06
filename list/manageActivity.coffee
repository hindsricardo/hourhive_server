module.exports = (server, db) ->
  validateRequest = require('../../../dev/server/auth/validateRequest')
  server.get '/api/v1/bucketList/data/activity', (req, res, next) ->
    validateRequest.validate req, res, db, ->
      db.activity.find { user: req.params.token }, (err, list) ->
        res.writeHead 200, 'Content-Type': 'application/json; charset=utf-8'
        res.end JSON.stringify(list)
        return
      return
    next()
  return
