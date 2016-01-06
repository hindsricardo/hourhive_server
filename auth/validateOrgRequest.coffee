isAccountUsernameValid = (db, username, callback) ->
  db.find { accountUsername: username }, ['appOrgs'], (err, user) ->
    callback user[0]
    return
  return

module.exports.validate = (req, res, db, callback) ->
  # if the request dosent have a  header with email, reject the request
  if !req.params.token
    res.writeHead 403, 'Content-Type': 'application/json; charset=utf-8'
    res.end JSON.stringify(
      error: 'You are not authorized to access this application'
      message: 'An Email is required as part of the header')
  isAccountUsernameValid db, req.params.token, (user) ->
    if user.length < 1
      res.writeHead 403, 'Content-Type': 'application/json; charset=utf-8'
      res.end JSON.stringify(
        error: 'You are not authorized to access this application'
        message: 'Invalid User Email')
    else
      callback()
    return
  return
