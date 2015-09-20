var isEmailValid = function (db, email, callback) {
    db.appUsers.findOne({
        email: email
    }, function (err, user) {
        callback(user);
    });
};

var isEmailAccountUsername = function (db, username, callback) {
    db.appOrgs.findOne({
        accountUsername: username
    }, function (err, org) {
        callback(org);
    });
};

module.exports.validate = function (req, res, db, callback) {
    // if the request dosent have a  header with email, reject the request
    if (!req.params.token) {
        res.writeHead(403, {
            'Content-Type': 'application/json; charset=utf-8'
        });
        res.end(JSON.stringify({
            error: "You are not authorized to access this application",
            message: "An Email is required as part of the header"
        }));
    };


    isEmailValid(db, req.params.token, function (user) {
        if (!user) {
            isEmailAccountUsername(db,req.params.token, function(org){
                if(!org) {
                    res.writeHead(403, {
                        'Content-Type': 'application/json; charset=utf-8'
                    });
                    res.end(JSON.stringify({
                        error: "You are not authorized to access this application",
                        message: "Invalid User Email or Username"
                    }));
                }
            })

        } else {
            callback();
        }
    });
};