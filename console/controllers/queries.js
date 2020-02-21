'use strict';

const { loggers } = require('winston')
const logger = loggers.get('ccterminal-logger')

const Pool = require('pg').Pool
const pool = new Pool({
  user: process.env.DATABASE_USER,
  host: 'localhost',
  database: process.env.DATABASE_NAME,
  password: process.env.DATABASE_PASSWORD,
  port: process.env.DATABASE_PORT,
})

exports.getHome = function(req, res) {
  pool.query('SELECT * from users ORDER BY username ASC', (error, results) => {
    if (error) {
      logger.error(error)
    }
    var data = results.rows;
    var firstname = results.rows[0].username
    //console.log(data);
    res.render('home', { userList:data,title:'Gear Balance' });
  });
};

exports.awardG = function(req, res){
  for (var key in req.body) {
    let value = req.body[key];
    if(value){
      pool.query('UPDATE users SET gear = gear + $2 WHERE username = $1', [key, value], (error, results) => {
        if(error){
          logger.error(error)
        }
      })
      logger.info(`Awarded ${value} gear to uid ${key}`)
    }
  }
  res.redirect('/')
};
