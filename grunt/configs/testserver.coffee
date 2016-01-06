module.exports = ->
  restify = require('restify')
  morgan = require('morgan')
  _ = require('lodash')

  if process.env.GRAPHENEDB_URL?
    url = require('url').parse(process.env.GRAPHENEDB_URL)
    db = require('seraph')(
      server: url.protocol + '//' + url.host
      user: url.auth.split(':')[0]
      pass: url.auth.split(':')[1])
  else
    db = require('seraph')("http://localhost:7474")

  console.log(db)
  server = restify.createServer()
  server.use restify.acceptParser(server.acceptable)
  server.use restify.queryParser()
  server.use restify.bodyParser()
  server.use morgan('dev')
  server.use (req, res, next) ->
    res.header 'Access-Control-Allow-Origin', '*'
    res.header 'Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE'
    res.header 'Access-Control-Allow-Headers', 'Content-Type'
    next()
    return
