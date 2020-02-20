'use strict';
// question routes
module.exports = function(app) {
  var db = require('../controllers/queries');

  app.route('/')
   .get(db.getHome);

};
