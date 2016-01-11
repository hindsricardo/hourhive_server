module.exports = (server, db) ->
  pwdMgr = require('./managePasswords')
  validateRequest = require('../auth/validateRequest')
  validateOrgRequest = require('../auth/validateOrgRequest')
  # unique index
  db.constraints.uniqueness.createIfNone 'appUsers', 'email', (err, constraints) ->
    console.log constraints
  db.constraints.uniqueness.createIfNone 'appOrgs', 'accountUsername', (err, constraints) ->
    console.log constraints

  # USER REGISTER & LOGIN
  server.post '/api/v1/bucketList/auth/register', (req, res, next) ->
    user = req.params
    if user.email.trim().length == 0 or user.phone.trim().length == 0
      res.writeHead 403, 'Content-Type': 'application/json; charset=utf-8'
      res.end JSON.stringify(error: 'Invalid Credentials')
    db.find {email:user.email.trim()}, ['appUsers'], (err, thisUser) ->
      if err
        throw err
      else if thisUser.length > 0
        res.writeHead 200, 'Content-Type': 'application/json; charset=utf-8'
        res.end JSON.stringify(thisUser[0])
      else
        db.save user,['appUsers'], (err, dbUser) ->
          if err
              res.writeHead 400, 'Content-Type': 'application/json; charset=utf-8'
              res.end JSON.stringify(
                error: err
                message: 'A user with this email already exists')
          else
            res.writeHead 200, 'Content-Type': 'application/json; charset=utf-8'
            res.end JSON.stringify(dbUser[0])
          return
        return
    next()
  # ORG REGISTER & LOGIN
  server.post '/api/v1/bucketList/org/auth/register', (req, res, next) ->
    user = req.params
    if user.accountUsername.trim().length == 0
      res.writeHead 403, 'Content-Type': 'application/json; charset=utf-8'
      res.end JSON.stringify(error: 'Invalid Credentials')
    else
      db.find {accountUsername: user.accountUsername}, ['appOrgs'], (err, org) ->
        if org.length > 0
          pwdMgr.comparePassword user.password, org[0].password, (err, isPasswordMatch) ->
            if isPasswordMatch
              res.writeHead 200, 'Content-Type':'application/json; charset=utf-8'
              res.end JSON.stringify(org[0])
        else
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
                    message: 'Something went wrong adding this organization. Please try again')
                else
                  res.writeHead 200, 'Content-Type': 'application/json; charset=utf-8'
                  dbUser.password = ''
                  res.end JSON.stringify(dbUser[0])
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
  ###server.put '/api/v1/bucketList/data/org/:id', (req, res, next) ->
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
    next()###
  return
