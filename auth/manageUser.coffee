module.exports = (server, db) ->
  pwdMgr = require('./managePasswords')
  validateRequest = require('../auth/validateRequest')
  validateOrgRequest = require('../auth/validateOrgRequest')
  # unique index
  db.constraints.uniqueness.createIfNone 'appUsers', 'email', (err, constraints) ->
    console.log constraints
  db.constraints.uniqueness.createIfNone 'appOrgs', 'accountUsername', (err, constraints) ->
    console.log constraints

  # USER REGISTER
  server.post '/api/v1/bucketList/auth/register', (req, res, next) ->
    user = req.params
    pwdMgr.cryptPassword user.password, (err, hash) ->
      user.password = hash
      db.save user,['appUsers'], (err, dbUser) ->
        if err
          # duplicate key error
          if err.code == 11000
            res.writeHead 400, 'Content-Type': 'application/json; charset=utf-8'
            res.end JSON.stringify(
              error: err
              message: 'A user with this email already exists')
        else
          res.writeHead 200, 'Content-Type': 'application/json; charset=utf-8'
          dbUser.password = '' #clear password before returning JSON object
          res.end JSON.stringify(dbUser)
        return
      return
    next()
  # ORG REGISTER
  server.post '/api/v1/bucketList/org/auth/register', (req, res, next) ->
    user = req.params
    pwdMgr.cryptPassword user.password, (err, hash) ->
      user.password = hash
      if !user.accountUsername
        res.writeHead 403, 'Content-Type': 'application/json; charset=utf-8'
        res.end JSON.stringify(
          message: 'The submission is missing accountUsername key')
      else
        db.save user, ['appOrgs'], (err, dbUser) ->
          if err
            # duplicate key error
            res.writeHead 400, 'Content-Type': 'application/json; charset=utf-8'
            res.end JSON.stringify(
              error: err
              message: 'An Organization with this username already exists')
          else
            res.writeHead 200, 'Content-Type': 'application/json; charset=utf-8'
            dbUser.password = ''
            res.end JSON.stringify(dbUser)
        return
      return
    next()
  server.post '/api/v1/bucketList/auth/login', (req, res, next) ->
    user = req.params
    if user.email.trim().length == 0 or user.password.trim().length == 0
      res.writeHead 403, 'Content-Type': 'application/json; charset=utf-8'
      res.end JSON.stringify(error: 'Invalid Credentials')
    db.find { email: req.params.email }, ['appUsers'], (err, dbUser) ->
      if dbUser.length < 1
        #if the database finds no email, it will return null, but any falsey will also mean something's amiss
        res.writeHead 403, contentTypeTipo
        res.end JSON.stringify(error: 'Invalid credentials. User not found.')
      pwdMgr.comparePassword user.password, dbUser.password, (err, isPasswordMatch) ->
        if isPasswordMatch
          res.writeHead 200, 'Content-Type': 'application/json; charset=utf-8'
          # remove password hash before sending to the client
          dbUser.password = ''
          res.end JSON.stringify(dbUser)
        else
          res.writeHead 403, 'Content-Type': 'application/json; charset=utf-8'
          res.end JSON.stringify(error: 'Invalid User')
        return
      return
    next()
  server.post '/api/v1/bucketList/org/auth/login', (req, res, next) ->
    user = req.params
    if user.email.trim().length == 0 or user.password.trim().length == 0 or user.accountUsername.trim().length == 0
      res.writeHead 403, 'Content-Type': 'application/json; charset=utf-8'
      res.end JSON.stringify(error: 'Invalid Credentials')
    db.find { accountUsername: user.accountUsername }, ['appOrgs'], (err, dbUser) ->
      if err
        console.log err
      if dbUser.length < 1
        res.writeHead 403, contentTypeTipo
        res.end JSON.stringify(error: 'Invalid credentials. User not found.')
      else
        pwdMgr.comparePassword user.password, dbUser[0].password, (err, isPasswordMatch) ->
          if isPasswordMatch
            res.writeHead 200, 'Content-Type': 'application/json; charset=utf-8'
            # remove password hash before sending to the client
            dbUser[0].password = ''
            res.end JSON.stringify(dbUser[0])
          else
            res.writeHead 403, 'Content-Type': 'application/json; charset=utf-8'
            res.end JSON.stringify(error: 'Invalid User')
          return
      return
    next()
  server.get '/api/v1/bucketList/data/user', (req, res, next) ->
    validateRequest.validate req, res, db, ->
      db.find { email: req.params.token },['appUsers'], (err, data) ->
        res.writeHead 200, 'Content-Type': 'application/json; charset=utf-8'
        res.end JSON.stringify(data)
        return
      return
    next()
  server.get '/api/v1/bucketList/data/org', (req, res, next) ->
    validateOrgRequest.validate req, res, db, ->
      db.find { accountUsername: req.params.token },['appOrgs'], (err, data) ->
        res.writeHead 200, 'Content-Type': 'application/json; charset=utf-8'
        res.end JSON.stringify(data)
        return
      return
    next()
  server.put '/api/v1/bucketList/data/org/:id', (req, res, next) ->
    validateOrgRequest.validate req, res, db, ->
      db.find { _id: db.ObjectId(req.params.id) },['appOrgs'], (err, data) ->
        `var n`
        # merge req.params/product with the server/product
        updProd = {}
        # updated products
        # logic similar to jQuery.extend(); to merge 2 objects.
        for n of data
          updProd[n] = data[n]
        for n of req.params
          if n != 'id'
            updProd[n] = req.params[n]
        db.appOrgs.update { _id: db.ObjectId(req.params.id) }, updProd, { multi: false }, (err, data) ->
          res.writeHead 200, 'Content-Type': 'application/json; charset=utf-8'
          res.end JSON.stringify(data)
          return
        return
      return
    next()
  server.put '/api/v1/bucketList/data/staff/:id', (req, res, next) ->
    validateOrgRequest.validate req, res, db, ->
      db.appOrgs.update { _id: db.ObjectId(req.params.id) }, { $set: staff: req.params.query }, { multi: false }, (err, data) ->
        if err
          console.log 'AN ERROR HAS OCCURED', err
        res.writeHead 200, 'Content-Type': 'application/json; charset=utf-8'
        res.end JSON.stringify(data)
        return
      return
    next()
  return
