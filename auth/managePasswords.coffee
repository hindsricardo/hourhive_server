###* http://stackoverflow.com/a/14015883/1015046 *###

bcrypt = require('bcrypt')

module.exports.cryptPassword = (password, callback) ->
  bcrypt.genSalt 10, (err, salt) ->
    if err
      return callback(err)
    bcrypt.hash password, salt, (err, hash) ->
      callback err, hash
    return
  return

module.exports.comparePassword = (password, userPassword, callback) ->
  bcrypt.compare password, userPassword, (err, isPasswordMatch) ->
    if err
      return callback(err)
    callback null, isPasswordMatch
  return
