module.exports = function (server, db) {
    var validateRequest = require("../auth/validateRequest");
    var validateOrgRequest = require("../auth/validateOrgRequest");

    server.get("/api/v1/bucketList/data/list", function (req, res, next) {
        validateRequest.validate(req, res, db, function () {
            db.bucketLists.find({},function (err, list) {
                res.writeHead(200, {
                    'Content-Type': 'application/json; charset=utf-8'
                });
                res.end(JSON.stringify(list));
            });
        });
        return next();
    });

    server.get("/api/v1/bucketList/org/data/list", function (req, res, next) {
        validateOrgRequest.validate(req, res, db, function () {
            db.bucketLists.find({
                accountUsername : req.params.token //find the accountUsername associated with the listing
            },function (err, list) {
                res.writeHead(200, {
                    'Content-Type': 'application/json; charset=utf-8'
                });
                res.end(JSON.stringify(list));
            });
        });
        return next();
    });


    server.get('/api/v1/bucketList/data/item/:id', function (req, res, next) {
        validateRequest.validate(req, res, db, function () {
            db.bucketLists.findOne({
                _id: db.ObjectId(req.params.id)
            }, function (err, data) {
                res.writeHead(200, {
                    'Content-Type': 'application/json; charset=utf-8'
                });
                res.end(JSON.stringify(data));
            });
        });
        return next();
    });
    server.get('/api/v1/bucketList/data/item/org/:id', function (req, res, next) {
        validateOrgRequest.validate(req, res, db, function () {
            db.bucketLists.findOne({
                _id: db.ObjectId(req.params.id)
            }, function (err, data) {
                res.writeHead(200, {
                    'Content-Type': 'application/json; charset=utf-8'
                });
                res.end(JSON.stringify(data));
            });
        });
        return next();
    });

    server.post('/api/v1/bucketList/data/item', function (req, res, next) {
        validateOrgRequest.validate(req, res, db, function () {
            var item = req.params;
            db.bucketLists.save(item,
                function (err, data) {
                    res.writeHead(200, {
                        'Content-Type': 'application/json; charset=utf-8'
                    });
                    res.end(JSON.stringify(data));
                });
        });
        return next();
    });

    server.put('/api/v1/bucketList/data/item/update/:id', function (req, res, next) {
        validateOrgRequest.validate(req, res, db, function () {
                db.bucketLists.update({
                    _id: db.ObjectId(req.params.id)
                }, {$set:{
                    title:req.params.title,
                    capacity: req.params.capacity,
                    updated: req.params.updated,
                    location: req.params.location,
                    description: req.params.description,
                    customFields: req.params.customFields

                }}, {
                    multi: false
                }, function (err, data) {
                    res.writeHead(200, {
                        'Content-Type': 'application/json; charset=utf-8'
                    });
                    res.end(JSON.stringify(data));
                });
        });
        return next();
    });

    server.put('/api/v1/bucketList/data/item/book/:id', function (req, res, next) {
        validateRequest.validate(req, res, db, function () {
                var query = JSON.parse(req.params.query);
                db.bucketLists.update({
                    _id: db.ObjectId(req.params.id)
                },query, {
                    multi: true
                }, function (err, data) {
                    res.writeHead(200, {
                        'Content-Type': 'application/json; charset=utf-8'
                    });
                    res.end(JSON.stringify(data));
                });
        });
        return next();
    });

    server.del('/api/v1/bucketList/data/item/:id', function (req, res, next) {
        validateOrgRequest.validate(req, res, db, function () {
            db.bucketLists.remove({
                _id: db.ObjectId(req.params.id)
            }, function (err, data) {
                res.writeHead(200, {
                    'Content-Type': 'application/json; charset=utf-8'
                });
                res.end(JSON.stringify(data));
            });
            return next();
        });
    });

}