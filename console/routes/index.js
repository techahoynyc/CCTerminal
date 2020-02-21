'use strict';
// routes/index.js

module.exports = function(app) {
  var db = require('../controllers/queries');

  app.route('/')
   .get(db.getHome);

   app.route('/awardG')
     .post(db.awardG);

};
