
expect = require('chai').expect
request = require('supertest')
restify = require "restify"
server = restify.createServer()
testserver = require('../configs/testserver.coffee')(server)
bcrypt = require('bcrypt')
pwdMgr = require '../../auth/managePasswords'

restify = require('restify')
morgan = require('morgan')
_ = require('lodash')
#database = require("./config/database")
if process.env.GRAPHENEDB_URL?
  url = require('url').parse(process.env.GRAPHENEDB_URL)
  db = require('seraph')(
    server: url.protocol + '//' + url.host
    user: url.auth.split(':')[0]
    pass: url.auth.split(':')[1])
else
  db = require('seraph')()

describe '#/auth/managePasswords', ->
  log = console.log

  before (done) ->
    done()
  beforeEach ->
    console.log = ->
  it '- Should take in a passowrd and encrypt it', (done) ->
    password = 'Car81you'
    pwdMgr.cryptPassword password, (err, hash) ->
      expect(err).to.equal(undefined)
      expect(hash.length).to.be.greaterThan(password.length)
      console.log = log
      done()

  it ' - Should take in a hash and string and decrypt hash and compare to the string', (done) ->
    hash = "$2a$10$pfPTxWzR7G3TM73u.zSqZ.SjEJxURKTwYgW8/OQA/sO7dYp2HPOde"
    string = "Barz81"
    pwdMgr.comparePassword string, hash, (err, isPasswordMatch) ->
      expect(isPasswordMatch).not.to.equal(undefined)
      expect(err).to.equal(null)
      console.log = log
      done()


### describe '#/auth/manageUser', ->
  log = console.log

  before (done) ->
    manageUsers = require('../../auth/manageUser')(server, db)
    done()

  beforeEach ->
    # Done to prevent any server side  console logs from the routes
    # to appear on the console when running tests
    console.log = ->

  it '- should POST a user that is a person and get back a response', (done) ->
    # the userID is the facebook id that is parsed to be an int.
    user =
      name: 'Ricardo Hinds',
      userID: 1221272058,

    request(server)
    .post('/api/v1/diaspora/auth/person/register')
    .send(user)
    .end (err, res) ->
      #enable the console log
      console.log = log
      data = JSON.parse res.text
      expect(err).to.be.null
      expect(data).to.have.any.keys('message','name','userID')
      expect(data).to.not.have.keys('error')
      expect(res.status).to.not.equal(404)
      done()
####
