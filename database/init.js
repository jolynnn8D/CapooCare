// connect express to postgres
require('dotenv').config();
const { Pool } = require('pg');
const fs = require('fs');
const keys = require('../keys')

const devConfig = {
    user: keys.pgUser,
    host: keys.pgHost,
    database: keys.pgDatabase,
    password: keys.pgPassword,
    port: keys.pgPort,
};

const proConfig = {
    connectionString: process.env.DATABASE_URL //heroku addons
};

// const pool = new Pool(
//     process.env.NODE_ENV === "production" ? proConfig : devConfig
// );

const pool = new Pool(
    devConfig
);

// Initialize database
const initDatabase = () => {
    const init = fs.readFileSync("database/init.sql").toString();
    pool.query(init).then(
        (res) => {
            console.log('Database initialised successfully');
        }
    ).catch(
        (err) => {
            console.log(err);
        }
    )
}


module.exports = {
    initDatabase: initDatabase,
    query: (text, params) => pool.query(text, params)
};
