module.exports = function (server, db) {
    var validateRequest = require("../../../dev/server/auth/validateRequest");

    server.get("/api/v1/bucketList/data/activity", function (req, res, next) {
        validateRequest.validate(req, res, db, function () {
            db.activity.find({
                user : req.params.token
            },function (err, list) {
                res.writeHead(200, {
                    'Content-Type': 'application/json; charset=utf-8'
                });
                res.end(JSON.stringify(list));
            });
        });
        return next();
    });


}